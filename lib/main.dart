import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/bottom_nav_provider.dart.dart';
import 'routing/app_router.dart';
import 'firebase_options.dart';
import 'theming/theme.dart';
import 'providers/expandable_button_provider.dart';
import 'providers/model_service_provider.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'auth_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ScreenUtil.ensureScreenSize();
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpandableButtonProvider()),
        ChangeNotifierProvider(create: (_) => ModelServiceProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ],
      child: MyApp(
        router: AppRouter(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return OverlaySupport(
          child: MaterialApp(
            title: 'SiMOGA',
            theme: AppTheme.lightTheme,
            onGenerateRoute: router.generateRoute,
            debugShowCheckedModeBanner: false,
            home: SplashScreenWrapper(router: router),
          ),
        );
      },
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  final AppRouter router;

  const SplashScreenWrapper({super.key, required this.router});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToAuthCheck();
  }

  void _navigateToAuthCheck() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthCheck(router: widget.router),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
