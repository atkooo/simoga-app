import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simoga/model/food_nutrition.dart';
import 'package:simoga/core/widgets/csv_parser.dart';
import 'package:provider/provider.dart';

import '../../../../service/model_service_android.dart';
import 'photo_options_widget.dart';
import 'food_details_dialog_foto.dart';
import '../../../../providers/model_service_provider.dart';

class PhotoWidget extends StatefulWidget {
  final String childId;

  const PhotoWidget({super.key, required this.childId});

  @override
  _PhotoWidgetState createState() => _PhotoWidgetState();
}

class _PhotoWidgetState extends State<PhotoWidget> {
  File? _imageFile;
  List<Map<String, dynamic>> _predictions = [];
  List<FoodNutrition> _foodNutritions = [];

  @override
  void initState() {
    super.initState();
    _loadFoodNutritions();
  }

  Future<void> _loadFoodNutritions() async {
    CsvParser parser = CsvParser();
    List<FoodNutrition> foods =
        await parser.loadCsvData('assets/data_food/nutrition.csv');
    setState(() {
      _foodNutritions = foods;
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ModelServiceProvider>(context);

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () =>
                    PhotoOptionsWidget.showPhotoOptions(context, _pickImage),
                child: Center(
                  child: Container(
                    height: 100.h,
                    width: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Tambah Foto',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: EdgeInsets.only(top: 24.h),
                  child: ElevatedButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 18.w),
                    ),
                  ),
                ),
              if (_imageFile != null && _predictions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 24.h),
                  child: Column(
                    children: _predictions.map((prediction) {
                      String label = prediction['label'];
                      double confidence = prediction['confidence'];
                      String category = 'Unknown';
                      String food = 'Unknown';
                      if (label.contains('/')) {
                        var parts = label.split('/');
                        category = parts[0];
                        food = parts[1];
                      }
                      return GestureDetector(
                        onTap: () => _showFoodDetailsDialog(
                            context, food, category, confidence, _imageFile!),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.fastfood, color: Colors.white),
                            ),
                            title: Text(
                              food,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            subtitle: Text(
                              'Kategori: $category\nAkurasi: ${(confidence * 100).toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            trailing: Icon(Icons.info),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _predictions = [];
      });
      _classifyImage(_imageFile!);
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _predictions = [];
    });
  }

  Future<void> _classifyImage(File image) async {
    final modelServiceProvider =
        Provider.of<ModelServiceProvider>(context, listen: false);
    if (!modelServiceProvider.isModelLoaded) {
      print('Model is not loaded yet');
      return;
    }

    print('Starting image classification');
    final result = await ImageUtils.classifyImage(image);
    if (result != null) {
      print('Klasifikasi berhasil: $result');
      setState(() {
        _predictions = result;
      });
    } else {
      print('Klasifikasi gagal atau hasil kosong');
    }
  }

  void _showFoodDetailsDialog(BuildContext context, String food,
      String category, double confidence, File imageFile) {
    final nutritionInfo = _foodNutritions.firstWhere(
        (nutrition) => nutrition.name.toLowerCase() == food.toLowerCase(),
        orElse: () => FoodNutrition(
            id: 0,
            name: 'Unknown',
            calories: 0,
            protein: 0,
            fat: 0,
            carbs: 0,
            image: ''));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FoodDetailsDialog(
          nutrition: nutritionInfo,
          initialShowChildChecklist: false,
          initialChildCheckList: {},
          childId: widget.childId,
          food: food,
          category: category,
          confidence: confidence,
          imageFile: imageFile,
        );
      },
    );
  }
}
