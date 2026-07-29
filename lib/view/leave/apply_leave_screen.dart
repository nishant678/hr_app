import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/app_button.dart';
import 'package:hr_app/configs/components/app_text_field.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/repository/leave_api/leave_http_api_repository.dart';
import 'package:intl/intl.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _reasonController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _fromTimeController = TextEditingController();
  final _toTimeController = TextEditingController();

  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  String _leaveType = 'SICK';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  PlatformFile? _selectedFile;
  final _leaveRepository = LeaveHttpApiRepository();

  final List<String> _leaveTypes = [
    'SICK',
    'CASUAL',
    'ANNUAL',
    'PERSONAL',
    'MATERNITY',
    'PATERNITY',
    'OTHER',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _fromDate = picked;
      _fromDateController.text = DateFormat('MMM dd, yyyy').format(picked);
      if (_toDate != null && _toDate!.isBefore(picked)) {
        _toDate = null;
        _toDateController.clear();
      }
      setState(() {});
    }
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final first = _fromDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _toDate = picked;
      _toDateController.text = DateFormat('MMM dd, yyyy').format(picked);
      setState(() {});
    }
  }

  Future<void> _pickFromTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _fromTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _fromTime = picked;
      _fromTimeController.text = picked.format(context);
      setState(() {});
    }
  }

  Future<void> _pickToTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _toTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _toTime = picked;
      _toTimeController.text = picked.format(context);
      setState(() {});
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'pdf',
        'doc',
        'docx',
        'mp4',
        'avi',
        'mov',
      ],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromDate == null) {
      _showSnackbar('Please select from date');
      return;
    }
    if (_toDate == null) {
      _showSnackbar('Please select to date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'leaveType': _leaveType,
        'fromDate': _formatDate(_fromDate),
        'toDate': _formatDate(_toDate),
      };
      if (_fromTime != null) data['fromTime'] = _formatTime(_fromTime);
      if (_toTime != null) data['toTime'] = _formatTime(_toTime);
      if (_reasonController.text.trim().isNotEmpty) {
        data['reason'] = _reasonController.text.trim();
      }

      final leave = await _leaveRepository.applyLeave(data);

      if (_selectedFile != null && _selectedFile!.path != null) {
        await _uploadAttachment(leave.id);
      }

      if (!context.mounted) return;
      _showSnackbar('Leave applied successfully', isError: false);
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackbar('Failed to apply leave: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAttachment(int leaveId) async {
    final file = _selectedFile!;
    try {
      await _leaveRepository.uploadAttachment(leaveId, file.path!);
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
        title: 'Apply Leave',
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
                  controller: _fromDateController,
                  label: 'From date',
                  readOnly: true,
                  onTap: _pickFromDate,
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
                  onTap: _pickToDate,
                  suffixIcon: Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                AppTextField(
                  controller: _fromTimeController,
                  label: 'From Time (optional)',
                  readOnly: true,
                  onTap: _pickFromTime,
                  suffixIcon: Icon(
                    Icons.schedule_outlined,
                    color: AppColors.textSecondary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                AppTextField(
                  controller: _toTimeController,
                  label: 'To Time (optional)',
                  readOnly: true,
                  onTap: _pickToTime,
                  suffixIcon: Icon(
                    Icons.schedule_outlined,
                    color: AppColors.textSecondary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                AppTextField(
                  controller: _reasonController,
                  label: 'Reason (optional)',
                  maxLines: 3,
                  suffixIcon: Icon(
                    Icons.work_outlined,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                _buildAttachmentField(),
                SizedBox(height: AppDimensions.paddingXXXL),
                AppButton(
                  title: 'SUBMIT REQUEST',
                  onPress: () => _submitLeave(),
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
          'Leave Type',
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
              value: _leaveType,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
              items: _leaveTypes
                  .map(
                    (v) => DropdownMenuItem<String>(
                      value: v,
                      child: Text(v, style: TextStyle(fontSize: 14.sp)),
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
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: 14.h,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Text(
                        _selectedFile?.name ?? 'Add attachment',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _selectedFile != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_selectedFile != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedFile = null),
                        child: Icon(
                          Icons.close,
                          color: AppColors.error,
                          size: 20.sp,
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
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
