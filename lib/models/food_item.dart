import 'package:hive/hive.dart';

part 'food_item.g.dart';

@HiveType(typeId: 0)
class FoodItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double caloriesPer100g;

  @HiveField(3)
  late double proteinPer100g;

  @HiveField(4)
  late double carbsPer100g;

  @HiveField(5)
  late double fatsPer100g;

  @HiveField(6)
  late bool isCustom;

  @HiveField(7)
  late String category;

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatsPer100g = 0,
    this.isCustom = false,
    this.category = 'General',
  });

  double getCalories(double quantityGrams) =>
      (caloriesPer100g * quantityGrams) / 100;

  double getProtein(double quantityGrams) =>
      (proteinPer100g * quantityGrams) / 100;

  double getCarbs(double quantityGrams) =>
      (carbsPer100g * quantityGrams) / 100;

  double getFats(double quantityGrams) =>
      (fatsPer100g * quantityGrams) / 100;
}
