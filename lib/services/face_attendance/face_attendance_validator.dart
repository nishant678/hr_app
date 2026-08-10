import 'dart:ui' show Size;

import 'package:face_detection_tflite/face_detection_tflite.dart';

class FaceCheckResult {
  const FaceCheckResult({required this.ok, required this.message});
  final bool ok;
  final String message;

  static const FaceCheckResult noFace = FaceCheckResult(
      ok: false, message: 'Chehra camera ke saamne laayein / Bring your face in front');
  static const FaceCheckResult multipleFaces = FaceCheckResult(
      ok: false, message: 'Sirf ek chehra hona chahiye / Only one face');
}

class FaceAttendanceValidator {
  FaceAttendanceValidator._();

  static const double _minFaceRatio = 0.06, _maxFaceRatio = 0.65;
  static const double _maxYaw = 24, _maxRoll = 20;
  static const double _minEyeOpen = 0.72;

  static bool looksLikeMaskCovered({
    required bool hasNoseLandmark,
    required bool hasMouthLandmark,
    required int contourScore,
  }) {
    return !hasNoseLandmark || !hasMouthLandmark || contourScore < 30;
  }

  static FaceCheckResult validate(Face face, Size imageSize) {
    final frameArea = imageSize.width * imageSize.height;
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    if (frameArea <= 0) return FaceCheckResult.noFace;

    final ratio = faceArea / frameArea;
    if (ratio < _minFaceRatio) {
      return const FaceCheckResult(ok: false, message: 'Thoda paas aayein / Move closer');
    }
    if (ratio > _maxFaceRatio) {
      return const FaceCheckResult(ok: false, message: 'Thoda door jaayein / Move back');
    }

    final y = face.headEulerAngleY;
    final z = face.headEulerAngleZ;
    if (y != null && y.abs() > _maxYaw) {
      return const FaceCheckResult(ok: false, message: 'Seedha dekhein / Look straight');
    }
    if (z != null && z.abs() > _maxRoll) {
      return const FaceCheckResult(ok: false, message: 'Sar seedha rakhein / Head straight');
    }

    final nose = face.landmarks.noseTip;
    final mouth = face.landmarks.mouth;
    int contourScore = 0;
    for (final t in [FaceContourType.face, FaceContourType.noseBottom, FaceContourType.upperLipBottom, FaceContourType.lowerLipTop]) {
      final c = face.getContour(t);
      if (c != null) contourScore += c.length;
    }

    if (looksLikeMaskCovered(hasNoseLandmark: nose != null, hasMouthLandmark: mouth != null, contourScore: contourScore)) {
      return const FaceCheckResult(ok: false, message: 'Chehra dhaka hua lag raha hai — mask / hath hataein / Face covered — remove mask');
    }

    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left != null && right != null && (left < _minEyeOpen || right < _minEyeOpen)) {
      return const FaceCheckResult(ok: false, message: 'Aankhein khuli rakhein / Keep eyes open');
    }

    return const FaceCheckResult(ok: true, message: 'Face verified');
  }
}
