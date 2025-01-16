// child.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Child {
  String id;
  String name;
  String gender;
  DateTime birthDate;
  double height;
  double weight;
  String image;
  String parentId;
  AKG akg;

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.image,
    required this.parentId,
    required this.akg,
  });

  factory Child.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Child(
      id: doc.id,
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      height: data['height'] ?? 0.0,
      weight: data['weight'] ?? 0.0,
      image: data['image'] ?? '',
      parentId: data['parentId'] ?? '',
      akg: AKG.fromMap(data['akg'] ?? {}),
    );
  }
}

class AKG {
  double caloriesHarris;
  double carbsMax;
  double carbsMin;
  double fatMax;
  double fatMin;
  double fiber;
  double proteinMax;
  double proteinMin;
  double water;

  AKG({
    required this.caloriesHarris,
    required this.carbsMax,
    required this.carbsMin,
    required this.fatMax,
    required this.fatMin,
    required this.fiber,
    required this.proteinMax,
    required this.proteinMin,
    required this.water,
  });

  factory AKG.fromMap(Map<String, dynamic> map) {
    return AKG(
      caloriesHarris: map['caloriesHarris']?.toDouble() ?? 0.0,
      carbsMax: map['carbsMax']?.toDouble() ?? 0.0,
      carbsMin: map['carbsMin']?.toDouble() ?? 0.0,
      fatMax: map['fatMax']?.toDouble() ?? 0.0,
      fatMin: map['fatMin']?.toDouble() ?? 0.0,
      fiber: map['fiber']?.toDouble() ?? 0.0,
      proteinMax: map['proteinMax']?.toDouble() ?? 0.0,
      proteinMin: map['proteinMin']?.toDouble() ?? 0.0,
      water: map['water']?.toDouble() ?? 0.0,
    );
  }
}
