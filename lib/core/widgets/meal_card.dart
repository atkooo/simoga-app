// lib/widgets/meal_card.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/meal.dart';
import '../../theming/colors.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({Key? key, required this.meal, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: _buildMealIcon(meal.time),
            title: Text(
              meal.description,
              style: TextStyle(fontSize: 16.sp, color: ColorsManager.darkBlue),
            ),
            subtitle: _buildMealDetails(meal),
            trailing: _buildAddButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildMealIcon(String time) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.restaurant, size: 24.sp, color: ColorsManager.mainBlue),
        SizedBox(height: 4.h),
        Text(time,
            style: TextStyle(fontSize: 16.sp, color: ColorsManager.gray)),
      ],
    );
  }

  Widget _buildMealDetails(Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kalori: ${meal.calories}',
            style: TextStyle(fontSize: 14.sp, color: ColorsManager.gray)),
        LinearProgressIndicator(
          value: meal.progress / meal.calories,
          backgroundColor: Colors.grey.shade200,
          color: Colors.green,
        ),
        Text('${meal.progress}/${meal.calories} kkal',
            style: TextStyle(fontSize: 12.sp, color: ColorsManager.gray)),
      ],
    );
  }

  Widget _buildAddButton() {
    return IconButton(
      icon: Icon(Icons.add, size: 24.sp, color: ColorsManager.mainBlue),
      onPressed: onTap,
    );
  }
}
