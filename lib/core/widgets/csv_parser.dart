import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../../../../model/food_nutrition.dart';

class CsvParser {
  Future<List<FoodNutrition>> loadCsvData(String path) async {
    try {
      final rawData = await rootBundle.loadString(path);
      List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);

      List<FoodNutrition> foods = [];
      for (var i = 1; i < rows.length; i++) {
        try {
          foods.add(FoodNutrition.fromCsv({
            'id': rows[i][0].toString(),
            'calories': rows[i][1].toString(),
            'proteins': rows[i][2].toString(),
            'fat': rows[i][3].toString(),
            'carbohydrate': rows[i][4].toString(),
            'name': rows[i][5],
            'image': rows[i][6],
          }));
        } catch (e) {}
      }
      return foods;
    } catch (e) {
      print("Error loading CSV: $e");
      return [];
    }
  }
}
