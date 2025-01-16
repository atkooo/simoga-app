import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../model/child_nutrition.dart';
import '../../../theming/colors.dart';
import '../../../theming/styles.dart';
import 'package:intl/intl.dart';

class ChildNutritionScreen extends StatefulWidget {
  final ChildNutrition nutrition;
  final Function(ChildNutrition) onNutritionUpdated;
  final String childId;

  const ChildNutritionScreen({
    required this.nutrition,
    required this.onNutritionUpdated,
    required this.childId,
    super.key,
  });

  @override
  _ChildNutritionScreenState createState() => _ChildNutritionScreenState();
}

class _ChildNutritionScreenState extends State<ChildNutritionScreen> {
  late ChildNutrition _nutrition;

  @override
  void initState() {
    super.initState();
    _nutrition = widget.nutrition;
    _fetchNutritionData();
  }

  Future<void> _fetchNutritionData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .collection('mealHistory')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      double totalCalories = 0;
      double totalProtein = 0;
      double totalFat = 0;
      double totalCarbs = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalCalories += data['calories'] ?? 0;
        totalProtein += data['protein'] ?? 0;
        totalFat += data['fat'] ?? 0;
        totalCarbs += data['carbs'] ?? 0;
      }

      setState(() {
        _nutrition.caloriesProgress = totalCalories.round();
        _nutrition.proteinProgress = totalProtein.round();
        _nutrition.fatProgress = totalFat.round();
        _nutrition.carbsProgress = totalCarbs.round();
      });

      widget.onNutritionUpdated(_nutrition);
    } catch (e) {
      print('Error fetching nutrition data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nutrition.title,
          style: TextStyles.font24Blue700Weight,
        ),
        Text(
          formattedDate,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.normal,
              color: ColorsManager.darkBlue),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: ListView(
              children: [
                _buildNutritionDetail('Kalori', _nutrition.caloriesTarget,
                    _nutrition.caloriesProgress, Icons.local_fire_department),
                _buildNutritionDetail('Protein', _nutrition.proteinTarget,
                    _nutrition.proteinProgress, Icons.fitness_center),
                _buildNutritionDetail('Lemak', _nutrition.fatTarget,
                    _nutrition.fatProgress, Icons.fastfood),
                _buildNutritionDetail('Karbohidrat', _nutrition.carbsTarget,
                    _nutrition.carbsProgress, Icons.rice_bowl),
                _buildNutritionDetail('Serat', _nutrition.fiberTarget,
                    _nutrition.fiberProgress, Icons.grass),
                _buildWaterIntake(
                    _nutrition.waterTarget, _nutrition.waterProgress),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionDetail(
      String title, int target, int progress, IconData icon) {
    final int remaining = target - progress;
    final bool isFulfilled = remaining <= 0;
    final String statusText = isFulfilled ? 'Terpenuhi' : 'Kurang $remaining g';
    final Color statusColor = isFulfilled ? Colors.green : Colors.red;

    final double progressValue = target > 0 ? progress / target : 0;
    return Padding(
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: ColorsManager.darkBlue, size: 24.sp),
          title: Text(
            '$title: $progress/$target',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                color: ColorsManager.darkBlue),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                ),
                SizedBox(height: 4.h),
                Text(
                  statusText,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaterIntake(int target, int progress) {
    final int mlPerGlass = 200; // 1 gelas = 200 ml
    final double targetGlasses = target / mlPerGlass;
    final double progressGlasses = progress / mlPerGlass;

    final double remainingGlasses = targetGlasses - progressGlasses;
    final bool isFulfilled = remainingGlasses <= 0;

    final String statusText =
        isFulfilled ? 'Terpenuhi' : 'Kurang ${remainingGlasses.ceil()} gelas';
    final Color statusColor = isFulfilled ? Colors.green : Colors.red;

    final double progressValue = target > 0 ? progress / target : 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(Icons.local_drink,
              color: ColorsManager.darkBlue, size: 24.sp),
          title: Text(
            'Air: ${(progressGlasses).toStringAsFixed(1)}/${targetGlasses.toStringAsFixed(1)} gelas (${progress}/${target} ml)',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                color: ColorsManager.darkBlue),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                ),
                SizedBox(height: 4.h),
                Text(
                  statusText,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
