import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hr_app/bloc/home_bloc/home_bloc.dart';
import 'package:hr_app/bloc/location_bloc/location_bloc.dart';
import 'package:hr_app/bloc/login_bloc/login_bloc.dart';
import 'package:hr_app/configs/theme/app_theme.dart';
import 'package:hr_app/core/app_runtime.dart';
import 'package:hr_app/controllers/location_controller.dart';
import 'package:hr_app/repository/auth_api/auth_http_api_repository.dart';
import 'package:hr_app/repositories/location_repository.dart';
import 'package:hr_app/services/location/location_permission_service.dart';
import 'package:hr_app/services/location/location_storage_service.dart';
import 'package:hr_app/services/location/location_sync_service.dart';
import 'package:hr_app/services/background/workmanager_service.dart';
import 'package:hr_app/services/location/location_tracking_service.dart';
import 'package:hr_app/view/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppRuntime();

  final sharedStorageService = LocationStorageService();
  final sharedRepository = LocationRepository();
  final sharedSyncService = LocationSyncService(
    repository: sharedRepository,
    storageService: sharedStorageService,
  );
  final trackingService = LocationTrackingService(
    permissionService: LocationPermissionService(),
    storageService: sharedStorageService,
    syncService: sharedSyncService,
  );

  Get.put(LocationController(
    permissionService: LocationPermissionService(),
    storageService: sharedStorageService,
    syncService: sharedSyncService,
    trackingService: trackingService,
  ));

  await WorkmanagerService.initialize();
  await WorkmanagerService.registerPeriodicSync();
  await trackingService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => LocationBloc()),
        BlocProvider(
          create: (context) =>
              LoginBloc(authApiRepository: AuthHttpApiRepository()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
            title: 'HR App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
