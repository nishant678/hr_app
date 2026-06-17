import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/design/spec_list_tile.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/view/expense/apply_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final String _selectedMonth = 'This Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Expenses',
        showBackButton: Navigator.canPop(context),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary, size: 24.sp),
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const ApplyExpenseScreen(),
                ),
              );
            },
          ),
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
            _buildMonthFilter(),
            SizedBox(height: AppDimensions.paddingL),
            _buildSummaryCard(),
            SizedBox(height: AppDimensions.paddingXXL),
            Text(
              'Expense Reports',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppDimensions.paddingM),
            _buildExpenseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthFilter() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: SpecShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedMonth,
            style: AppTextStyles.labelL.copyWith(fontWeight: FontWeight.w600),
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 22.sp),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
          _summaryRow('Total Expenses', '\$210.00', emphasize: true),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _summaryRow('Pending', '\$2,250.00'),
          SizedBox(height: 10.h),
          _summaryRow('Approved', '\$150.00'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String amount, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasize
              ? AppTextStyles.labelL.copyWith(fontWeight: FontWeight.w600)
              : AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          amount,
          style: emphasize
              ? AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.labelL.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    return Column(
      children: [
        SpecListTile(
          leading: _iconBubble(Icons.directions_car_outlined, AppColors.primary),
          title: 'Travel Expense',
          subtitle: 'Transport',
          trailingPrimary: '\$50.00',
          trailingBadge: 'Pending',
          badgeColor: AppColors.warning,
        ),
        SpecListTile(
          leading: _iconBubble(Icons.restaurant_outlined, AppColors.leaveAccent),
          title: 'Client Meeting',
          subtitle: 'Meals',
          trailingPrimary: '\$35.00',
          trailingBadge: 'Pending',
          badgeColor: AppColors.warning,
        ),
        SpecListTile(
          leading: _iconBubble(Icons.inventory_2_outlined, AppColors.success),
          title: 'Office Supplies',
          subtitle: 'Stationery',
          trailingPrimary: '\$125.00',
          trailingBadge: 'Pending',
          badgeColor: AppColors.warning,
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
