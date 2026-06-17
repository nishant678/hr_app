import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/design/spec_list_tile.dart';
import 'package:hr_app/configs/components/design/spec_segmented_control.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Attendance',
        showBackButton: Navigator.canPop(context),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpecSegmentedControl(
                labels: const ['All', 'Pending', 'Completed'],
                selectedIndex: _segmentIndex,
                onChanged: (i) => setState(() => _segmentIndex = i),
              ),
              SizedBox(height: AppDimensions.paddingXXL),
              _buildCalendar(),
              SizedBox(height: AppDimensions.paddingXXL),
              Text(
                'Attendance History',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: AppDimensions.paddingM),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: SpecShadows.card,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chevron_left, size: 26.sp, color: AppColors.textPrimary),
                onPressed: () {},
              ),
              Text(
                'April 2024',
                style: AppTextStyles.labelL.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chevron_right, size: 26.sp, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: AppDimensions.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => SizedBox(
                    width: 32.w,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelS.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: AppDimensions.paddingM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 6.w,
              childAspectRatio: 1,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isToday = day == 15;
              final isOrange = day == 10 || day == 22;
              final isGreen = day <= 25 && day != 10 && day != 15 && day != 22;

              Color? bg;
              Color fg = AppColors.textPrimary;
              if (isToday) {
                bg = AppColors.primary;
                fg = AppColors.white;
              } else if (isOrange) {
                bg = AppColors.warning;
                fg = AppColors.white;
              } else if (isGreen) {
                bg = AppColors.success;
                fg = AppColors.white;
              }

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$day',
                  style: AppTextStyles.labelM.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        SpecListTile(
          leading: _iconBubble(Icons.check_circle_outline, AppColors.success),
          title: 'Today',
          subtitle: 'Tue, 12 May 2024',
          trailingPrimary: '9:15 AM',
        ),
        SpecListTile(
          leading: _iconBubble(Icons.event_note_outlined, AppColors.warning),
          title: 'Half Day Leave',
          statusLabel: 'Approved',
          statusColor: AppColors.success,
          subtitle: 'Tue, 12 May 2024',
          trailingPrimary: '9:00 AM',
        ),
        SpecListTile(
          leading: _iconBubble(Icons.directions_car_outlined, AppColors.primary),
          title: 'Travel Expense',
          subtitle: 'Transport',
          trailingPrimary: '\$50.00',
        ),
      ],
    );
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}
