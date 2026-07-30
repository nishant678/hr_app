import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/model/user/user_profile_model.dart';
import 'package:hr_app/view/asset/asset_screen.dart';
import 'package:hr_app/view/attendance/attendance_screen.dart';
import 'package:hr_app/view/expense/expense_screen.dart';
import 'package:hr_app/view/leave/apply_leave_screen.dart';
import 'package:hr_app/view/salary_slip/salary_slip_screen.dart';
import 'package:hr_app/view/user_details/user_details_screen.dart';

class AppDrawer extends StatelessWidget {
  final UserProfileModel? profile;
  final VoidCallback? onLogout;

  const AppDrawer({super.key, this.profile, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _menuItem(
                  context,
                  Icons.dashboard_outlined,
                  'Dashboard',
                  () => Navigator.pop(context),
                ),
                _menuItem(context, Icons.person_outline, 'Profile', () {
                  if (profile == null) return;
                  Navigator.pop(context);
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailsScreen(profile: profile!),
                      ),
                    );
                  });
                }),
                _menuItem(
                  context,
                  Icons.check_circle_outline,
                  'Attendance',
                  () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceScreen(),
                        ),
                      );
                    });
                  },
                ),
                _menuItem(context, Icons.beach_access_outlined, 'Leave', () {
                  Navigator.pop(context);
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplyLeaveScreen(),
                      ),
                    );
                  });
                }),
                _menuItem(context, Icons.receipt_long_outlined, 'Expense', () {
                  Navigator.pop(context);
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExpenseScreen()),
                    );
                  });
                }),
                _menuItem(context, Icons.payments_outlined, 'Salary Slip', () {
                  Navigator.pop(context);
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SalarySlipScreen(),
                      ),
                    );
                  });
                }),
                _menuItem(context, Icons.inventory_2_outlined, 'Assets', () {
                  Navigator.pop(context);
                  Future.microtask(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AssetScreen()),
                    );
                  });
                }),
                _menuItem(
                  context,
                  Icons.task_alt_outlined,
                  'Tasks',
                  () => Navigator.pop(context),
                ),
                _menuItem(
                  context,
                  Icons.calendar_today_outlined,
                  'Calendar',
                  () => Navigator.pop(context),
                ),
                _menuItem(
                  context,
                  Icons.message_outlined,
                  'Messages',
                  () => Navigator.pop(context),
                ),
                _menuItem(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () => Navigator.pop(context),
                ),
                _menuItem(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingL,
              ),
              child: _menuItem(
                context,
                Icons.logout,
                'Logout',
                () {
                  Navigator.pop(context);
                  if (onLogout != null) {
                    Future.microtask(onLogout!);
                  }
                },
                color: AppColors.dashboardQuickExpenseCoral,
                boldText: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: 20.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.dashboardHeaderBlue, Color(0xFF1A3A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundImage:
                  profile != null &&
                      profile!.profilePhoto != null &&
                      profile!.profilePhoto!.isNotEmpty
                  ? NetworkImage(profile!.profilePhoto!)
                  : const AssetImage('assets/profile_icon.png')
                        as ImageProvider,
            ),
            SizedBox(width: AppDimensions.paddingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimensions.paddingS),
                Text(
                  profile?.fullName ?? 'User',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Flutter Developer',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
    bool boldText = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 24.sp),
      title: Text(
        label,
        style: AppTextStyles.labelM.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: boldText ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 4.w,
      contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
    );
  }
}
