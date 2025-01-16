import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../theming/colors.dart';
import '../../../theming/styles.dart';

class PasswordValidations extends StatelessWidget {
  final bool hasLowerCase;
  final bool hasUpperCase;
  final bool hasNumber;
  final bool hasMinLength;

  const PasswordValidations({
    super.key,
    required this.hasLowerCase,
    required this.hasUpperCase,
    required this.hasNumber,
    required this.hasMinLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildValidationRow('Minimal 1 huruf kecil', hasLowerCase),
        Gap(10.h),
        buildValidationRow('Minimal 1 huruf besar', hasUpperCase),
        Gap(10.h),
        buildValidationRow('Minimal 1 angka', hasNumber),
        Gap(10.h),
        buildValidationRow('Minimal 8 karakter', hasMinLength),
      ],
    );
  }

  Widget buildValidationRow(String text, bool hasValidated) {
    return Row(
      children: [
        Icon(
          hasValidated ? Icons.check_circle : Icons.cancel,
          size: 20.w,
          color: hasValidated ? Colors.green : Colors.red,
        ),
        Gap(8.w),
        Text(
          text,
          style: TextStyles.font14DarkBlue500Weight.copyWith(
            color: hasValidated ? ColorsManager.darkBlue : ColorsManager.gray,
          ),
        ),
      ],
    );
  }
}
