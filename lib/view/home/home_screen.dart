import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/bloc/home_bloc/home_bloc.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/view/attendance/attendance_screen.dart';
import 'package:hr_app/view/expense/expense_screen.dart';
import 'package:hr_app/view/face_checkin/face_check_in_screen.dart';
import 'package:hr_app/view/leave/apply_leave_screen.dart';

/// Home dashboard matched to **second** reference screenshot (colors, layout, icons, grouped summary cards).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.paddingL,
                AppDimensions.paddingL,
                AppDimensions.paddingL,
                AppDimensions.paddingXXL,
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        52.h,
        AppDimensions.paddingL,
        24.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.dashboardHeaderBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: const AssetImage('assets/profile_icon.png'),
          ),
          SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              'Welcome, Amit Sharma',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(
              Icons.interests_outlined,
              color: AppColors.white,
              size: 22.sp,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildClockInCard() {
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
                  'Clock-In Today:',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '9:15 AM',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final verified = await navigator.push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => const FaceCheckInScreen(),
                        ),
                      );
                      if (!mounted) return;
                      if (verified == true) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Face verify ho gaya — clock-in record kiya gaya / Face verified — clock-in recorded',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dashboardClockInGreen,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 22.sp, color: AppColors.white),
                        SizedBox(width: 6.w),
                        Text(
                          'CLOCK IN',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'On time',
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _quickCard(
            circularIcon: true,
            icon: Icons.check,
            iconBg: AppColors.dashboardClockInGreen.withValues(alpha: 0.18),
            iconColor: AppColors.dashboardClockInGreen,
            label: 'Attendance',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AttendanceScreen(),
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: _quickCard(
            circularIcon: false,
            icon: Icons.folder_copy_outlined,
            iconBg: AppColors.dashboardQuickLeaveOrange.withValues(alpha: 0.15),
            iconColor: AppColors.dashboardQuickLeaveOrange,
            label: 'Leave',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ApplyLeaveScreen(),
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: _quickCard(
            circularIcon: false,
            icon: Icons.beach_access_outlined,
            iconBg: AppColors.dashboardQuickExpenseCoral.withValues(alpha: 0.15),
            iconColor: AppColors.dashboardQuickExpenseCoral,
            label: 'Expense',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ExpenseScreen(),
              ),
            ),
          ),
        ),
      ],
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
      width: circularIcon ? 52.w : null,
      height: circularIcon ? 52.w : null,
      padding: circularIcon ? null : EdgeInsets.all(12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconBg,
        shape: circularIcon ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circularIcon ? null : BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: iconColor, size: circularIcon ? 26.sp : 26.sp),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: SpecShadows.card,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
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
          trailing: '9:15 AM',
        ),
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(
            Icons.arrow_downward,
            AppColors.dashboardQuickLeaveOrange,
          ),
          title: 'Half Day Leave',
          trailing: 'Mon',
        ),
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(
            Icons.payments,
            AppColors.white,
            background: AppColors.dashboardClockCardBlue,
          ),
          title: 'Travel Expense',
          trailing: '\$50.00',
        ),
      ],
    );
  }

  Widget _buildSecondSummaryCard() {
    return _SummaryCardShell(
      trailingHeader: const SizedBox.shrink(),
      children: [
        _summaryDivider(),
        _summaryRow(
          leading: _squareIcon(
            Icons.assignment_outlined,
            AppColors.dashboardClockInGreen,
          ),
          title: 'Today',
          trailing: '9:15 AM',
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.divider);
  }

  Widget _squareIcon(
    IconData icon,
    Color iconColor, {
    Color? background,
  }) {
    final bg = background ?? iconColor.withValues(alpha: 0.15);
    return Container(
      width: 40.w,
      height: 40.w,
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
              style: AppTextStyles.labelL.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            trailing,
            style: AppTextStyles.labelL.copyWith(
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
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
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
