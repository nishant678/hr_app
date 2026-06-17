import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/app_button.dart';
import 'package:hr_app/configs/components/app_text_field.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';

class ApplyExpenseScreen extends StatefulWidget {
  const ApplyExpenseScreen({super.key});

  @override
  State<ApplyExpenseScreen> createState() => _ApplyExpenseScreenState();
}

class _ApplyExpenseScreenState extends State<ApplyExpenseScreen> {
  final _amountController = TextEditingController(text: r'$60.00');
  final _descriptionController = TextEditingController(text: 'Taxi fare for client visit');
  final _dateController = TextEditingController(text: 'Apr 25, 2024');
  String _category = 'Transport';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Apply Expense',
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
            AppTextField(
              controller: _dateController,
              label: 'Date',
              readOnly: true,
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            _buildCategoryDropdown(),
            SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              controller: _amountController,
              label: 'Amount',
              keyboardType: TextInputType.text,
              prefixIcon: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
              suffixIcon: Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            AppTextField(
              controller: _descriptionController,
              label: 'Notes',
              maxLines: 4,
            ),
            SizedBox(height: AppDimensions.paddingL),
            _buildAttachmentField(),
            SizedBox(height: AppDimensions.paddingXXXL),
            AppButton(
              title: 'SUBMIT EXPENSE',
              onPress: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
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
              value: _category,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 22.sp),
              items: const ['Transport', 'Meals', 'Stationery', 'Other']
                  .map(
                    (v) => DropdownMenuItem<String>(
                      value: v,
                      child: Text(v, style: AppTextStyles.bodyM),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
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
