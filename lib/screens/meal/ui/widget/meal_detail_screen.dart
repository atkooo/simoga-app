import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'search_food_widget.dart';
import 'barcode_scan_widget.dart';
import 'photo_widget.dart';

import '../../../../routing/routes.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../child/ui/child_tab.dart';
import '../../../../providers/bottom_nav_provider.dart.dart';
import '../../../../core/widgets/custom_bottom_bar.dart';
import '../../../../providers/expandable_button_provider.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealDescription;
  final int calories;
  final String childId;

  const MealDetailScreen({
    super.key,
    required this.mealDescription,
    required this.calories,
    required this.childId,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _selectedActionIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpandableButtonProvider>(context, listen: false)
          .setExpandedIndex(0);
      setState(() {
        _selectedActionIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = Provider.of<BottomNavProvider>(context).currentIndex;
    final expandableButtonProvider =
        Provider.of<ExpandableButtonProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.mealDescription,
          onPopupMenuSelected: (item) => _onSelected(context, item),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 0.15.sh,
                child: ChildTabsScreen(
                  onChildSelected: (index) {},
                ),
              ),
              SizedBox(height: 16.h),
              _buildSearchMethods(context, expandableButtonProvider),
              Expanded(
                child: _buildDynamicContent(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => onTabTapped(context, index),
        ),
      ),
    );
  }

  Widget _buildSearchMethods(
      BuildContext context, ExpandableButtonProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pencatatan',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ExpandableIconButton(
              index: 0,
              icon: Icons.search,
              label: 'Cari Makanan',
              provider: provider,
              onPressed: () {
                setState(() {
                  _selectedActionIndex = 0;
                });
              },
            ),
            _ExpandableIconButton(
              index: 1,
              icon: Icons.photo_camera,
              label: 'Foto Makanan',
              provider: provider,
              onPressed: () {
                setState(() {
                  _selectedActionIndex = 1;
                });
              },
            ),
            _ExpandableIconButton(
              index: 2,
              icon: Icons.barcode_reader,
              label: 'Scan Barcode',
              provider: provider,
              onPressed: () {
                setState(() {
                  _selectedActionIndex = 2;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicContent() {
    if (_selectedActionIndex == -1) {
      return Center(
        child: Text(
          'Silahkan pilih metode pencatatan',
          style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
        ),
      );
    }

    switch (_selectedActionIndex) {
      case 0:
        return SearchFoodWidget(childId: widget.childId);
      case 1:
        return PhotoWidget(childId: widget.childId);
      case 2:
        return BarcodeScanWidget();
      default:
        return Container();
    }
  }

  void onTabTapped(BuildContext context, int index) {
    Provider.of<BottomNavProvider>(context, listen: false)
        .setCurrentIndex(index);
    Navigator.pop(context);
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

class _ExpandableIconButton extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final ExpandableButtonProvider provider;
  final VoidCallback onPressed;

  const _ExpandableIconButton({
    required this.index,
    required this.icon,
    required this.label,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = provider.expandedIndex == index;

    return GestureDetector(
      onTap: () {
        provider.setExpandedIndex(isExpanded ? -1 : index);
        onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isExpanded ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: isExpanded ? Colors.white : Colors.grey),
            SizedBox(width: isExpanded ? 8.w : 0),
            isExpanded
                ? Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
