import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simoga/screens/child/ui/child_detail.dart';
import '../../../routing/routes.dart';
import '../../../theming/colors.dart';

class ChildProfilePage extends StatefulWidget {
  const ChildProfilePage({super.key});

  @override
  _ChildProfilePageState createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFirestore _firestore;
  late final String _uid;
  late final CollectionReference _childrenCollection;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _uid = _auth.currentUser?.uid ?? '';
    _childrenCollection = _firestore.collection('children');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text(
            'List Anak',
            style: TextStyle(fontSize: 20),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _childrenCollection
              .where('parentId', isEqualTo: _uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            }

            final children = snapshot.data?.docs ?? [];

            if (children.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care, size: 80, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Silahkan inputkan informasi anak',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.childForm);
                      },
                      child: Text('Tambah Data Anak'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: ColorsManager.mainBlue,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w),
                    child: ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final childData =
                            children[index].data() as Map<String, dynamic>;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.w),
                            leading: CircleAvatar(
                              backgroundColor: ColorsManager.mainBlue,
                              radius: 30.r,
                              backgroundImage: childData['image'] != null
                                  ? NetworkImage(childData['image'])
                                  : null,
                              child: childData['image'] == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              childData['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  childData['gender'] ?? '',
                                  style: const TextStyle(
                                      color: ColorsManager.gray, fontSize: 12),
                                ),
                                Text(
                                  'Berat: ${childData['weight']} kg, Tinggi: ${childData['height']} cm',
                                  style: const TextStyle(
                                      color: ColorsManager.gray, fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildDetailPage(
                                    childData: {
                                      'id': children[index].id,
                                      ...childData,
                                    },
                                  ),
                                ),
                              );
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (String value) async {
                                if (value == 'edit') {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.childForm,
                                    arguments: {
                                      'id': children[index].id,
                                      ...childData,
                                    },
                                  );
                                } else if (value == 'delete') {
                                  bool? confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Konfirmasi'),
                                      content: const Text(
                                          'Apakah Anda yakin ingin menghapus data anak ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Ya'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmDelete == true) {
                                    await _childrenCollection
                                        .doc(children[index].id)
                                        .delete();
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit,
                                            color: ColorsManager.mainBlue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.childForm);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.mainBlue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: const Text('Tambahkan Data'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                  'Apakah Anda yakin ingin pergi ke Layar Beranda?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Tidak'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Ya'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await saveUserDataCompletionStatus();
                            Navigator.pushNamedAndRemoveUntil(
                                context, Routes.homeScreen, (route) => false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.mainBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> saveUserDataCompletionStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'dataComplete': true,
      }, SetOptions(merge: true));
    }
  }
}
