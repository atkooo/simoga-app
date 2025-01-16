// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import '../../theming/styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.font18BoldDarkBlue,
    );
  }
}
