import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';
import '../services/database_service.dart';

class MealProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  DateTime _selectedDate = DateTime.now();
  List<MealEntry> _entriesForDate = [];
  List<MealEntry> _filteredEntries = [];
  String _filterMealType = 'All';
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<MealEntry> get entriesForDate => _entriesForDate;
  List<MealEntry> get filteredEntries => _filteredEntries;
  String get filterMealType => _filterMealType;
  bool get isLoading => _isLoading;

  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  MealProvider() {
    loadEntriesForDate(_selectedDate);
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    loadEntriesForDate(date);
  }

  void loadEntriesForDate(DateTime date) {
    _entriesForDate = DatabaseService.getMealEntriesForDate(date);
    _applyFilter();
    notifyListeners();
  }

  void setFilterMealType(String type) {
    _filterMealType = type;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterMealType == 'All') {
      _filteredEntries = List.from(_entriesForDate);
    } else {
      _filteredEntries =
          _entriesForDate.where((e) => e.mealType == _filterMealType).toList();
    }
  }

  Future<bool> addMealEntry({
    required FoodItem food,
    required String mealType,
    required double quantity,
    required DateTime date,
  }) async {
    if (quantity <= 0) return false;

    final entry = MealEntry(
      id: _uuid.v4(),
      foodItemId: food.id,
      foodItemName: food.name,
      mealType: mealType,
      quantityGrams: quantity,
      calories: food.getCalories(quantity),
      protein: food.getProtein(quantity),
      carbs: food.getCarbs(quantity),
      fats: food.getFats(quantity),
      date: date,
    );

    await DatabaseService.addMealEntry(entry);
    loadEntriesForDate(_selectedDate);
    return true;
  }

  Future<void> deleteMealEntry(String id) async {
    await DatabaseService.deleteMealEntry(id);
    loadEntriesForDate(_selectedDate);
  }

  // Nutrition totals for selected date
  double get totalCalories =>
      _entriesForDate.fold(0, (sum, e) => sum + e.calories);

  double get totalProtein =>
      _entriesForDate.fold(0, (sum, e) => sum + e.protein);

  double get totalCarbs =>
      _entriesForDate.fold(0, (sum, e) => sum + e.carbs);

  double get totalFats =>
      _entriesForDate.fold(0, (sum, e) => sum + e.fats);

  Map<String, double> get caloriesByMealType {
    final map = <String, double>{};
    for (final type in mealTypes) {
      map[type] = _entriesForDate
          .where((e) => e.mealType == type)
          .fold(0, (sum, e) => sum + e.calories);
    }
    return map;
  }

  // Weekly data (last 7 days)
  List<Map<String, dynamic>> getWeeklyData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final entries = DatabaseService.getMealEntriesForDate(date);
      final calories = entries.fold(0.0, (sum, e) => sum + e.calories);
      result.add({
        'date': date,
        'calories': calories,
        'label': _dayLabel(date),
      });
    }
    return result;
  }

  String _dayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Goal achievement per week
  double weeklyGoalAchievement(double targetCalories) {
    final weekly = getWeeklyData();
    if (targetCalories <= 0) return 0;
    final achieved = weekly.where((d) {
      return (d['calories'] as double) >= targetCalories * 0.8;
    }).length;
    return (achieved / 7) * 100;
  }
}

class FoodProvider extends ChangeNotifier {
  List<FoodItem> _foods = [];
  List<FoodItem> _searchResults = [];
  String _searchQuery = '';

  List<FoodItem> get foods => _foods;
  List<FoodItem> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;

  final _uuid = const Uuid();

  FoodProvider() {
    loadFoods();
  }

  void loadFoods() {
    _foods = DatabaseService.getAllFoods();
    _searchResults = List.from(_foods);
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _searchResults = DatabaseService.searchFoods(query);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = List.from(_foods);
    notifyListeners();
  }

  List<String> get categories {
    final cats = _foods.map((f) => f.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<FoodItem> getFoodsByCategory(String category) {
    return _foods.where((f) => f.category == category).toList();
  }

  Future<bool> addCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required String category,
  }) async {
    if (name.trim().isEmpty || calories <= 0) return false;

    final food = FoodItem(
      id: _uuid.v4(),
      name: name.trim(),
      caloriesPer100g: calories,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatsPer100g: fats,
      isCustom: true,
      category: category.isEmpty ? 'Custom' : category,
    );

    await DatabaseService.addCustomFood(food);
    loadFoods();
    return true;
  }

  Future<void> deleteFood(String id) async {
    await DatabaseService.deleteFood(id);
    loadFoods();
  }
}

class GoalProvider extends ChangeNotifier {
  late NutritionGoal _goal;

  NutritionGoal get goal => _goal;

  GoalProvider() {
    _goal = DatabaseService.getGoal();
  }

  Future<bool> saveGoal({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) async {
    if (calories <= 0) return false;
    _goal = NutritionGoal(
      targetCalories: calories,
      targetProtein: protein,
      targetCarbs: carbs,
      targetFats: fats,
    );
    await DatabaseService.saveGoal(_goal);
    notifyListeners();
    return true;
  }

  double calorieProgress(double consumed) {
    if (_goal.targetCalories <= 0) return 0;
    return (consumed / _goal.targetCalories).clamp(0.0, 1.0);
  }

  double proteinProgress(double consumed) {
    if (_goal.targetProtein <= 0) return 0;
    return (consumed / _goal.targetProtein).clamp(0.0, 1.0);
  }

  double carbsProgress(double consumed) {
    if (_goal.targetCarbs <= 0) return 0;
    return (consumed / _goal.targetCarbs).clamp(0.0, 1.0);
  }

  double fatsProgress(double consumed) {
    if (_goal.targetFats <= 0) return 0;
    return (consumed / _goal.targetFats).clamp(0.0, 1.0);
  }
}
