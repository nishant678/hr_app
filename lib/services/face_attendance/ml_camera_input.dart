import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Builds [InputImage] from a [CameraImage] for ML Kit (matches google_ml_kit example + multi-plane NV21 fallback).
InputImage? mlInputImageFromCameraImage(
  CameraImage image,
  CameraController controller,
  CameraDescription camera,
) {
  final rotation = _rotation(
    controller.value.deviceOrientation,
    camera.sensorOrientation,
    camera.lensDirection,
  );
  if (rotation == null) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null ||
      (Platform.isAndroid && format != InputImageFormat.nv21) ||
      (Platform.isIOS && format != InputImageFormat.bgra8888)) {
    return null;
  }

  final Uint8List bytes;
  final int bytesPerRow;
  if (image.planes.length == 1) {
    bytes = image.planes.first.bytes;
    bytesPerRow = image.planes.first.bytesPerRow;
  } else if (Platform.isAndroid) {
    bytes = _concatenatePlanes(image.planes);
    bytesPerRow = image.planes.first.bytesPerRow;
  } else {
    return null;
  }

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: bytesPerRow,
    ),
  );
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final plane in planes) {
    allBytes.putUint8List(plane.bytes);
  }
  return allBytes.done().buffer.asUint8List();
}

const Map<DeviceOrientation, int> _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImageRotation? _rotation(
  DeviceOrientation orientation,
  int sensorOrientation,
  CameraLensDirection lensDirection,
) {
  if (Platform.isIOS) {
    return InputImageRotationValue.fromRawValue(sensorOrientation);
  }
  if (Platform.isAndroid) {
    var rotationCompensation = _orientations[orientation];
    if (rotationCompensation == null) return null;
    if (lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  return null;
}
