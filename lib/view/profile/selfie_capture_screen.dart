import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  CameraController? _controller;
  CameraDescription? _cameraDesc;
  bool _initializing = true;
  bool _permissionDenied = false;
  bool _capturing = false;
  String _hint = 'Camera tayyar ho rahi hai… / Preparing camera…';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
        _hint = 'Selfie sirf Android / iOS par / Selfie is only on Android & iOS.';
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
    );

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _permissionDenied = _looksLikeCameraPermissionDenied(e);
        _hint = _permissionDenied
            ? 'Camera permission allow karein / Allow camera permission in Settings.'
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
      _hint = 'Apna chehra frame me rakhein, phir neeche Capture dabayein.\n'
          'Frame your face and tap Capture below.';
    });
  }

  Future<void> _capture() async {
    if (_capturing || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final shot = await _controller!.takePicture();
      if (mounted) Navigator.of(context).pop(shot.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _capturing = false;
          _hint = 'Capture error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: const Text('Update Profile Photo'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildPreview(controller),
              ),
            ),
            Text(
              _hint,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: _buildCaptureButton(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(CameraController? controller) {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            _hint,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Text(
          _hint,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.white.withValues(alpha: 0.85),
          ),
        ),
      );
    }
    final mirror =
        _cameraDesc?.lensDirection == CameraLensDirection.front;
    return Transform.scale(
      scaleX: mirror ? -1 : 1,
      child: CameraPreview(controller),
    );
  }

  Widget _buildCaptureButton(CameraController? controller) {
    final ready = controller != null && controller.value.isInitialized;
    return Column(
      children: [
        if (ready) ...[
          FloatingActionButton.large(
            onPressed: _capturing ? null : _capture,
            backgroundColor: AppColors.white,
            foregroundColor: Colors.black,
            child: _capturing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.camera_alt),
          ),
        ],
        if (ready)
          SizedBox(height: AppDimensions.paddingM),
        if (ready)
          Text(
            'Capture',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.white),
          ),
      ],
    );
  }
}