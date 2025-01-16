import 'package:flutter/material.dart';
import 'colors.dart';
import 'styles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: ColorsManager.mainBlue,
    scaffoldBackgroundColor: ColorsManager.lightShadeOfGray,
    colorScheme: const ColorScheme.light(
      primary: ColorsManager.mainBlue,
      secondary: ColorsManager.coralRed,
      surface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyles.font24Blue700Weight,
      bodyLarge: TextStyles.font14Grey400Weight,
      bodyMedium: TextStyles.font13Grey400Weight,
      labelLarge: TextStyles.font16White600Weight,
      bodySmall: TextStyles.font11MediumLightShadeOfGray400Weight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsManager.mainBlue,
      titleTextStyle: TextStyles.font16White600Weight,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: ColorsManager.mainBlue,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: ColorsManager.mainBlue,
        textStyle: TextStyles.font14White600Weight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: ColorsManager.gray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: ColorsManager.mainBlue),
      ),
    ),
  );
}
