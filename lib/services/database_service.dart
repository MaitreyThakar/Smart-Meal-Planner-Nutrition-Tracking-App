import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static const String _foodBoxName = 'food_items';
  static const String _mealBoxName = 'meal_entries';
  static const String _goalBoxName = 'nutrition_goals';

  static final _uuid = const Uuid();

  static Box<FoodItem> get foodBox => Hive.box<FoodItem>(_foodBoxName);
  static Box<MealEntry> get mealBox => Hive.box<MealEntry>(_mealBoxName);
  static Box<NutritionGoal> get goalBox =>
      Hive.box<NutritionGoal>(_goalBoxName);

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(MealEntryAdapter());
    Hive.registerAdapter(NutritionGoalAdapter());

    await Hive.openBox<FoodItem>(_foodBoxName);
    await Hive.openBox<MealEntry>(_mealBoxName);
    await Hive.openBox<NutritionGoal>(_goalBoxName);

    await _seedFoodDatabase();
    await _seedGoal();
  }

  static Future<void> _seedGoal() async {
    if (goalBox.isEmpty) {
      await goalBox.put('goal', NutritionGoal());
    }
  }

  static Future<void> _seedFoodDatabase() async {
    if (foodBox.isNotEmpty) return;

    final foods = [
      FoodItem(id: _uuid.v4(), name: 'Rice (cooked)', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatsPer100g: 0.3, category: 'Grains'),
      FoodItem(id: _uuid.v4(), name: 'Wheat Bread', caloriesPer100g: 265, proteinPer100g: 9, carbsPer100g: 49, fatsPer100g: 3.2, category: 'Grains'),
      FoodItem(id: _uuid.v4(), name: 'Oats', caloriesPer100g: 389, proteinPer100g: 17, carbsPer100g: 66, fatsPer100g: 7, category: 'Grains'),
      FoodItem(id: _uuid.v4(), name: 'Chapati / Roti', caloriesPer100g: 297, proteinPer100g: 8, carbsPer100g: 52, fatsPer100g: 7, category: 'Grains'),
      FoodItem(id: _uuid.v4(), name: 'Pasta (cooked)', caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatsPer100g: 1.1, category: 'Grains'),
      FoodItem(id: _uuid.v4(), name: 'Chicken Breast', caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatsPer100g: 3.6, category: 'Protein'),
      FoodItem(id: _uuid.v4(), name: 'Eggs', caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatsPer100g: 11, category: 'Protein'),
      FoodItem(id: _uuid.v4(), name: 'Lentils (dal)', caloriesPer100g: 116, proteinPer100g: 9, carbsPer100g: 20, fatsPer100g: 0.4, category: 'Protein'),
      FoodItem(id: _uuid.v4(), name: 'Paneer', caloriesPer100g: 265, proteinPer100g: 18, carbsPer100g: 1.2, fatsPer100g: 20, category: 'Protein'),
      FoodItem(id: _uuid.v4(), name: 'Fish (Salmon)', caloriesPer100g: 208, proteinPer100g: 20, carbsPer100g: 0, fatsPer100g: 13, category: 'Protein'),
      FoodItem(id: _uuid.v4(), name: 'Tuna (canned)', caloriesPer100g: 132, proteinPer100g: 28, carbsPer100g: 0, fatsPer100g: 1.3, category: 'Protein'),
      FoodItem(id: _uuid.v4(), name: 'Whole Milk', caloriesPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8, fatsPer100g: 3.3, category: 'Dairy'),
      FoodItem(id: _uuid.v4(), name: 'Curd / Yogurt', caloriesPer100g: 59, proteinPer100g: 3.5, carbsPer100g: 4.7, fatsPer100g: 3.3, category: 'Dairy'),
      FoodItem(id: _uuid.v4(), name: 'Banana', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatsPer100g: 0.3, category: 'Fruits'),
      FoodItem(id: _uuid.v4(), name: 'Apple', caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatsPer100g: 0.2, category: 'Fruits'),
      FoodItem(id: _uuid.v4(), name: 'Orange', caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatsPer100g: 0.1, category: 'Fruits'),
      FoodItem(id: _uuid.v4(), name: 'Mango', caloriesPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15, fatsPer100g: 0.4, category: 'Fruits'),
      FoodItem(id: _uuid.v4(), name: 'Spinach', caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatsPer100g: 0.4, category: 'Vegetables'),
      FoodItem(id: _uuid.v4(), name: 'Broccoli', caloriesPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 7, fatsPer100g: 0.4, category: 'Vegetables'),
      FoodItem(id: _uuid.v4(), name: 'Tomato', caloriesPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatsPer100g: 0.2, category: 'Vegetables'),
      FoodItem(id: _uuid.v4(), name: 'Potato', caloriesPer100g: 77, proteinPer100g: 2, carbsPer100g: 17, fatsPer100g: 0.1, category: 'Vegetables'),
      FoodItem(id: _uuid.v4(), name: 'Almonds', caloriesPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatsPer100g: 50, category: 'Nuts & Seeds'),
      FoodItem(id: _uuid.v4(), name: 'Peanut Butter', caloriesPer100g: 588, proteinPer100g: 25, carbsPer100g: 20, fatsPer100g: 50, category: 'Nuts & Seeds'),
      FoodItem(id: _uuid.v4(), name: 'Olive Oil', caloriesPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatsPer100g: 100, category: 'Fats & Oils'),
      FoodItem(id: _uuid.v4(), name: 'Idli', caloriesPer100g: 58, proteinPer100g: 2, carbsPer100g: 12, fatsPer100g: 0.1, category: 'Indian'),
      FoodItem(id: _uuid.v4(), name: 'Dosa', caloriesPer100g: 133, proteinPer100g: 3.5, carbsPer100g: 25, fatsPer100g: 2.8, category: 'Indian'),
      FoodItem(id: _uuid.v4(), name: 'Sambar', caloriesPer100g: 49, proteinPer100g: 2.8, carbsPer100g: 7, fatsPer100g: 1.4, category: 'Indian'),
      FoodItem(id: _uuid.v4(), name: 'Biryani (Veg)', caloriesPer100g: 172, proteinPer100g: 4, carbsPer100g: 30, fatsPer100g: 4.5, category: 'Indian'),
      FoodItem(id: _uuid.v4(), name: 'Green Tea', caloriesPer100g: 1, proteinPer100g: 0.2, carbsPer100g: 0.2, fatsPer100g: 0, category: 'Beverages'),
      FoodItem(id: _uuid.v4(), name: 'Coffee (black)', caloriesPer100g: 2, proteinPer100g: 0.3, carbsPer100g: 0, fatsPer100g: 0, category: 'Beverages'),
    ];

    for (final food in foods) {
      await foodBox.put(food.id, food);
    }
  }

  // Food CRUD
  static List<FoodItem> getAllFoods() => foodBox.values.toList();

  static List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) return getAllFoods();
    final q = query.toLowerCase();
    return foodBox.values
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q))
        .toList();
  }

  static Future<void> addCustomFood(FoodItem food) async {
    await foodBox.put(food.id, food);
  }

  static Future<void> deleteFood(String id) async {
    await foodBox.delete(id);
  }

  // Meal CRUD
  static Future<void> addMealEntry(MealEntry entry) async {
    await mealBox.put(entry.id, entry);
  }

  static Future<void> deleteMealEntry(String id) async {
    await mealBox.delete(id);
  }

  static List<MealEntry> getMealEntriesForDate(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return mealBox.values
        .where((e) => e.dateKey == dateKey)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<MealEntry> getMealEntriesForDateAndType(
      DateTime date, String mealType) {
    return getMealEntriesForDate(date)
        .where((e) => e.mealType == mealType)
        .toList();
  }

  static List<MealEntry> getEntriesForDateRange(
      DateTime start, DateTime end) {
    return mealBox.values.where((e) {
      return e.date
              .isAfter(start.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  static List<MealEntry> getAllEntries() => mealBox.values.toList();

  // Goals
  static NutritionGoal getGoal() {
    return goalBox.get('goal') ?? NutritionGoal();
  }

  static Future<void> saveGoal(NutritionGoal goal) async {
    await goalBox.put('goal', goal);
  }
}
