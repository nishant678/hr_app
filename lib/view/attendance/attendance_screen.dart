import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/app_app_bar.dart';
import 'package:hr_app/configs/components/design/spec_list_tile.dart';
import 'package:hr_app/configs/components/design/spec_segmented_control.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/model/attendance/attendance_model.dart';
import 'package:hr_app/repository/attendance_api/attendance_http_api_repository.dart';
import 'package:hr_app/view/face_checkin/face_check_in_screen.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _attendanceRepo = AttendanceHttpApiRepository();
  List<AttendanceModel> _records = [];
  bool _loading = true;
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _loading = true);
    try {
      final data = await _attendanceRepo.getMyAttendance();
      if (mounted) setState(() => _records = data);
    } catch (e) {
      debugPrint('Failed to load attendance: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleCheckIn() async {
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FaceCheckInScreen()),
    );
    if (verified == true) {
      _fetchRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in successful'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      await _attendanceRepo.checkOut();
      _fetchRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-out successful'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-out failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  AttendanceModel? get _todayRecord {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      return _records.firstWhere((r) => r.date == today);
    } catch (_) {
      return null;
    }
  }

  List<AttendanceModel> get _filteredRecords {
    if (_selectedSegment == 0) return _records;
    if (_selectedSegment == 1) return _records.where((r) => r.status == 'PRESENT' || r.status == 'LATE').toList();
    return _records.where((r) => r.status == 'ABSENT').toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return AppColors.success;
      case 'LATE':
        return AppColors.warning;
      case 'HALF_DAY':
        return Colors.orange;
      case 'ABSENT':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PRESENT':
        return 'Present';
      case 'LATE':
        return 'Late';
      case 'HALF_DAY':
        return 'Half Day';
      case 'ABSENT':
        return 'Absent';
      default:
        return status;
    }
  }

  IconData _typeIcon(String status) {
    switch (status) {
      case 'PRESENT':
        return Icons.check_circle_outline;
      case 'LATE':
        return Icons.access_time;
      case 'HALF_DAY':
        return Icons.wb_cloudy_outlined;
      case 'ABSENT':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayRecord;
    final isCheckedIn = today != null && today.checkInTime != null;
    final isCheckedOut = today != null && today.checkOutTime != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Attendance',
        showBackButton: Navigator.canPop(context),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRecords,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodayCard(today, isCheckedIn, isCheckedOut),
              SizedBox(height: AppDimensions.paddingL),
              SpecSegmentedControl(
                labels: const ['All', 'Present', 'Absent'],
                selectedIndex: _selectedSegment,
                onChanged: (i) => setState(() => _selectedSegment = i),
              ),
              SizedBox(height: AppDimensions.paddingL),
              Text('History', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: AppDimensions.paddingM),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_filteredRecords.isEmpty)
                _buildEmptyState()
              else
                ..._filteredRecords.map(_buildRecordCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard(AttendanceModel? today, bool isCheckedIn, bool isCheckedOut) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dashboardClockCardBlue,
            AppColors.dashboardClockCardBlue.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: SpecShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 8.h),
          if (isCheckedIn) ...[
            Text(
              'Check-in: ${today!.checkInTime}',
              style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            if (today.checkOutTime != null)
              Text(
                'Check-out: ${today.checkOutTime}',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _statusColor(today.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _statusLabel(today.status),
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 12.h),
            if (!isCheckedOut)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCheckOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dashboardClockInGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text('CHECK OUT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                ),
              ),
          ] else ...[
            Text('Not checked in yet', style: TextStyle(color: Colors.white60, fontSize: 15.sp)),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleCheckIn,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: Text('CHECK IN WITH FACE',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dashboardClockInGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.event_note_outlined, size: 48.sp, color: AppColors.textSecondary),
            SizedBox(height: AppDimensions.paddingM),
            Text('No records found', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(AttendanceModel record) {
    return SpecListTile(
      leading: _iconBubble(_typeIcon(record.status), _statusColor(record.status)),
      title: _formatDate(record.date),
      subtitle: record.checkInTime != null ? '${record.checkInTime} - ${record.checkOutTime ?? "—"}' : 'No check-in',
      trailingPrimary: record.hoursWorked != null ? '${record.hoursWorked!.toStringAsFixed(1)}h' : '—',
      trailingBadge: _statusLabel(record.status),
      badgeColor: _statusColor(record.status),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
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
