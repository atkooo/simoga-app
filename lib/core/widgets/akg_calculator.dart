class NutritionCalculator {
  static Map<String, double> calculateAKG({
    required String gender,
    required double weight,
    required double height,
    required int age,
  }) {
    // Mifflin-St Jeor
    double caloriesMifflin;
    if (gender == 'Laki-laki') {
      caloriesMifflin = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      caloriesMifflin = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Harris-Benedict
    double caloriesHarris;
    if (gender == 'Laki-laki') {
      caloriesHarris =
          66.5 + (13.75 * weight) + (5.003 * height) - (6.755 * age);
    } else {
      caloriesHarris =
          655.1 + (9.563 * weight) + (1.850 * height) - (4.676 * age);
    }

    // Protein
    double proteinMin = 0.8 * weight;
    double proteinMax = 1.0 * weight;

    // Lemak
    double fatMin = 0.25 * caloriesMifflin / 9;
    double fatMax = 0.35 * caloriesMifflin / 9;

    // Karbohidrat
    double carbsMin = 0.45 * caloriesMifflin / 4;
    double carbsMax = 0.65 * caloriesMifflin / 4;

    // Serat
    double fiber;
    if (age >= 1 && age <= 3) {
      fiber = 19;
    } else if (age >= 4 && age <= 8) {
      fiber = 25;
    } else if (gender == 'Perempuan' && age >= 9 && age <= 18) {
      fiber = 26;
    } else if (gender == 'Laki-laki' && age >= 9 && age <= 13) {
      fiber = 31;
    } else if (gender == 'Laki-laki' && age >= 14 && age <= 18) {
      fiber = 38;
    } else {
      fiber = 0;
    }

    // Air
    double water = 30 * weight;

    return {
      'caloriesMifflin': caloriesMifflin,
      'caloriesHarris': caloriesHarris,
      'proteinMin': proteinMin,
      'proteinMax': proteinMax,
      'fatMin': fatMin,
      'fatMax': fatMax,
      'carbsMin': carbsMin,
      'carbsMax': carbsMax,
      'fiber': fiber,
      'water': water,
    };
  }
}
