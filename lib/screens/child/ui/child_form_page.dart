import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simoga/screens/child/ui/child_list.dart';

import '../../../theming/colors.dart';
import '../../../core/widgets/app_text_form_field.dart';
import '../../../core/widgets/akg_calculator.dart';

class ChildFormPage extends StatefulWidget {
  final Map<String, dynamic>? childData;

  const ChildFormPage({Key? key, this.childData}) : super(key: key);

  @override
  _ChildFormPageState createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  String? _selectedGender;
  File? _image;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final SingleSelectController<String?> _genderController =
      SingleSelectController(null);
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.childData != null) {
      _nameController.text = widget.childData!['name'] ?? '';
      _birthDate = widget.childData!['birthDate'] != null
          ? DateTime.parse(widget.childData!['birthDate'])
          : null;
      _birthDateController.text = _formatDate(_birthDate);
      _selectedGender = widget.childData!['gender'];
      _genderController.value = _selectedGender;
      _weightController.text = widget.childData!['weight']?.toString() ?? '';
      _heightController.text = widget.childData!['height']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  Future<void> _saveChildData() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);
      final birthDate = _birthDate;
      if (weight == null || height == null || birthDate == null) {
        return;
      }

      final age = DateTime.now().year - birthDate.year;
      final akg = NutritionCalculator.calculateAKG(
        gender: _selectedGender!,
        weight: weight,
        height: height,
        age: age,
      );

      final childData = {
        'name': _nameController.text,
        'birthDate': _birthDate?.toIso8601String(),
        'gender': _selectedGender,
        'weight': weight,
        'height': height,
        'parentId': user.uid,
        'akg': akg,
        'image': _image?.path,
      };

      try {
        if (widget.childData != null) {
          await FirebaseFirestore.instance
              .collection('children')
              .doc(widget.childData!['id'])
              .update(childData);
        } else {
          await FirebaseFirestore.instance
              .collection('children')
              .add(childData);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'childDataComplete': true, 'dataComplete': true});

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChildListPage(),
          ),
        );
      } catch (e) {
        print('Error saving child data: $e');
      }
    }
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30.h, 0, 30.h, 16.h),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20.h),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40.r,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? Icon(Icons.person,
                                      size: 50.r, color: ColorsManager.gray76)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 20.r,
                                width: 20.r,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add,
                                    size: 15.r, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    AppTextFormField(
                      hint: 'Nama',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nama';
                        }
                        return null;
                      },
                      suffixIcon: const Icon(
                        Icons.person,
                        color: ColorsManager.mainBlue,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: AppTextFormField(
                          hint: 'Tanggal Lahir',
                          controller: _birthDateController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan masukkan tanggal lahir';
                            }
                            return null;
                          },
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: ColorsManager.mainBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomDropdown<String>(
                      hintText: 'Pilih Jenis Kelamin',
                      items: const ['Laki-laki', 'Perempuan'],
                      controller: _genderController,
                      excludeSelected: false,
                      listItemBuilder: (context, item, isSelected, onSelect) {
                        IconData iconData;
                        if (item == 'Laki-laki') {
                          iconData = Icons.male;
                        } else {
                          iconData = Icons.female;
                        }
                        return ListTile(
                          leading:
                              Icon(iconData, color: ColorsManager.mainBlue),
                          title: Text(item),
                          selected: isSelected,
                          onTap: onSelect,
                        );
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    AppTextFormField(
                      hint: 'Berat Badan (kg)',
                      controller: _weightController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan berat badan';
                        }
                        return null;
                      },
                      suffixIcon: const Icon(
                        Icons.line_weight,
                        color: ColorsManager.mainBlue,
                      ),
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 20.h),
                    AppTextFormField(
                      hint: 'Tinggi Badan (cm)',
                      controller: _heightController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan tinggi badan';
                        }
                        return null;
                      },
                      suffixIcon: const Icon(
                        Icons.height,
                        color: ColorsManager.mainBlue,
                      ),
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildListPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveChildData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
