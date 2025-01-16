// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simoga/theming/colors.dart';
import '../../screens/notification/notification_list_screen.dart';
import '../../routing/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function(int)? onPopupMenuSelected;

  const CustomAppBar(
      {super.key, required this.title, this.onPopupMenuSelected});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        child: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.notifications, color: Colors.white),
              offset: Offset(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Container(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Pengingat Makanan Anak',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          NotificationItem(
                            time: '08:00',
                            meal: 'Sarapan',
                            icon: Icons.wb_sunny,
                            color: Colors.orange,
                          ),
                          NotificationItem(
                            time: '12:00',
                            meal: 'Makan Siang',
                            icon: Icons.wb_cloudy,
                            color: Colors.blue,
                          ),
                          NotificationItem(
                            time: '18:00',
                            meal: 'Makan Malam',
                            icon: Icons.nightlight_round,
                            color: Colors.indigo,
                          ),
                          Divider(),
                          ListTile(
                            title: Center(
                              child: Text(
                                'Lihat Semua',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationListScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
            ),
            PopupMenuButton<int>(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onSelected: (item) {
                if (item == 0) {
                  Navigator.pushNamed(context, Routes.parentProfile);
                } else if (item == 1) {
                  Navigator.pushNamed(context, Routes.childProfile);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.person,
                          size: 20.sp, color: ColorsManager.gray),
                      SizedBox(width: 10.w),
                      Text(
                        'Profil Orang Tua',
                        style: TextStyle(
                            fontSize: 14.sp, color: ColorsManager.gray),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.child_care,
                          size: 20.sp, color: ColorsManager.gray),
                      SizedBox(width: 10.w),
                      Text(
                        'Profil Anak',
                        style: TextStyle(
                            fontSize: 14.sp, color: ColorsManager.gray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (item) => onPopupMenuSelected?.call(item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20.sp, color: Colors.grey),
                      SizedBox(width: 10.w),
                      Text(
                        'Settings',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.help, size: 20.sp, color: Colors.blue),
                      SizedBox(width: 10.w),
                      Text(
                        'Help',
                        style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20.sp, color: Colors.red),
                      SizedBox(width: 10.w),
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          backgroundColor: Colors.blueAccent,
          elevation: 6,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String time;
  final String meal;
  final IconData icon;
  final Color color;

  const NotificationItem({
    Key? key,
    required this.time,
    required this.meal,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(meal, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Waktunya mencatat makanan $meal anak'),
      trailing: Text(time, style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        // Aksi ketika notifikasi ditekan
      },
    );
  }
}
