import 'package:camera/camera.dart' show CameraDescription, CameraLensDirection;
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_litert/flutter_litert.dart' show CameraFrameRotation, rotationForFrame;

CameraFrameRotation? mlFaceFrameRotation({
  required int width,
  required int height,
  required CameraDescription camera,
  required DeviceOrientation deviceOrientation,
}) {
  try {
    return rotationForFrame(
      width: width,
      height: height,
      sensorOrientation: camera.sensorOrientation,
      isFrontCamera: camera.lensDirection == CameraLensDirection.front,
      deviceOrientation: deviceOrientation,
    );
  } catch (_) {
    return null;
  }
}
