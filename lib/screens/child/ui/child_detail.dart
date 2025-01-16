// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theming/colors.dart';
import '../../../theming/styles.dart';

class ChildDetailPage extends StatelessWidget {
  final Map<String, dynamic>? childData;

  const ChildDetailPage({super.key, this.childData});

  @override
  Widget build(BuildContext context) {
    if (childData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Anak'),
          backgroundColor: ColorsManager.mainBlue,
        ),
        body: Center(
          child: Text('Tidak ada data anak yang tersedia.',
              style: TextStyles.font24Blue700Weight),
        ),
      );
    }

    String formatTanggalIndonesia(String tanggalString) {
      DateTime tanggal = DateTime.parse(tanggalString);
      List<String> namaBulan = [
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

      return '${tanggal.day} ${namaBulan[tanggal.month - 1]} ${tanggal.year}';
    }

    String formatAngka(double angka) {
      return angka
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    final Map<String, String> akgMap = {
      'Kalori (Harris-Benedict)':
          '${formatAngka(childData!['akg']['caloriesHarris'])} kkal',
      'Protein':
          '${formatAngka(childData!['akg']['proteinMin'])} - ${formatAngka(childData!['akg']['proteinMax'])} g',
      'Lemak':
          '${formatAngka(childData!['akg']['fatMin'])} - ${formatAngka(childData!['akg']['fatMax'])} g',
      'Karbohidrat':
          '${formatAngka(childData!['akg']['carbsMin'])} - ${formatAngka(childData!['akg']['carbsMax'])} g',
      'Serat': '${formatAngka(childData!['akg']['fiber'])} g',
      'Air': '${formatAngka(childData!['akg']['water'])} ml',
    };

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.mainBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text('Kembali',
                            style: TextStyles.font16White600Weight
                                .copyWith(fontSize: 13)),
                      ),
                    ),
                    Center(
                      child: childData!['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.file(
                                File(childData!['image']),
                                height: 200.h,
                                width: 200.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: ColorsManager.gray76,
                              radius: 50,
                              child: Icon(Icons.person, size: 50),
                            ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text(
                        'Nama: ${childData!['name']}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Tanggal Lahir: ${formatTanggalIndonesia(childData!['birthDate'])}',
                        style: TextStyles.font14Grey400Weight,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Jenis Kelamin: ${childData!['gender']}',
                        style: TextStyles.font14Grey400Weight,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Berat Badan: ${childData!['weight']} kg',
                        style: TextStyles.font14Grey400Weight,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        'Tinggi Badan: ${childData!['height']} cm',
                        style: TextStyles.font14Grey400Weight,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text(
                        'Target AKG',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Table(
                      border: TableBorder.all(color: ColorsManager.gray76),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: ColorsManager.mainBlue,
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Center(
                                child: Text(
                                  'Nutrisi',
                                  style:
                                      TextStyles.font16White600Weight.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Center(
                                child: Text(
                                  'Target',
                                  style:
                                      TextStyles.font16White600Weight.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (var entry in akgMap.entries)
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  entry.key,
                                  style: TextStyles.font14Grey400Weight,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  entry.value,
                                  style: TextStyles.font14Grey400Weight,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
