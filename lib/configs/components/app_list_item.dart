import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class AppListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailingText;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? trailingColor;

  const AppListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.leading,
    this.trailing,
    this.onTap,
    this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: AppDimensions.paddingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelL,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: AppTextStyles.labelL.copyWith(
                  color: trailingColor ?? AppColors.textPrimary,
                ),
              ),
            if (trailing != null) ...[
              SizedBox(width: AppDimensions.paddingS),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
