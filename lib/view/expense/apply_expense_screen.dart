import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/app_button.dart';
import 'package:hr_app/configs/components/app_text_field.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/repository/expense_api/expense_http_api_repository.dart';
import 'package:intl/intl.dart';

class ApplyExpenseScreen extends StatefulWidget {
  const ApplyExpenseScreen({super.key});

  @override
  State<ApplyExpenseScreen> createState() => _ApplyExpenseScreenState();
}

class _ApplyExpenseScreenState extends State<ApplyExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _expenseDate;
  String _expenseType = 'TRAVEL';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  PlatformFile? _selectedFile;
  final _expenseRepository = ExpenseHttpApiRepository();

  final List<String> _expenseTypes = [
    'TRAVEL',
    'MEALS',
    'OFFICE_SUPPLIES',
    'UTILITIES',
    'SOFTWARE',
    'EQUIPMENT',
    'TRANSPORT',
    'OTHER',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) {
      _expenseDate = picked;
      _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      setState(() {});
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expenseDate == null) {
      _showSnackbar('Please select the expense date');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnackbar('Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'expenseType': _expenseType,
        'amount': amount,
        'expenseDate': _formatDate(_expenseDate),
      };
      if (_descriptionController.text.trim().isNotEmpty) {
        data['description'] = _descriptionController.text.trim();
      }

      final expense = await _expenseRepository.applyExpense(data);

      if (_selectedFile != null && _selectedFile!.path != null) {
        await _uploadAttachment(expense.id);
      }

      if (!context.mounted) return;
      _showSnackbar('Expense submitted successfully', isError: false);
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackbar('Failed to submit expense: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAttachment(int expenseId) async {
    final file = _selectedFile!;
    try {
      await _expenseRepository.uploadAttachment(expenseId, file.path!);
    } catch (e) {
      debugPrint('Attachment upload failed: $e');
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Apply Expense',
        showBackButton: Navigator.canPop(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        child: SafeArea(
          bottom: true,
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(),
                SizedBox(height: AppDimensions.paddingL),
                AppTextField(
                  controller: _dateController,
                  label: 'Date',
                  readOnly: true,
                  onTap: _pickDate,
                  suffixIcon: Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                AppTextField(
                  controller: _amountController,
                  label: 'Amount',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.textSecondary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                ),
                SizedBox(height: AppDimensions.paddingL),
                _buildAttachmentField(),
                SizedBox(height: AppDimensions.paddingXXXL),
                AppButton(
                  title: 'SUBMIT EXPENSE',
                  onPress: _submitExpense,
                  loading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Type',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _expenseType,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 22.sp),
              items: _expenseTypes
                  .map(
                    (v) => DropdownMenuItem<String>(
                      value: v,
                      child: Text(v.split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' '),
                          style: TextStyle(fontSize: 14.sp)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _expenseType = v);
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
          'Attachment (optional)',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12.r),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 14.h),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: AppColors.textSecondary, size: 22.sp),
                    SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Text(
                        _selectedFile?.name ?? 'Add attachment',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _selectedFile != null ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_selectedFile != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedFile = null),
                        child: Icon(Icons.close, color: AppColors.error, size: 20.sp),
                      )
                    else
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
