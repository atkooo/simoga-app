class FoodNutrition {
  final int id;
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final String image;

  FoodNutrition({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.image,
  });

  factory FoodNutrition.fromCsv(Map<String, dynamic> csv) {
    try {
      return FoodNutrition(
        id: int.parse(csv['id']),
        name: csv['name'],
        calories: int.parse(csv['calories']),
        protein: double.parse(csv['proteins']),
        fat: double.parse(csv['fat']),
        carbs: double.parse(csv['carbohydrate']),
        image: csv['image'],
      );
    } catch (e) {
      throw FormatException(
          'Error parsing CSV values: ${csv.toString()} -> $e');
    }
  }
}
