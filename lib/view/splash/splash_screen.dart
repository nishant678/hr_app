import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/bloc/location_bloc/location_bloc.dart';
import 'package:hr_app/configs/theme/app_colors.dart';
import 'package:hr_app/view/bottombar/bottom_navigation_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _navigateToHome();
  }

  _requestLocationPermission() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(const RequestLocationPermission());
    });
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomBar()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.business_center,
                size: 60.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 30.h), 
            Text(
              'HR App',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Human Resource Management',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


