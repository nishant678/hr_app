import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hr_app/configs/components/shimmer_loading.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/repository/attendance_api/attendance_http_api_repository.dart';
import 'package:hr_app/services/face_attendance/face_attendance_validator.dart';
import 'package:hr_app/services/face_attendance/ml_camera_input.dart';
class FaceCheckInScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  const FaceCheckInScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.locationAddress,
  });

  @override
  State<FaceCheckInScreen> createState() => _FaceCheckInScreenState();
}

class _FaceCheckInScreenState extends State<FaceCheckInScreen> {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
      minFaceSize: 0.14,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final _attendanceRepo = AttendanceHttpApiRepository();

  CameraController? _controller;
  CameraDescription? _cameraDesc;

  bool _initializing = true;
  bool _permissionDenied = false;
  bool _busy = false;
  bool _capturing = false;
  bool _completed = false;
  bool _faceValid = false;
  String _hint = 'Camera tayyar ho rahi hai… / Preparing camera…';
  DateTime? _lastRun;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  bool _looksLikeCameraPermissionDenied(CameraException e) {
    final c = e.code.toLowerCase();
    final d = (e.description ?? '').toLowerCase();
    return c.contains('permission') ||
        d.contains('permission') ||
        c.contains('denied') ||
        d.contains('denied') ||
        c.contains('unauthorized') ||
        d.contains('unauthorized');
  }

  Future<void> _bootstrap() async {
    if (kIsWeb) {
      setState(() {
        _initializing = false;
        _hint =
            'Face check-in sirf Android / iOS par / Face check-in is only on Android & iOS.';
      });
      return;
    }

    final cameras = await availableCameras();
    CameraDescription? picked;
    for (final c in cameras) {
      if (c.lensDirection == CameraLensDirection.front) {
        picked = c;
        break;
      }
    }
    picked ??= cameras.isNotEmpty ? cameras.first : null;
    if (picked == null) {
      setState(() {
        _initializing = false;
        _hint = 'Koi camera nahi mila / No camera found';
      });
      return;
    }

    _cameraDesc = picked;
    await _controller?.dispose();
    _controller = CameraController(
      picked,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _permissionDenied = _looksLikeCameraPermissionDenied(e);
        _hint = _permissionDenied
            ? 'Camera permission allow karein (system dialog) ya Settings se enable karein.\n'
                  'Allow camera permission from the system dialog, or enable it in Settings.'
            : 'Camera start nahi ho paya: ${e.description ?? e.code}';
      });
      await _controller?.dispose();
      _controller = null;
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hint = 'Camera start nahi ho paya: $e';
      });
      await _controller?.dispose();
      _controller = null;
      return;
    }

    if (!mounted) return;
    setState(() {
      _initializing = false;
      _permissionDenied = false;
      _hint =
          'Oval ke andar chehra rakhein, phir neeche Capture dabayein.\nKeep your face inside the oval, then tap Capture below.';
    });

    try {
      await _controller!.startImageStream(_onCameraImage);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hint = 'Preview stream error: $e';
      });
    }
  }

  Future<void> _retryAfterPermission() async {
    setState(() {
      _permissionDenied = false;
      _initializing = true;
      _hint = 'Camera tayyar ho rahi hai… / Preparing camera…';
    });
    await _bootstrap();
  }

  Future<Size> _readImageSizeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final sz = Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
    frame.image.dispose();
    return sz;
  }

  Future<void> _captureAndVerify() async {
    if (_completed || !mounted || _capturing) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _capturing = true;
      _faceValid = false;
      _hint = 'Photo capture ho rahi hai… / Capturing photo…';
    });

    String? capturedPath;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      final shot = await controller.takePicture();
      capturedPath = shot.path;
      final input = InputImage.fromFilePath(capturedPath);
      final faces = await _detector.processImage(input);

      final bytes = await File(capturedPath).readAsBytes();
      final imageSize = await _readImageSizeBytes(bytes);

      if (!mounted || _completed) return;

      if (faces.isEmpty) {
        setState(() {
          _hint = FaceCheckResult.noFace.message;
          _capturing = false;
        });
        await controller.startImageStream(_onCameraImage);
        return;
      }
      if (faces.length > 1) {
        setState(() {
          _hint = FaceCheckResult.multipleFaces.message;
          _capturing = false;
        });
        await controller.startImageStream(_onCameraImage);
        return;
      }

      final result = FaceAttendanceValidator.validate(faces.first, imageSize);
      if (!result.ok) {
        setState(() {
          _hint = result.message;
          _capturing = false;
        });
        await controller.startImageStream(_onCameraImage);
        return;
      }

      // Face validated — call check-in API
      setState(() => _hint = 'Check-in ho raha hai… / Checking in…');

      try {
        await _attendanceRepo.checkIn(
          faceImagePath: capturedPath,
          latitude: widget.latitude,
          longitude: widget.longitude,
          locationAddress: widget.locationAddress,
        );
        _completed = true;
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        setState(() {
          _hint =
              'Check-in failed: $e\nCapture se dobara try karein / Tap Capture to retry';
          _capturing = false;
        });
        await controller.startImageStream(_onCameraImage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hint = 'Capture error: $e';
          _capturing = false;
        });
      }
      try {
        if (controller.value.isInitialized &&
            !controller.value.isStreamingImages) {
          await controller.startImageStream(_onCameraImage);
        }
      } catch (_) {}
    }
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (!mounted || _completed || _capturing) return;
    if (_busy) return;
    final now = DateTime.now();
    if (_lastRun != null &&
        now.difference(_lastRun!) < const Duration(milliseconds: 420)) {
      return;
    }
    _lastRun = now;
    _busy = true;

    final controller = _controller;
    final cam = _cameraDesc;
    if (controller == null || !controller.value.isInitialized || cam == null) {
      _busy = false;
      return;
    }

    try {
      final input = mlInputImageFromCameraImage(image, controller, cam);
      if (input == null) {
        return;
      }

      final faces = await _detector.processImage(input);
      if (!mounted || _completed || _capturing) return;

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      if (faces.isEmpty) {
        setState(() {
          _faceValid = false;
          _hint =
              'Chehra camera ke saamne laayein / Bring your face in front of the camera\nPhir Capture dabayein / Then tap Capture';
        });
      } else if (faces.length > 1) {
        setState(() {
          _faceValid = false;
          _hint = FaceCheckResult.multipleFaces.message;
        });
      } else {
        final result = FaceAttendanceValidator.validate(faces.first, imageSize);
        setState(() {
          _faceValid = result.ok;
          _hint = result.ok
              ? 'Theek lag raha hai — ab Capture dabayein.\nLooks good — now tap Capture.'
              : '${result.message}\nPhir dubara try karein / Then adjust and try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hint = 'Detection error: $e';
        });
      }
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  Widget _buildCaptureBar() {
    if (_initializing ||
        _permissionDenied ||
        _controller == null ||
        !_controller!.value.isInitialized) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _capturing
                  ? 'Verifying…'
                  : _faceValid
                  ? 'Face verified — tap to capture'
                  : 'Bring your face inside the oval',
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: (!_capturing && _faceValid) ? _captureAndVerify : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _capturing
                        ? Colors.white24
                        : _faceValid
                        ? AppColors.dashboardClockInGreen
                        : Colors.white38,
                    width: 4,
                  ),
                  color: _capturing
                      ? Colors.white24
                      : _faceValid
                      ? AppColors.dashboardClockInGreen
                      : Colors.white10,
                ),
                child: _capturing
                    ? Padding(
                        padding: EdgeInsets.all(18.w),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _faceValid
                            ? Icons.camera_alt
                            : Icons.camera_alt_outlined,
                        color: _faceValid ? Colors.white : Colors.white38,
                        size: 32.sp,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Face Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildCaptureBar(),
    );
  }

  Widget _buildBody() {
    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            _hint,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ),
      );
    }

    if (_initializing) {
      return const AppShimmer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 280,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(140)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 160,
                height: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(4))),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_permissionDenied) {
      return Padding(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _hint,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Android: Settings -> Apps -> HR App -> Permissions -> Camera\n'
              'iOS: Settings -> Privacy -> Camera -> HR App',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _retryAfterPermission,
              child: const Text('Dobara try karein / Try again'),
            ),
          ],
        ),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _hint,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
              SizedBox(height: 20.h),
              FilledButton(
                onPressed: _retryAfterPermission,
                child: const Text('Dobara try karein / Try again'),
              ),
            ],
          ),
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
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: 8.h,
          ),
          child: Text(
            'Live preview sirf madad ke liye hai; asli check-in Neeche Capture button se hota hai.\nLive preview is a guide; check-in happens via the Capture button below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10.sp,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
