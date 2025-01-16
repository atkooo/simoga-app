import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../routing/routes.dart';
import '../../theming/colors.dart';
import '../../theming/styles.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorsManager.mainBlue, ColorsManager.softBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 300.h,
                    ),
                  ),
                  FadeInLeft(
                    duration: const Duration(seconds: 2),
                    child: Text(
                      'SIMOGA',
                      style: TextStyles.font36Blue900Weight.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  FadeInRight(
                    duration: const Duration(seconds: 2),
                    child: Text(
                      'Monitoring anak hanya lewat genggaman',
                      style: TextStyles.font14SoftBlue600Weight.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                        shadows: [
                          const Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  FadeInUp(
                    duration: const Duration(seconds: 2),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.loginScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ColorsManager.mainBlue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 20.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: ColorsManager.mainBlue,
                      ),
                      label: Text(
                        'Mulai',
                        style: TextStyles.font16White600Weight.copyWith(
                          color: ColorsManager.mainBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
