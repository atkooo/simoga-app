import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theming/colors.dart';

class BuildDivider {
  static Widget buildDivider() {
    return Expanded(
      child: Divider(
        thickness: 1.5.h,
        color: ColorsManager.gray,
      ),
    );
  }
}
