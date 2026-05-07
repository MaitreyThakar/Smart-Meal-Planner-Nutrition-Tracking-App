import 'package:hive/hive.dart';

part 'meal_entry.g.dart';

@HiveType(typeId: 1)
class MealEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String foodItemId;

  @HiveField(2)
  late String foodItemName;

  @HiveField(3)
  late String mealType; // Breakfast, Lunch, Dinner, Snacks

  @HiveField(4)
  late double quantityGrams;

  @HiveField(5)
  late double calories;

  @HiveField(6)
  late double protein;

  @HiveField(7)
  late double carbs;

  @HiveField(8)
  late double fats;

  @HiveField(9)
  late DateTime date;

  @HiveField(10)
  late bool isSynced;

  MealEntry({
    required this.id,
    required this.foodItemId,
    required this.foodItemName,
    required this.mealType,
    required this.quantityGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
    this.isSynced = false,
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
