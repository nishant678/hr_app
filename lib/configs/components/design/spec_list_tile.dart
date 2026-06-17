import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';

/// White rounded list row matching reference cards (12px radius, soft shadow).
class SpecListTile extends StatelessWidget {
  const SpecListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.statusLabel,
    this.statusColor,
    this.trailingPrimary,
    this.trailingBadge,
    this.badgeColor,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final String? statusLabel;
  final Color? statusColor;
  final String? trailingPrimary;
  final String? trailingBadge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: SpecShadows.card,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingM,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leading,
                  SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.labelL.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (statusLabel != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            statusLabel!,
                            style: AppTextStyles.bodyS.copyWith(
                              color: statusColor ?? AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (subtitle != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailingPrimary != null && trailingPrimary!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: trailingBadge != null ? 8.w : 0),
                      child: Text(
                        trailingPrimary!,
                        style: AppTextStyles.labelL.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  if (trailingBadge != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? AppColors.warning).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        trailingBadge!,
                        style: AppTextStyles.labelS.copyWith(
                          color: badgeColor ?? AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
