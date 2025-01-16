import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simoga/core/widgets/notification_widget.dart';

import 'package:simoga/screens/meal/ui/meal_screen.dart';
import '../../child/ui/child_tab.dart';
import '../../nutrition/nutrition_summary.dart';
import '../../child/ui/child_nutrition.dart';
import '../../../model/child_nutrition.dart';
import '../../../routing/routes.dart';
import '../../../core/widgets/custom_bottom_bar.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../providers/bottom_nav_provider.dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> children = [];
  int _selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    setupNotifications();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('parentId', isEqualTo: user.uid)
          .get();

      final fetchedChildren = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final akgData = data['akg'] ?? {};

        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed Child',
          'image': data['image'] ?? '',
          'nutrition': {
            'caloriesTarget': _safeConvert(akgData['caloriesHarris']),
            'caloriesProgress': 0,
            'proteinTarget': _safeConvert(akgData['proteinMax']),
            'proteinProgress': 0,
            'fatTarget': _safeConvert(akgData['fatMax']),
            'fatProgress': 0,
            'carbsTarget': _safeConvert(akgData['carbsMax']),
            'carbsProgress': 0,
            'fiberTarget': _safeConvert(akgData['fiber']),
            'fiberProgress': 0,
            'waterTarget': _safeConvert(akgData['water']),
            'waterProgress': 0,
          },
        };
      }).toList();

      setState(() {
        children = fetchedChildren;
      });
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  int _safeConvert(dynamic value, {int defaultValue = 0}) {
    if (value is num && !value.isNaN && !value.isInfinite) {
      return value.toInt();
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = Provider.of<BottomNavProvider>(context).currentIndex;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'SiMOGA',
        onPopupMenuSelected: (item) => _onSelected(context, item),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(
                height: 0.15.sh,
                child: ChildTabsScreen(
                  onChildSelected: (index) {
                    setState(() {
                      _selectedChildIndex = index;
                    });
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(child: child, opacity: animation);
                  },
                  child: _buildCurrentTab(currentIndex),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => onTabTapped(context, index),
      ),
    );
  }

  Widget _buildCurrentTab(int currentIndex) {
    if (children.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    switch (currentIndex) {
      case 0:
        return NutritionSummary(
            key: ValueKey(children[_selectedChildIndex]['name']),
            childName: children[_selectedChildIndex]['name']);
      case 1:
        return MealScreen(
            key: ValueKey(children[_selectedChildIndex]['id']),
            childId: children[_selectedChildIndex]['id']);
      case 2:
        final nutritionData = children[_selectedChildIndex]['nutrition'];
        final childNutrition = ChildNutrition(
          title: 'Informasi Gizi Anak',
          caloriesTarget: nutritionData['caloriesTarget'],
          caloriesProgress: nutritionData['caloriesProgress'],
          proteinTarget: nutritionData['proteinTarget'],
          proteinProgress: nutritionData['proteinProgress'],
          fatTarget: nutritionData['fatTarget'],
          fatProgress: nutritionData['fatProgress'],
          carbsTarget: nutritionData['carbsTarget'],
          carbsProgress: nutritionData['carbsProgress'],
          fiberTarget: nutritionData['fiberTarget'],
          fiberProgress: nutritionData['fiberProgress'],
          waterTarget: nutritionData['waterTarget'],
          waterProgress: nutritionData['waterProgress'],
        );
        return ChildNutritionScreen(
          key: ValueKey(children[_selectedChildIndex]['id']),
          nutrition: childNutrition,
          childId: children[_selectedChildIndex]['id'],
          onNutritionUpdated: (updatedNutrition) {
            setState(() {
              children[_selectedChildIndex]['nutrition'] = {
                'caloriesTarget': updatedNutrition.caloriesTarget,
                'caloriesProgress': updatedNutrition.caloriesProgress,
                'proteinTarget': updatedNutrition.proteinTarget,
                'proteinProgress': updatedNutrition.proteinProgress,
                'fatTarget': updatedNutrition.fatTarget,
                'fatProgress': updatedNutrition.fatProgress,
                'carbsTarget': updatedNutrition.carbsTarget,
                'carbsProgress': updatedNutrition.carbsProgress,
                'fiberTarget': updatedNutrition.fiberTarget,
                'fiberProgress': updatedNutrition.fiberProgress,
                'waterTarget': updatedNutrition.waterTarget,
                'waterProgress': updatedNutrition.waterProgress,
              };
            });
          },
        );
      default:
        return Container();
    }
  }

  void onTabTapped(BuildContext context, int index) {
    Provider.of<BottomNavProvider>(context, listen: false)
        .setCurrentIndex(index);
  }

  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                await _signOut(context);
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.providerData
          .any((provider) => provider.providerId == 'google.com')) {
        await _signOutGoogle();
      } else {
        await _signOutEmailPassword();
      }
      Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.loginScreen,
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _signOutEmailPassword() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _showSignOutError(e.toString());
    }
  }

  Future<void> _signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _showSignOutError(e.toString());
    }
  }

  void _showSignOutError(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign out error'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
