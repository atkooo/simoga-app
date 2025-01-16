import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theming/styles.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Dengan login, Anda menyetujui ',
            style: TextStyles.font11MediumLightShadeOfGray400Weight,
          ),
          TextSpan(
            text: 'Syarat & Ketentuan ', // Sesuaikan jika istilah ini berbeda
            style: TextStyles.font11DarkBlue500Weight,
          ),
          TextSpan(
            text: 'dan ',
            style: TextStyles.font11MediumLightShadeOfGray400Weight
                .copyWith(height: 4.h),
          ),
          TextSpan(
            text: 'Kebijakan Privasi ', // Sesuaikan jika istilah ini berbeda
            style: TextStyles.font11DarkBlue500Weight,
          ),
          TextSpan(
            text: 'kami.',
            style: TextStyles.font11MediumLightShadeOfGray400Weight,
          ),
        ],
      ),
    );
  }
}
