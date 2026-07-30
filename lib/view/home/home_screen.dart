import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hr_app/bloc/home_bloc/home_bloc.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/components/shimmer_loading.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/model/attendance/attendance_model.dart';
import 'package:hr_app/repository/attendance_api/attendance_http_api_repository.dart';
import 'package:hr_app/services/location/address_service.dart';
import 'package:hr_app/view/attendance/attendance_screen.dart';
import 'package:hr_app/view/expense/expense_screen.dart';
import 'package:hr_app/view/face_checkin/face_check_in_screen.dart';
import 'package:hr_app/view/leave/apply_leave_screen.dart';
import 'package:hr_app/view/salary_slip/salary_slip_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const HomeScreen({super.key, this.onMenuTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _attendanceRepo = AttendanceHttpApiRepository();
  final _addressService = AddressService();

  AttendanceModel? _todayRecord;
  bool _loadingAttendance = true;
  String _currentAddress = '';
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());
    _fetchTodayAttendance();
  }

  Future<void> _fetchTodayAttendance() async {
    setState(() => _loadingAttendance = true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final records = await _attendanceRepo.getMyAttendance();
      final record = records.where((r) => r.date == today).toList();
      if (mounted) {
        setState(() {
          _todayRecord = record.isNotEmpty ? record.first : null;
          _loadingAttendance = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAttendance = false);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition();
      _currentLat = pos.latitude;
      _currentLng = pos.longitude;

      final addr = await _addressService.getAddressFromPosition(pos);
      if (mounted) {
        setState(() => _currentAddress = addr ?? '');
      }
    } catch (_) {}
  }

  Future<void> _handleCheckIn() async {
    await _fetchCurrentLocation();
    if (!mounted) return;

    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FaceCheckInScreen(
          latitude: _currentLat,
          longitude: _currentLng,
          locationAddress: _currentAddress.isNotEmpty ? _currentAddress : null,
        ),
      ),
    );

    if (verified == true) {
      _fetchTodayAttendance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      await _attendanceRepo.checkOut();
      _fetchTodayAttendance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-out failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? get _checkInTime => _todayRecord?.checkInTime;
  String? get _checkOutTime => _todayRecord?.checkOutTime;
  bool get _isCheckedIn => _checkInTime != null;
  bool get _isCheckedOut => _checkOutTime != null;

  String? get _formattedCheckIn => _formatTime(_checkInTime);
  String? get _formattedCheckOut => _formatTime(_checkOutTime);

  String? _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parsed = DateFormat('HH:mm:ss').parse(timeStr);
      return DateFormat('h:mm a').format(parsed).toLowerCase();
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClockInCard(),
                        SizedBox(height: AppDimensions.paddingXXL),
                        _buildQuickActions(),
                        SizedBox(height: AppDimensions.paddingXXL),
                        _buildFirstSummaryCard(),
                        SizedBox(height: AppDimensions.paddingL),
                        _buildSecondSummaryCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => widget.onMenuTap?.call(),
                child: Icon(Icons.menu, color: AppColors.primary, size: 28.sp),
              ),
              SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Book',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClockInCard() {
    final displayAddress =
        _todayRecord?.locationAddress != null &&
            _todayRecord!.locationAddress!.isNotEmpty
        ? _todayRecord!.locationAddress!
        : _currentAddress;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.dashboardClockCardBlue,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: SpecShadows.card,
      ),
      padding: EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _isCheckedIn ? 'Clock-In Today:' : 'Not checked in yet',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              if (_isCheckedIn)
                Text(
                  _formattedCheckIn ?? _checkInTime!,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          if (_isCheckedOut)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'Check-out: ${_formattedCheckOut ?? _checkOutTime}',
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
            ),
          if (displayAddress.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white60, size: 14.sp),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      displayAddress,
                      style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16.h),
          if (_loadingAttendance)
            const AppShimmer(child: SummaryCardShimmer())
          else if (_isCheckedOut)
            _buildAttendanceCompleteState()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _isCheckedIn ? _handleCheckOut : _handleCheckIn,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isCheckedIn
                          ? AppColors.dashboardQuickExpenseCoral
                          : AppColors.dashboardClockInGreen,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isCheckedIn ? Icons.logout : Icons.add,
                            size: 20.sp,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            _isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.sp,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _isCheckedIn ? 'Checked in' : 'On time',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: const Color(0xFF8FA8C4),
                        child: Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCompleteState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 20.sp, color: AppColors.white),
                SizedBox(width: 6.w),
                Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _isCheckedOut ? 'Done for today' : 'On time',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6.h),
              CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFF8FA8C4),
                child: Icon(Icons.person, color: AppColors.white, size: 20.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final cards = [
      _quickCardData(
        Icons.check,
        AppColors.dashboardClockInGreen.withValues(alpha: 0.18),
        AppColors.dashboardClockInGreen,
        'Attendance',
        const AttendanceScreen(),
      ),
      _quickCardData(
        Icons.folder_copy_outlined,
        AppColors.dashboardQuickLeaveOrange.withValues(alpha: 0.15),
        AppColors.dashboardQuickLeaveOrange,
        'Leave',
        const ApplyLeaveScreen(),
      ),
      _quickCardData(
        Icons.beach_access_outlined,
        AppColors.dashboardQuickExpenseCoral.withValues(alpha: 0.15),
        AppColors.dashboardQuickExpenseCoral,
        'Expense',
        const ExpenseScreen(),
      ),
      _quickCardData(
        Icons.receipt_long_outlined,
        AppColors.dashboardQuickExpenseCoral.withValues(alpha: 0.15),
        AppColors.dashboardQuickExpenseCoral,
        'Salary Slip',
        const SalarySlipScreen(),
      ),
    ];
    return Row(
      children: cards.map((c) => Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: _quickCard(
            circularIcon: true,
            icon: c.icon,
            iconBg: c.iconBg,
            iconColor: c.iconColor,
            label: c.label,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => c.screen),
            ),
          ),
        ),
      )).toList(),
    );
  }

  ({IconData icon, Color iconBg, Color iconColor, String label, Widget screen})
  _quickCardData(
    IconData icon,
    Color iconBg,
    Color iconColor,
    String label,
    Widget screen,
  ) {
    return (
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      label: label,
      screen: screen,
    );
  }

  Widget _quickCard({
    required bool circularIcon,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    VoidCallback? onTap,
  }) {
    final iconBox = Container(
      width: circularIcon ? 35.w : null,
      height: circularIcon ? 35.w : null,
      padding: circularIcon ? null : EdgeInsets.all(12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconBg,
        shape: circularIcon ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circularIcon ? null : BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: iconColor, size: circularIcon ? 20.sp : 20.sp),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: SpecShadows.card,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
            child: Column(
              children: [
                iconBox,
                SizedBox(height: 10.h),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstSummaryCard() {
    return _SummaryCardShell(
      trailingHeader: Icon(
        Icons.favorite_border,
        color: AppColors.textSecondary,
        size: 22.sp,
      ),
      children: [
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(Icons.login, AppColors.dashboardClockInGreen),
          title: 'Clock-In',
          trailing: _formattedCheckIn ?? _checkInTime ?? '--',
        ),
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(
            Icons.logout,
            AppColors.dashboardQuickExpenseCoral,
          ),
          title: 'Clock-Out',
          trailing: _formattedCheckOut ?? _checkOutTime ?? '--',
        ),
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(
            Icons.payments,
            AppColors.white,
            background: AppColors.dashboardClockCardBlue,
          ),
          title: 'Today\'s Hours',
          trailing: _todayRecord?.hoursWorked != null
              ? '${_todayRecord!.hoursWorked!.toStringAsFixed(1)}h'
              : '--',
        ),
      ],
    );
  }

  Widget _buildSecondSummaryCard() {
    final displayAddress =
        _todayRecord?.locationAddress != null &&
            _todayRecord!.locationAddress!.isNotEmpty
        ? _todayRecord!.locationAddress!
        : _currentAddress;
    return _SummaryCardShell(
      trailingHeader: const SizedBox.shrink(),
      children: [
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(
            Icons.assignment_outlined,
            AppColors.dashboardClockInGreen,
          ),
          title: displayAddress.isNotEmpty ? 'Location' : 'Today',
          trailing: displayAddress.isNotEmpty
              ? displayAddress.length > 25
                    ? '${displayAddress.substring(0, 25)}...'
                    : displayAddress
              : (_formattedCheckIn ?? _checkInTime ?? '--'),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.divider);
  }

  Widget _squareIcon(IconData icon, Color iconColor, {Color? background}) {
    final bg = background ?? iconColor.withValues(alpha: 0.15);
    return Container(
      width: 35.w,
      height: 35.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: iconColor, size: 20.sp),
    );
  }

  Widget _summaryRow({
    required Widget leading,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: 12.h,
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.labelM.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            trailing,
            style: AppTextStyles.labelS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardShell extends StatelessWidget {
  const _SummaryCardShell({
    required this.trailingHeader,
    required this.children,
  });

  final Widget trailingHeader;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: SpecShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.paddingM,
              14.h,
              AppDimensions.paddingM,
              10.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Summary",
                  style: AppTextStyles.labelL.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailingHeader,
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
