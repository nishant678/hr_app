import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Result of ML Kit–based checks for attendance (single face, pose, eyes, no-mask heuristic).
class FaceCheckResult {
  const FaceCheckResult({required this.ok, required this.message});

  final bool ok;
  final String message;

  static const FaceCheckResult noFace = FaceCheckResult(
    ok: false,
    message:
        'Chehra camera ke saamne laayein / Bring your face in front of the camera',
  );

  static const FaceCheckResult multipleFaces = FaceCheckResult(
    ok: false,
    message: 'Sirf ek chehra hona chahiye / Only one face should be visible',
  );
}

class FaceAttendanceValidator {
  FaceAttendanceValidator._();

  @visibleForTesting
  static bool looksLikeMaskCovered({
    required bool hasNoseLandmark,
    required bool hasMouthLandmark,
    required int contourScore,
  }) {
    return !hasNoseLandmark || !hasMouthLandmark || contourScore < 32;
  }

  /// Validates [face] for check-in. Uses landmarks, classification, contours where available.
  static FaceCheckResult validate(Face face, Size imageSize) {
    final frameArea = imageSize.width * imageSize.height;
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    if (frameArea <= 0) return FaceCheckResult.noFace;

    final ratio = faceArea / frameArea;
    if (ratio < 0.06) {
      return const FaceCheckResult(
        ok: false,
        message: 'Thoda paas aayein / Move a bit closer to the camera',
      );
    }
    if (ratio > 0.72) {
      return const FaceCheckResult(
        ok: false,
        message: 'Thoda door ho jaayein / Move slightly back from the camera',
      );
    }

    final y = face.headEulerAngleY;
    final z = face.headEulerAngleZ;
    if (y != null && y.abs() > 24) {
      return const FaceCheckResult(
        ok: false,
        message: 'Seedha chehra dikhayein / Look straight at the camera',
      );
    }
    if (z != null && z.abs() > 20) {
      return const FaceCheckResult(
        ok: false,
        message: 'Sar seedha rakhein / Keep your head straight',
      );
    }

    final nose = face.landmarks[FaceLandmarkType.noseBase];
    final mouth =
        face.landmarks[FaceLandmarkType.bottomMouth] ??
        face.landmarks[FaceLandmarkType.leftMouth] ??
        face.landmarks[FaceLandmarkType.rightMouth];

    int contourScore = 0;
    void addContour(FaceContourType t) {
      final c = face.contours[t];
      if (c != null) contourScore += c.points.length;
    }

    addContour(FaceContourType.face);
    addContour(FaceContourType.noseBridge);
    addContour(FaceContourType.upperLipBottom);
    addContour(FaceContourType.lowerLipTop);

    if (looksLikeMaskCovered(
      hasNoseLandmark: nose != null,
      hasMouthLandmark: mouth != null,
      contourScore: contourScore,
    )) {
      return const FaceCheckResult(
        ok: false,
        message:
            'Chehra dhaka hua lag raha hai — mask / hath hataein / Face looks covered — remove mask or hand',
      );
    }

    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left != null && right != null) {
      if (left < 0.72 || right < 0.72) {
        return const FaceCheckResult(
          ok: false,
          message:
              'Dono aankhein khuli rakhein; mask / dhundhla chehra avoid karein / Keep both eyes open; avoid mask or blur',
        );
      }
    }

    return const FaceCheckResult(
      ok: true,
      message: 'Face verify ho gaya / Face verified',
    );
  }
}
