import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/configs/components/design/spec_shadows.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/configs/theme/app_dimensions.dart';
import 'package:hr_app/configs/theme/app_text_styles.dart';
import 'package:hr_app/view/attendance/attendance_screen.dart';
import 'package:hr_app/view/expense/expense_screen.dart';
import 'package:hr_app/view/home/home_screen.dart';
import 'package:hr_app/view/leave/apply_leave_screen.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    AttendanceScreen(),
    ApplyLeaveScreen(),
    ExpenseScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: SpecShadows.bottomBar,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: 10.h,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _NavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 0,
                    active: _selectedIndex == 0,
                    onTap: _onItemTapped,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month,
                    title: 'Attendance',
                    index: 1,
                    active: _selectedIndex == 1,
                    onTap: _onItemTapped,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.event_note_outlined,
                    activeIcon: Icons.event_note,
                    title: 'Leave',
                    index: 2,
                    active: _selectedIndex == 2,
                    onTap: _onItemTapped,
                    badgeCount: 2,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    title: 'Expenses',
                    index: 3,
                    active: _selectedIndex == 3,
                    onTap: _onItemTapped,
                    badgeCount: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.index,
    required this.active,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final IconData activeIcon;
  final String title;
  final int index;
  final bool active;
  final ValueChanged<int> onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  active ? activeIcon : icon,
                  color: color,
                  size: 24.sp,
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -6.w,
                    top: -4.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.navBadge,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount! > 9 ? '9+' : '$badgeCount',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelS.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
