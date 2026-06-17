import 'package:flutter/material.dart';
import 'package:hr_app/configs/theme/app_colors.dart';

/// Card / bar shadows tuned to match reference (soft, low elevation).
class SpecShadows {
  SpecShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> bottomBar = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, -4),
    ),
  ];
}
