import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theming/colors.dart';
import '../../../theming/styles.dart';

class ChildTabsScreen extends StatefulWidget {
  final ValueChanged<int> onChildSelected;

  const ChildTabsScreen({super.key, required this.onChildSelected});

  @override
  _ChildTabsScreenState createState() => _ChildTabsScreenState();
}

class _ChildTabsScreenState extends State<ChildTabsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> children = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      widget.onChildSelected(_tabController.index);
    });
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
        return {
          'id': doc.id,
          'name': doc['name'],
          'image': doc['image'],
        };
      }).toList();

      setState(() {
        children = fetchedChildren;
        _tabController.dispose();
        _tabController = TabController(length: children.length, vsync: this);
      });
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: List.generate(children.length, (index) {
              bool isSelected = _tabController.index == index;
              final child = children[index];
              final name = child['name'] ?? 'No Name';
              final displayName =
                  name.length > 8 ? '${name.substring(0, 8)}...' : name;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _tabController.index = index;
                  });
                  widget.onChildSelected(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      EdgeInsets.only(right: 16.w, left: index == 0 ? 0 : 0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorsManager.mainBlue.withOpacity(0.2)
                        : ColorsManager.softGreen,
                    borderRadius: BorderRadius.circular(10.r),
                    border: isSelected
                        ? Border.all(color: ColorsManager.mainBlue, width: 2.w)
                        : null,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor:
                            isSelected ? ColorsManager.mainBlue : Colors.white,
                        backgroundImage: child['image'] != null
                            ? NetworkImage(child['image'])
                            : null,
                        child: child['image'] == null
                            ? Icon(
                                Icons.person,
                                color: isSelected
                                    ? Colors.white
                                    : ColorsManager.softBlue,
                                size: 25.sp,
                              )
                            : null,
                      ),
                      SizedBox(
                        width: 60.w,
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: isSelected
                              ? TextStyles.font14Blue700Weight
                              : TextStyles.font14White600Weight,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
