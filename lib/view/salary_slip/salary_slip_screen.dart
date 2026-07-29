import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/model/salary_slip/salary_slip_model.dart';
import 'package:hr_app/repository/salary_slip_api/salary_slip_http_api_repository.dart';

class SalarySlipScreen extends StatefulWidget {
  const SalarySlipScreen({super.key});

  @override
  State<SalarySlipScreen> createState() => _SalarySlipScreenState();
}

class _SalarySlipScreenState extends State<SalarySlipScreen> {
  final _repo = SalarySlipHttpApiRepository();
  final _slipKey = GlobalKey();

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  SalarySlipModel? _slip;
  bool _loading = false;
  bool _busy = false;

  final _years = List.generate(5, (i) => DateTime.now().year - 2 + i);

  @override
  void initState() {
    super.initState();
    _fetchSlip();
  }

  Future<void> _fetchSlip() async {
    setState(() => _loading = true);
    try {
      final slip = await _repo.getPayslip(year: _selectedYear, month: _selectedMonth);
      if (mounted) setState(() => _slip = slip);
    } catch (_) {
      if (mounted) {
        setState(() => _slip = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No payslip found for this period')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _download() async {
    if (_slip == null) return;
    setState(() => _busy = true);
    try {
      final boundary = _slipKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/Salary_Slip_${_slip!.monthName}_${_slip!.year}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_slip == null) return;
    setState(() => _busy = true);
    try {
      final boundary = _slipKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/Salary_Slip_${_slip!.monthName}_${_slip!.year}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)], text: 'Salary Slip');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Salary Slip'),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _slip == null
                    ? Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15.sp,
                          ),
                        ),
                      )
                    : _buildSlipContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _dropdown(
              value: _selectedYear,
              items: _years.map((y) => DropdownMenuItem(
                value: y,
                child: Text(y.toString()),
              )).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedYear = v);
                _fetchSlip();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _dropdown(
              value: _selectedMonth,
              items: List.generate(12, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(DateFormat.MMMM().format(DateTime(2000, i + 1))),
              )).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedMonth = v);
                _fetchSlip();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildSlipContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: RepaintBoundary(
        key: _slipKey,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildSection('Employee Details', [
                _row('Name', _slip!.employeeName),
                _row('Employee ID', _slip!.employeeId),
                _row('Designation', _slip!.designation),
                _row('Department', _slip!.department),
                _row('PAN', _slip!.panNumber),
                _row('UAN', _slip!.uanNumber),
              ]),
              SizedBox(height: 12.h),
              _buildSection('Earnings', [
                _row('Basic Salary', '₹ ${_fmt(_slip!.basicSalary)}'),
                _row('HRA', '₹ ${_fmt(_slip!.hra)}'),
                _row('Conveyance', '₹ ${_fmt(_slip!.conveyance)}'),
                _row('Medical', '₹ ${_fmt(_slip!.medical)}'),
                _row('Special Allowance', '₹ ${_fmt(_slip!.specialAllowance)}'),
                const Divider(height: 20),
                _row('Gross Earnings', '₹ ${_fmt(_slip!.grossEarnings)}',
                    bold: true),
              ]),
              SizedBox(height: 12.h),
              _buildSection('Deductions', [
                _row('PF', '₹ ${_fmt(_slip!.pf)}'),
                _row('ESI', '₹ ${_fmt(_slip!.esi)}'),
                _row('Professional Tax', '₹ ${_fmt(_slip!.professionalTax)}'),
                _row('TDS', '₹ ${_fmt(_slip!.tds)}'),
                const Divider(height: 20),
                _row('Total Deductions', '₹ ${_fmt(_slip!.totalDeductions)}',
                    bold: true),
              ]),
              SizedBox(height: 12.h),
              _buildNetPay(),
              SizedBox(height: 16.h),
              _buildBankDetails(),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  _slip!.netPayInWords,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      'Download',
                      Icons.download,
                      _busy,
                      _download,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _actionButton(
                      'Share',
                      Icons.share,
                      _busy,
                      _share,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.receipt_long, size: 40.r, color: AppColors.primary),
        SizedBox(height: 4.h),
        Text(
          'SALARY SLIP',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '${_slip!.monthName} ${_slip!.year}',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 6.h),
        ...rows,
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetPay() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            'Net Pay',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            '₹ ${_fmt(_slip!.netPay)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetails() {
    return _buildSection('Bank Details', [
      _row('Bank Name', _slip!.bankName),
      _row('Account No', _slip!.bankAccountNumber),
      _row('IFSC Code', _slip!.ifscCode),
    ]);
  }

  Widget _actionButton(
    String label,
    IconData icon,
    bool busy,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 40.h,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onTap,
        icon: busy
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 18.r),
        label: Text(label),
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2);
}
