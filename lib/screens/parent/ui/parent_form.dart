import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../routing/routes.dart';
import '../../../theming/colors.dart';
import '../../../theming/styles.dart';
import '../../../core/widgets/app_text_form_field.dart';

class ParentForm extends StatefulWidget {
  final String userId;
  const ParentForm({Key? key, required this.userId}) : super(key: key);

  @override
  _ParentFormState createState() => _ParentFormState();
}

class _ParentFormState extends State<ParentForm> {
  final TextEditingController nikController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final String selectedProvince = 'Kalimantan Barat';
  String? selectedRegency;
  String? selectedCity;

  List regencies = [];
  List cities = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchRegencies('61');
  }

  Future<void> fetchRegencies(String provinceId) async {
    final response = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'));
    if (response.statusCode == 200) {
      setState(() {
        // Ubah nama kabupaten menjadi capitalize each word
        regencies = jsonDecode(response.body).map((regency) {
          regency['name'] = capitalizeEachWord(regency['name']);
          return regency;
        }).toList();
      });
    }
  }

  Future<void> fetchCities(String regencyId) async {
    final response = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json'));
    if (response.statusCode == 200) {
      setState(() {
        // Ubah nama kota menjadi capitalize each word
        cities = jsonDecode(response.body).map((city) {
          city['name'] = capitalizeEachWord(city['name']);
          return city;
        }).toList();
      });
    }
  }

  void saveParentData() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedRegency == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kabupaten wajib diisi')),
        );
        return;
      }
      if (selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kota wajib diisi')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'nik': nikController.text,
          'address': addressController.text,
          'provinsi': selectedProvince,
          'kabupaten': capitalizeEachWord(selectedRegency!),
          'kecamatan': capitalizeEachWord(selectedCity!),
          'parentDataComplete': true,
          'childDataComplete': false,
          'dataComplete': false,
        });

        Navigator.pushReplacementNamed(context, Routes.childForm,
            arguments: {'userId': widget.userId});
      } catch (e) {
        print('Error saving parent data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data orang tua.')),
        );
      }
    }
  }

  String capitalizeEachWord(String input) {
    return input
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          title: Text(
            'Informasi Orang Tua',
            style: TextStyles.font20WhiteWeight,
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
            padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 16.h),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    AppTextFormField(
                      hint: 'NIK',
                      controller: nikController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIK wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    AppTextFormField(
                      hint: 'Alamat',
                      controller: addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    _buildDropdown(
                      hintText: 'Pilih Kabupaten',
                      value: selectedRegency,
                      items: regencies,
                      onChanged: (value) {
                        setState(() {
                          selectedRegency = value!;
                          selectedCity = null;
                          cities = [];
                        });
                        final selectedRegencyId = regencies.firstWhere(
                            (regency) =>
                                regency['name'] == selectedRegency)['id'];
                        fetchCities(selectedRegencyId);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kabupaten wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    _buildDropdown(
                      hintText: 'Pilih Kota',
                      value: selectedCity,
                      items: cities,
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kota wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: saveParentData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hintText,
    required String? value,
    required List items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyles.font14Hint500Weight,
        filled: true,
        fillColor: ColorsManager.lightShadeOfGray,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 17.h),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorsManager.gray93Color,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      value: value,
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['name'],
          child: Text(capitalizeEachWord(item['name'])),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
