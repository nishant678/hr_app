import 'dart:async';
import 'package:camera/camera.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/shimmer_loading.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/repository/face_verify_api/face_verify_http_api_repository.dart';
import 'package:hr_app/services/face_attendance/face_attendance_validator.dart';
import 'package:hr_app/services/face_attendance/ml_camera_input.dart';
import 'package:hr_app/services/session_manager/session_controller.dart';
import 'package:hr_app/view/bottombar/bottom_navigation_bar.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});
  @override
  State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  FaceDetector? _detector;
  final _repo = FaceVerifyHttpApiRepository();
  CameraController? _controller;
  CameraDescription? _cameraDesc;
  bool _init = true,
      _permDenied = false,
      _busy = false,
      _capturing = false,
      _completed = false,
      _faceValid = false;
  String _hint = 'Camera tayyar ho rahi hai';
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
    try {
      _detector = await FaceDetector.create(
        model: FaceDetectionModel.frontCamera,
        minFaceSize: 0.1,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _init = false;
          _hint = 'Model load failed: $e';
        });
      }
      return;
    }
    final cams = await availableCameras();
    final picked = cams.firstWhere(
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _init = false;
          _hint = 'Camera error: $e';
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _init = false;
      _hint = 'Chehra oval me laayein — auto register hoga';
    });
    try {
      await _controller!.startImageStream(_onCameraImage);
    } catch (_) {}
  }

  Future<void> _onCameraImage(CameraImage img) async {
    if (!mounted || _completed || _capturing || _busy) return;
    final now = DateTime.now();
    if (_lastRun != null &&
        now.difference(_lastRun!) < const Duration(milliseconds: 420)) {
      return;
    }
    _lastRun = now;
    _busy = true;
    final ctrl = _controller;
    final cam = _cameraDesc;
    final det = _detector;
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
          _hint = 'Chehra laayein';
        });
      } else if (faces.length > 1) {
        _cancelTimer();
        setState(() {
          _faceValid = false;
          _hint = 'Sirf ek chehra';
        });
      } else {
        final r = FaceAttendanceValidator.validate(faces.first, sz);
        if (r.ok) {
          if (!_faceValid) {
            _cancelTimer();
            _countdown = 3;
            _timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (!mounted || _completed || _capturing || !_faceValid) {
                t.cancel();
                return;
              }
              _countdown--;
              if (_countdown <= 0) {
                t.cancel();
                _doRegister();
              } else {
                setState(() => _hint = 'Registering in $_countdown...');
              }
            });
          }
          setState(() {
            _faceValid = true;
            _hint = _countdown > 0
                ? 'Registering in $_countdown...'
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

  Future<void> _doRegister() async {
    if (_completed || !mounted || _capturing) return;
    _cancelTimer();
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    setState(() {
      _capturing = true;
      _hint = 'Registering…';
    });
    try {
      if (ctrl.value.isStreamingImages) await ctrl.stopImageStream();
      final shot = await ctrl.takePicture();
      await _repo.registerFace(shot.path);
      _completed = true;
      SessionController.faceRegistered = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face register ho gaya!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomBar()),
        );
      }
    } catch (e) {
      _capturing = false;
      _hint = 'Register failed: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
      try {
        if (ctrl.value.isInitialized && !ctrl.value.isStreamingImages) {
          await ctrl.startImageStream(_onCameraImage);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Face Registration'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBar(),
    );
  }

  Widget _buildBody() {
    if (_init) {
      return const AppShimmer(
        child: Center(
          child: SizedBox(
            width: 200,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(140)),
              ),
            ),
          ),
        ),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return Center(
        child: Text(
          _hint,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      );
    }
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
                    duration: const Duration(milliseconds: 250),
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
    if (_init || _controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }
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
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                _capturing
                    ? 'Registering…'
                    : _faceValid && _countdown > 0
                    ? 'Register in $_countdown…'
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
          ],
        ),
      ),
    );
  }
}
