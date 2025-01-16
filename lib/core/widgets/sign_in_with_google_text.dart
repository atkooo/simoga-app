import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../theming/styles.dart';
import '../../helpers/build_divider.dart';

class SigninWithGoogleText extends StatelessWidget {
  const SigninWithGoogleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BuildDivider.buildDivider(),
          Gap(8.w),
          Text(
            'atau',
            style: TextStyles.font13Grey400Weight,
          ),
          Gap(8.w),
          BuildDivider.buildDivider(),
        ],
      ),
    );
  }
}
