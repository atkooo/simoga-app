import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../theming/colors.dart';

class BarcodeScanWidget extends StatefulWidget {
  BarcodeScanWidget({super.key});

  @override
  _BarcodeScanWidgetState createState() => _BarcodeScanWidgetState();
}

class _BarcodeScanWidgetState extends State<BarcodeScanWidget> {
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  bool _isLoading = false;

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        _fetchFoodData(result.rawContent);
      }
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == BarcodeScanner.cameraAccessDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kamera akses tidak diizinkan')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kesalahan: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _fetchFoodData(String barcode) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          setState(() {
            _foodNameController.text =
                product['product_name'] ?? 'Tidak diketahui';
            _caloriesController.text =
                (product['nutriments']['energy-kcal_100g'] ?? 0).toString();
            _proteinController.text =
                (product['nutriments']['proteins_100g'] ?? 0).toString();
            _carbsController.text =
                (product['nutriments']['carbohydrates_100g'] ?? 0).toString();
            _fatController.text =
                (product['nutriments']['fat_100g'] ?? 0).toString();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data tidak ditemukan untuk barcode ini')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data tidak ditemukan untuk barcode ini')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan saat mengambil data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pindai Barcode',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _scanBarcode,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Pindai Barcode'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.mainBlue,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            )
          else ...[
            _buildTextField(
              controller: _foodNameController,
              label: 'Nama Makanan',
              icon: Icons.fastfood,
            ),
            _buildTextField(
              controller: _caloriesController,
              label: 'Kalori',
              icon: Icons.local_fire_department,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _proteinController,
              label: 'Protein (g)',
              icon: Icons.egg,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _carbsController,
              label: 'Karbohidrat (g)',
              icon: Icons.bakery_dining,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _fatController,
              label: 'Lemak (g)',
              icon: Icons.opacity,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: ColorsManager.mainBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ColorsManager.mainBlue),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label harus diisi';
          }
          return null;
        },
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
      ),
    );
  }
}
