import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/design/spec_list_tile.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/components/shimmer_loading.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/model/expense/expense_model.dart';
import 'package:hr_app/repository/expense_api/expense_http_api_repository.dart';
import 'package:hr_app/view/expense/apply_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _expenseRepo = ExpenseHttpApiRepository();
  List<ExpenseModel> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => _loading = true);
    try {
      final data = await _expenseRepo.getExpenses();
      if (mounted) setState(() => _expenses = data);
    } catch (e) {
      debugPrint('Failed to load expenses: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openApplyExpense() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ApplyExpenseScreen()),
    );
    if (result == true) _fetchExpenses();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'TRAVEL':
        return Icons.directions_car_outlined;
      case 'MEALS':
        return Icons.restaurant_outlined;
      case 'OFFICE_SUPPLIES':
        return Icons.inventory_2_outlined;
      case 'SOFTWARE':
        return Icons.computer_outlined;
      case 'EQUIPMENT':
        return Icons.build_outlined;
      case 'UTILITIES':
        return Icons.bolt_outlined;
      case 'TRANSPORT':
        return Icons.local_taxi_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _formatType(String type) {
    return type.split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
  }

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
            onPressed: _openApplyExpense,
          ),
        ],
      ),
      body: _loading
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AppShimmer(child: ListShimmer(itemCount: 5, withBadge: true)),
            )
          : _expenses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchExpenses,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _expenses.length + 1,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildSummaryCard();
                      final expense = _expenses[index - 1];
                      return _buildExpenseCard(expense);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64.sp, color: AppColors.textSecondary),
          SizedBox(height: AppDimensions.paddingL),
          Text('No expenses yet', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.paddingS),
          ElevatedButton.icon(
            onPressed: _openApplyExpense,
            icon: const Icon(Icons.add),
            label: const Text('Apply Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final total = _expenses.fold(0.0, (s, e) => s + e.amount);
    final pending = _expenses.where((e) => e.status == 'PENDING').fold(0.0, (s, e) => s + e.amount);
    final approved = _expenses.where((e) => e.status == 'APPROVED').fold(0.0, (s, e) => s + e.amount);
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
          _summaryRow('Total Expenses', '\$${total.toStringAsFixed(2)}', emphasize: true),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _summaryRow('Pending', '\$${pending.toStringAsFixed(2)}'),
          SizedBox(height: 10.h),
          _summaryRow('Approved', '\$${approved.toStringAsFixed(2)}'),
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

  Widget _buildExpenseCard(ExpenseModel expense) {
    return SpecListTile(
      leading: _iconBubble(_typeIcon(expense.expenseType), AppColors.primary),
      title: _formatType(expense.expenseType),
      subtitle: expense.description ?? expense.expenseDate,
      trailingPrimary: '\$${expense.amount.toStringAsFixed(2)}',
      trailingBadge: _statusLabel(expense.status),
      badgeColor: _statusColor(expense.status),
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
