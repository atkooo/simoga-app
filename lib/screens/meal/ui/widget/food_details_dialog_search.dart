import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../model/food_nutrition.dart';

class FoodDetailsDialog extends StatefulWidget {
  final FoodNutrition nutrition;
  final TextEditingController weightController;
  final TextEditingController quantityController;
  final bool initialShowChildChecklist;
  final Map<String, bool> initialChildCheckList;
  final String childId;

  const FoodDetailsDialog({
    required this.nutrition,
    required this.weightController,
    required this.quantityController,
    required this.initialShowChildChecklist,
    required this.initialChildCheckList,
    required this.childId,
    super.key,
  });

  @override
  _FoodDetailsDialogState createState() => _FoodDetailsDialogState();
}

class _FoodDetailsDialogState extends State<FoodDetailsDialog> {
  late bool showChildChecklist;
  late Map<String, bool> childCheckList;
  String selectedPortion = '100%';
  double portionFactor = 1.0;

  @override
  void initState() {
    super.initState();
    showChildChecklist = widget.initialShowChildChecklist;
    childCheckList = Map.from(widget.initialChildCheckList);
  }

  void _updatePortionFactor(String portion) {
    setState(() {
      selectedPortion = portion;
      portionFactor = int.parse(portion.replaceAll('%', '')) / 100;
    });
  }

  Future<void> _saveMealHistory() async {
    final now = DateTime.now();
    final mealData = {
      'foodName': widget.nutrition.name,
      'calories': widget.nutrition.calories * portionFactor,
      'protein': widget.nutrition.protein * portionFactor,
      'fat': widget.nutrition.fat * portionFactor,
      'carbs': widget.nutrition.carbs * portionFactor,
      'portion': selectedPortion,
      'timestamp': now,
    };

    try {
      if (widget.childId.isNotEmpty) {
        DocumentSnapshot childDoc = await FirebaseFirestore.instance
            .collection('children')
            .doc(widget.childId)
            .get();
        if (childDoc.exists && childDoc.data() != null) {
          final parentId = childDoc.get('parentId');
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;

          print('Current User ID: $currentUserId');
          print('Parent ID: $parentId');

          if (currentUserId != null && currentUserId == parentId) {
            await FirebaseFirestore.instance
                .collection('children')
                .doc(widget.childId)
                .collection('mealHistory')
                .add(mealData);

            for (var entry in childCheckList.entries) {
              if (entry.value) {
                await FirebaseFirestore.instance
                    .collection('children')
                    .where('name', isEqualTo: entry.key)
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    FirebaseFirestore.instance
                        .collection('children')
                        .doc(doc.id)
                        .collection('mealHistory')
                        .add(mealData);
                  }
                });
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Riwayat makan berhasil disimpan!')));
          } else {
            throw Exception(
                'User is not authorized to add meal history for this child');
          }
        } else {
          throw Exception(
              'Child document does not exist or parentId not found');
        }
      } else {
        throw Exception('Child ID tidak boleh kosong');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan riwayat makan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(widget.nutrition.image,
                      height: 150, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.keyboard_arrow_down,
                    size: 30, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                widget.nutrition.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kalori: ${(widget.nutrition.calories * portionFactor).toStringAsFixed(2)} kkal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Protein: ${(widget.nutrition.protein * portionFactor).toStringAsFixed(2)} g',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Lemak: ${(widget.nutrition.fat * portionFactor).toStringAsFixed(2)} g',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Karbohidrat: ${(widget.nutrition.carbs * portionFactor).toStringAsFixed(2)} g',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Makanan yang dikonsumsi:',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPortion,
                items: <String>['25%', '50%', '75%', '100%']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _updatePortionFactor(newValue);
                  }
                },
                isExpanded: true,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Catat makanan anak lainnya?'),
                value: showChildChecklist,
                onChanged: (bool? value) {
                  setState(() {
                    showChildChecklist = value ?? false;
                  });
                },
              ),
              if (showChildChecklist)
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: childCheckList.keys.map((String key) {
                    return CheckboxListTile(
                      title: Text(key),
                      value: childCheckList[key],
                      onChanged: (bool? value) {
                        setState(() {
                          childCheckList[key] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _saveMealHistory();
            Navigator.of(context).pop({
              'showChildChecklist': showChildChecklist,
              'childCheckList': childCheckList,
              'selectedPortion': selectedPortion,
            });
          },
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
          child: const Text('Simpan'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
