import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/date_dropdown.dart';
import '../../../theming/colors.dart';
import '../../../theming/styles.dart';
import '../../../core/widgets/meal_card.dart';
import '../../../model/meal.dart';
import '../../../routing/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealScreen extends StatefulWidget {
  final String childId;

  const MealScreen({Key? key, required this.childId}) : super(key: key);

  @override
  _MealScreenState createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<Meal> meals = [];
  bool isLoading = true;
  int waterConsumed = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMealData();
  }

  @override
  void didUpdateWidget(covariant MealScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.childId != oldWidget.childId) {
      _fetchMealData();
    }
  }

  Future<void> _fetchMealData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .get();

      final totalCalories =
          (docSnapshot.data()?['akg']['caloriesHarris'] as num?)?.toDouble() ??
              0.0;
      final water = (docSnapshot.data()?['akg']['water'] as num?)?.toInt() ?? 0;

      final startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final mealHistorySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .collection('mealHistory')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      final mealHistory =
          mealHistorySnapshot.docs.map((doc) => doc.data()).toList();
      print('Meal History: $mealHistory');

      final Map<String, double> caloriesProgress = {
        'Sarapan': 0.0,
        'Snack Pagi': 0.0,
        'Makan Siang': 0.0,
        'Snack Sore': 0.0,
        'Makan Malam': 0.0,
      };

      for (var meal in mealHistory) {
        final timestamp = (meal['timestamp'] as Timestamp).toDate();
        final hour = timestamp.hour;

        if (hour >= 5 && hour < 10) {
          caloriesProgress['Sarapan'] = (caloriesProgress['Sarapan'] ?? 0) +
              (meal['calories'] as num).toDouble();
        } else if (hour >= 10 && hour < 12) {
          caloriesProgress['Snack Pagi'] =
              (caloriesProgress['Snack Pagi'] ?? 0) +
                  (meal['calories'] as num).toDouble();
        } else if (hour >= 12 && hour < 15) {
          caloriesProgress['Makan Siang'] =
              (caloriesProgress['Makan Siang'] ?? 0) +
                  (meal['calories'] as num).toDouble();
        } else if (hour >= 15 && hour < 18) {
          caloriesProgress['Snack Sore'] =
              (caloriesProgress['Snack Sore'] ?? 0) +
                  (meal['calories'] as num).toDouble();
        } else if (hour >= 18 && hour < 22) {
          caloriesProgress['Makan Malam'] =
              (caloriesProgress['Makan Malam'] ?? 0) +
                  (meal['calories'] as num).toDouble();
        }
      }

      print('Calories Progress: $caloriesProgress');

      setState(() {
        meals = [
          Meal(
              time: '07:00',
              description: 'Sarapan',
              calories: (totalCalories * 0.25).round(),
              progress: caloriesProgress['Sarapan']?.toInt() ?? 0),
          Meal(
              time: '10:00',
              description: 'Snack Pagi',
              calories: (totalCalories * 0.1).round(),
              progress: caloriesProgress['Snack Pagi']?.toInt() ?? 0),
          Meal(
              time: '12:00',
              description: 'Makan Siang',
              calories: (totalCalories * 0.3).round(),
              progress: caloriesProgress['Makan Siang']?.toInt() ?? 0),
          Meal(
              time: '15:00',
              description: 'Snack Sore',
              calories: (totalCalories * 0.1).round(),
              progress: caloriesProgress['Snack Sore']?.toInt() ?? 0),
          Meal(
              time: '18:00',
              description: 'Makan Malam',
              calories: (totalCalories * 0.25).round(),
              progress: caloriesProgress['Makan Malam']?.toInt() ?? 0),
        ];
        waterConsumed = water;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching meal data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pencatatan Makanan',
                style: TextStyles.font24Blue700Weight,
              ),
              SizedBox(height: 5.h),
              _buildDateDropdown(),
              SizedBox(height: 16.h),
              Expanded(
                child: _buildMealList(context),
              ),
            ],
          );
  }

  Widget _buildDateDropdown() {
    return DateDropdown(
      selectedDay: selectedDate.day.toString(),
      selectedMonth: _getIndonesianMonth(selectedDate.month),
      selectedYear: selectedDate.year.toString(),
      onDayChanged: (value) {
        setState(() {
          selectedDate = DateTime(
              selectedDate.year, selectedDate.month, int.parse(value!));
        });
        _fetchMealData();
      },
      onMonthChanged: (value) {
        setState(() {
          selectedDate = DateTime(
              selectedDate.year, _getMonthNumber(value!), selectedDate.day);
        });
        _fetchMealData();
      },
      onYearChanged: (value) {
        setState(() {
          selectedDate =
              DateTime(int.parse(value!), selectedDate.month, selectedDate.day);
        });
        _fetchMealData();
      },
      showDayDropdown: true,
      showYearDropdown: false,
    );
  }

 Widget _buildMealList(BuildContext context) {
  return RefreshIndicator(
    onRefresh: _fetchMealData,
    child: ListView.builder(
      itemCount: meals.length + 1,
      itemBuilder: (context, index) {
        if (index == meals.length) {
          return _buildWaterIntake();
        }
        final meal = meals[index];
        print(
            'Meal: ${meal.description}, Progress: ${meal.progress}, Calories: ${meal.calories}');
        
        void _navigateToMealDetail() {
          Navigator.pushNamed(
            context,
            Routes.mealDetailScreen,
            arguments: {
              'mealDescription': meal.description,
              'calories': meal.calories,
              'progress': meal.progress,
              'childId': widget.childId,
            },
          );
        }

        return MealCard(
          meal: meal,
          onTap: _navigateToMealDetail,
        );
      },
    ),
  );
}

  Widget _buildWaterIntake() {
    final int glassesConsumed = (waterConsumed / 200).floor();
    final int totalGlasses = 8;

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
          title: Text('Kebutuhan Air Putih',
              style: TextStyle(fontSize: 16.sp, color: ColorsManager.darkBlue)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check_circle, size: 24.sp, color: Colors.blue),
                onPressed: () {},
              ),
              Text('$glassesConsumed/$totalGlasses Gelas',
                  style: TextStyle(fontSize: 14.sp, color: ColorsManager.gray)),
            ],
          ),
        ),
      ),
    );
  }

  String _getIndonesianMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  int _getMonthNumber(String month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months.indexOf(month) + 1;
  }
}
