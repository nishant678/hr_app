import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hr_app/bloc/home_bloc/home_bloc.dart';
import 'package:hr_app/configs/color/color.dart';

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
      backgroundColor: AppColors.whiteColor,
      body: Container(
        color: AppColors.blackColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          "Welcome Refreshing Monday",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          "Great companies are built by great people.",
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 7.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Today's Overview",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Icon(Icons.more_horiz, color: Colors.black),
                                ],
                              ),
                            ),
                            SizedBox(height: 7.h),
                            _overviewCard(),
                            const SizedBox(height: 20),
                            BlocBuilder<HomeBloc, HomeStates>(
                              builder: (context, state) {
                                if (state.isLoading) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _statsGrid(state);
                              },
                            ),
                            const SizedBox(height: 20),
                            _todayList(),
                            const SizedBox(height: 20),
                            _timeTrack(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Wade Warren",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Human Resource Manager",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff1E1E1E),
            ),
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff7A5CFA), Color(0xff9F7BFF)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text("3 May, 2024", style: TextStyle(color: Colors.white70)),
                Spacer(),
                Text("8:45 AM", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _clockBox("Clock In", "08.00 AM"),
                const SizedBox(width: 12),
                _clockBox("Clock Out", "05.00 PM"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _clockBox(String title, String time) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(HomeStates state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 2,
        shrinkWrap: true,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _statTile(
            "Total Employee",
            state.totalEmployees.toString(),
            AppColors.iconBoxColor1,
            AppColors.color1,
            AppColors.lightBlackColor,
            AppColors.blackColor,
          ),
          _statTile(
            "Total Present",
            state.totalPresent.toString(),
            AppColors.iconBoxColor2,
            AppColors.color3,
            AppColors.lightBlackColor,
            AppColors.blackColor,
          ),
          _statTile(
            "Total Late",
            state.totalLate.toString(),
            AppColors.iconBoxColor3,
            AppColors.color2,
            AppColors.lightBlackColor,
            AppColors.blackColor,
          ),
          _statTile(
            "Total Leave",
            state.totalLeave.toString(),
            AppColors.iconBoxColor4,
            AppColors.color2,
            AppColors.lightBlackColor,
            AppColors.blackColor,
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    String title,
    String value,
    Color color,
    Color color1,
    Color lightBlackColor,
    Color blackColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(Icons.people, color: color),
              ),
              SizedBox(width: 7.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: lightBlackColor, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  Widget _todayList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Text(
                  "What’s up Today",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text("See All", style: TextStyle(color: Colors.deepPurple)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < 2; i++)
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: _todayItem(
                    "Motion Designer Interview",
                    "12:00 PM - 01:00 PM",
                    "more",
                  ),
                ),
                if (i < 1) Divider(thickness: 0.8),
              ],
            ),
        ],
      ),
    );
  }

  Widget _todayItem(String title, String time, String text3) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SizedBox(
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black)),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            text3 == "more"
                ? const Icon(Icons.more_horiz, color: Colors.grey)
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      text3,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _timeTrack() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Text(
                  "In-Time Tracking",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text("See All", style: TextStyle(color: Colors.deepPurple)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < 2; i++)
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: _todayItem(
                    "Brigette Whopper",
                    "Marketing Officer",
                    "07:48 AM",
                  ),
                ),
                if (i < 1) Divider(thickness: 0.8),
              ],
            ),
        ],
      ),
    );
  }
}
