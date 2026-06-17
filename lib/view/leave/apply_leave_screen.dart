import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/app_button.dart';
import 'package:hr_app/configs/components/app_text_field.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _reasonController = TextEditingController(text: 'Doctor appointment');
  final _fromDateController = TextEditingController(text: 'Apr 25, 2024');
  final _toDateController = TextEditingController(text: 'Apr 25, 2024');
  final _fromTimeController = TextEditingController(text: '9:00 AM');
  String _leaveType = 'Half Day Leave';

  @override
  void dispose() {
    _reasonController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _fromTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Apply Leave',
        showBackButton: Navigator.canPop(context),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(),
            SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              controller: _fromDateController,
              label: 'From date',
              readOnly: true,
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              controller: _toDateController,
              label: 'To date',
              readOnly: true,
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              controller: _fromTimeController,
              label: 'From Time',
              readOnly: true,
              suffixIcon: Icon(
                Icons.schedule_outlined,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
              footer: Text(
                'Approved',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              controller: _reasonController,
              label: 'Reason',
              maxLines: 3,
              suffixIcon: Icon(
                Icons.work_outline,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            _buildAttachmentField(),
            SizedBox(height: AppDimensions.paddingXXXL),
            AppButton(
              title: 'SUBMIT REQUEST',
              onPress: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Type',
          style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _leaveType,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 22.sp),
              items: const [
                'Half Day Leave',
                'Full Day Leave',
                'Sick Leave',
                'Vacation',
              ]
                  .map(
                    (v) => DropdownMenuItem<String>(
                      value: v,
                      child: Text(v, style: AppTextStyles.bodyM),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _leaveType = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment',
          style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: 14.h,
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: AppColors.textSecondary, size: 22.sp),
                    SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Text(
                        'Add attachment',
                        style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 22.sp),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
