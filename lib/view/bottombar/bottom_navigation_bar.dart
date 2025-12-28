import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_app/bloc/home_bloc/home_bloc.dart';
import 'package:hr_app/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:hr_app/view/employee/employee_screen.dart';
import 'package:hr_app/view/home/home_screen.dart';
import 'package:hr_app/view/payroll/payroll_screen.dart';
import 'package:hr_app/view/profile/profile_screen.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  List<Widget> get widgetOptions => <Widget>[
    BlocProvider(create: (context) => HomeBloc(), child: const HomeScreen()),
    const PayrollScreen(),
    const EmployeeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: BlocBuilder<NavigationBloc, NavigationStates>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: widgetOptions[state.selectedIndex],
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Colors.deepPurple,
              onPressed: () {},
              child: const Icon(Icons.add, size: 32),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 10,
                color: Colors.white,
                child: SizedBox(
                  height: 65,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NavItem(icon: Icons.home, title: "Overview", index: 0),
                        _NavItem(
                          icon: Icons.search,
                          title: "Payroll",
                          index: 1,
                        ),
                        const SizedBox(width: 50),
                        _NavItem(
                          icon: Icons.notifications,
                          title: "Employees",
                          index: 2,
                        ),
                        _NavItem(
                          icon: Icons.person,
                          title: "Profile",
                          index: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationStates>(
      builder: (context, state) {
        final bool active = state.selectedIndex == index;
        return GestureDetector(
          onTap: () {
            context.read<NavigationBloc>().add(ChangeTabIndex(index: index));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active ? Colors.deepPurple : Colors.grey,
                size: 22,
              ),
              Text(
                title,
                style: TextStyle(
                  color: active ? Colors.deepPurple : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.42, 20);

    path.arcToPoint(
      Offset(size.width * 0.58, 20),
      radius: const Radius.circular(40),
      clockwise: false,
    );

    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
