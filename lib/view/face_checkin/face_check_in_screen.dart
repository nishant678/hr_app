import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/shimmer_loading.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/repository/attendance_api/attendance_http_api_repository.dart';
import 'package:hr_app/repository/face_verify_api/face_verify_http_api_repository.dart';
import 'package:hr_app/services/face_attendance/face_attendance_validator.dart';
import 'package:hr_app/services/face_attendance/ml_camera_input.dart';
import 'package:image/image.dart' as img;

class FaceCheckInScreen extends StatefulWidget {
  final double? latitude, longitude;
  final String? locationAddress;
  final bool isCheckOut;
  const FaceCheckInScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.isCheckOut = false,
  });
  @override
  State<FaceCheckInScreen> createState() => _FaceCheckInScreenState();
}

class _FaceCheckInScreenState extends State<FaceCheckInScreen> {
  FaceDetector? _detector;
  final _attendanceRepo = AttendanceHttpApiRepository();
  final _faceVerifyRepo = FaceVerifyHttpApiRepository();
  CameraController? _controller;
  CameraDescription? _cameraDesc;
  bool _init = true,
      _permDenied = false,
      _busy = false,
      _capturing = false,
      _completed = false,
      _faceValid = false;
  String _hint = 'Camera tayyar ho rahi hai…';
  DateTime? _lastRun;
  Timer? _timer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _cancelTimer();
    _controller?.dispose();
    _detector?.dispose();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _countdown = 0;
  }

  Future<void> _bootstrap() async {
    if (kIsWeb) {
      setState(() {
        _init = false;
        _hint = 'Face check-in only on Android/iOS';
      });
      return;
    }
    try {
      _detector = await FaceDetector.create(
        model: FaceDetectionModel.frontCamera,
        minFaceSize: 0.1,
      );
    } catch (e) {
      if (mounted)
        setState(() {
          _init = false;
          _hint = 'Model load failed: $e';
        });
      return;
    }
    final cams = await availableCameras();
    var picked = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );
    _cameraDesc = picked;
    _controller = CameraController(
      picked,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      if (mounted)
        setState(() {
          _init = false;
          _permDenied = e.code.contains('permission');
          _hint = e.description ?? e.code;
        });
      return;
    }
    if (!mounted) return;
    setState(() {
      _init = false;
      _hint = 'Chehra oval me laayein — auto capture hoga';
    });
    try {
      await _controller!.startImageStream(_onCameraImage);
    } catch (_) {}
  }

  Future<void> _onCameraImage(CameraImage img) async {
    if (!mounted || _completed || _capturing || _busy) return;
    var now = DateTime.now();
    if (_lastRun != null &&
        now.difference(_lastRun!) < Duration(milliseconds: 420))
      return;
    _lastRun = now;
    _busy = true;
    final ctrl = _controller, cam = _cameraDesc, det = _detector;
    if (ctrl == null ||
        !ctrl.value.isInitialized ||
        cam == null ||
        det == null) {
      _busy = false;
      return;
    }
    final rot = mlFaceFrameRotation(
      width: img.width,
      height: img.height,
      camera: cam,
      deviceOrientation: ctrl.value.deviceOrientation,
    );
    try {
      final faces = await det.detectFacesFromCameraImage(
        img,
        mode: FaceDetectionMode.full,
        rotation: rot,
        maxDim: 960,
      );
      if (!mounted || _completed || _capturing) {
        _cancelTimer();
        _busy = false;
        return;
      }
      final sz = faces.isNotEmpty
          ? faces.first.originalSize
          : Size(img.width.toDouble(), img.height.toDouble());
      if (faces.isEmpty) {
        _cancelTimer();
        setState(() {
          _faceValid = false;
          _hint = 'Chehra laayein / Bring face';
        });
      } else if (faces.length > 1) {
        _cancelTimer();
        setState(() {
          _faceValid = false;
          _hint = 'Sirf ek chehra / Only one face';
        });
      } else {
        final r = FaceAttendanceValidator.validate(faces.first, sz);
        if (r.ok) {
          if (!_faceValid) {
            _cancelTimer();
            _countdown = 3;
            _timer = Timer.periodic(Duration(seconds: 1), (t) {
              if (!mounted || _completed || _capturing || !_faceValid) {
                t.cancel();
                return;
              }
              _countdown--;
              if (_countdown <= 0) {
                t.cancel();
                _captureAndVerify();
              } else {
                setState(() => _hint = 'Capturing in $_countdown...');
              }
            });
          }
          setState(() {
            _faceValid = true;
            _hint = _countdown > 0
                ? 'Capturing in $_countdown...'
                : 'Hold still';
          });
        } else {
          _cancelTimer();
          setState(() {
            _faceValid = false;
            _hint = r.message;
          });
        }
      }
    } catch (e) {
      _cancelTimer();
      if (mounted) setState(() => _hint = 'Error: $e');
    } finally {
      _busy = false;
    }
  }

  Future<Size> _readImageSizeBytes(Uint8List bytes) async {
    try {
      final d = img.decodeImage(bytes);
      if (d != null) return Size(d.width.toDouble(), d.height.toDouble());
    } catch (_) {}
    return Size(720, 1280);
  }

  double? _blurScore(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final gray = img.grayscale(decoded);
      final w = 320;
      final h = (w * gray.height / gray.width).round();
      final small = img.copyResize(gray, width: w, height: h);
      double sum = 0, count = 0;
      for (int y = 1; y < small.height - 1; y++) {
        for (int x = 1; x < small.width - 1; x++) {
          final p = small.getPixel(x, y);
          final gv = img.getLuminance(p);
          final laplacian =
              (img.getLuminance(small.getPixel(x - 1, y)) +
                      img.getLuminance(small.getPixel(x + 1, y)) +
                      img.getLuminance(small.getPixel(x, y - 1)) +
                      img.getLuminance(small.getPixel(x, y + 1)) -
                      4 * gv)
                  .abs();
          sum += laplacian * laplacian;
          count++;
        }
      }
      return count > 0 ? sum / count : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _deviceInfoMap() {
    try {
      return {
        if (!kIsWeb) 'device.os': Platform.operatingSystem,
        'device.version': Platform.operatingSystemVersion,
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _captureAndVerify() async {
    if (_completed || !mounted || _capturing) return;
    _cancelTimer();
    final ctrl = _controller, det = _detector;
    if (ctrl == null || !ctrl.value.isInitialized || det == null) return;
    setState(() {
      _capturing = true;
      _faceValid = false;
      _hint = 'Capturing…';
    });
    try {
      if (ctrl.value.isStreamingImages) await ctrl.stopImageStream();
      final shot = await ctrl.takePicture();
      final path = shot.path;
      final faces = await det.detectFacesFromFilepath(
        path,
        mode: FaceDetectionMode.full,
      );
      final bytes = await File(path).readAsBytes();
      final sz = await _readImageSizeBytes(bytes);
      if (!mounted || _completed) return;

      if (faces.isEmpty) {
        setState(() {
          _hint = 'No face — try again';
          _capturing = false;
        });
        await ctrl.startImageStream(_onCameraImage);
        return;
      }
      if (faces.length > 1) {
        setState(() {
          _hint = 'Multiple faces';
          _capturing = false;
        });
        await ctrl.startImageStream(_onCameraImage);
        return;
      }
      final r = FaceAttendanceValidator.validate(faces.first, sz);
      if (!r.ok) {
        setState(() {
          _hint = r.message;
          _capturing = false;
        });
        await ctrl.startImageStream(_onCameraImage);
        return;
      }

      final bs = _blurScore(bytes);
      if (bs != null && bs < 120) {
        setState(() {
          _hint = 'Blurry — hold steady (sharpness $bs)';
          _capturing = false;
        });
        await ctrl.startImageStream(_onCameraImage);
        return;
      }

      setState(
        () => _hint = widget.isCheckOut ? 'Checking out…' : 'Checking in…',
      );
      bool registered = false;
      try {
        registered = await _faceVerifyRepo.isFaceRegistered();
      } catch (_) {
        registered = false;
      }
      if (!registered) {
        try {
          await _faceVerifyRepo.registerFace(path);
        } catch (e) {
          if (!mounted || _completed) return;
          setState(() {
            _hint = 'Register failed: $e';
            _capturing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
          );
          await ctrl.startImageStream(_onCameraImage);
          return;
        }
      }
      if (widget.isCheckOut) {
        await _attendanceRepo.checkOut(faceImagePath: path);
      } else {
        await _attendanceRepo.checkIn(
          faceImagePath: path,
          latitude: widget.latitude,
          longitude: widget.longitude,
          locationAddress: widget.locationAddress,
          deviceInfo: _deviceInfoMap(),
        );
      }
      _completed = true;
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hint = '${widget.isCheckOut ? 'Check-out' : 'Check-in'} failed';
        _capturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      await ctrl.startImageStream(_onCameraImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.isCheckOut ? 'Check-out' : 'Check-in'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBar(),
    );
  }

  Widget _buildBody() {
    if (_init)
      return AppShimmer(
        child: Center(
          child: SizedBox(
            width: 200,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
        ),
      );
    if (_permDenied)
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            _hint,
            style: TextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ),
      );
    final c = _controller;
    if (c == null || !c.value.isInitialized)
      return Center(
        child: Text(
          _hint,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      );
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: CameraPreview(c)),
              IgnorePointer(
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    width: 0.72.sw.clamp(220.0, 300.0),
                    height: 0.38.sh.clamp(280.0, 400.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(140),
                      border: Border.all(
                        color: _faceValid
                            ? AppColors.dashboardClockInGreen
                            : Colors.white.withValues(alpha: 0.9),
                        width: 3,
                      ),
                      boxShadow: _faceValid
                          ? [
                              BoxShadow(
                                color: AppColors.dashboardClockInGreen
                                    .withValues(alpha: 0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.paddingM),
                  color: Colors.black54,
                  child: Text(
                    _hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar() {
    if (_init ||
        _permDenied ||
        _controller == null ||
        !_controller!.value.isInitialized)
      return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        12.h,
        24.w,
        12.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.85), Colors.black],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_capturing)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                _capturing
                    ? 'Verifying…'
                    : _faceValid && _countdown > 0
                    ? 'Auto-capture in $_countdown…'
                    : _faceValid
                    ? 'Hold still…'
                    : 'Chehra oval me laayein',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _capturing || _faceValid
                      ? AppColors.dashboardClockInGreen
                      : Colors.white70,
                  fontSize: 13.sp,
                  fontWeight: _faceValid ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (_capturing) SizedBox(width: 34),
          ],
        ),
      ),
    );
  }
}
