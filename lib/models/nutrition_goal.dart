import 'package:hive/hive.dart';

part 'nutrition_goal.g.dart';

@HiveType(typeId: 2)
class NutritionGoal extends HiveObject {
  @HiveField(0)
  late double targetCalories;

  @HiveField(1)
  late double targetProtein;

  @HiveField(2)
  late double targetCarbs;

  @HiveField(3)
  late double targetFats;

  NutritionGoal({
    this.targetCalories = 2000,
    this.targetProtein = 50,
    this.targetCarbs = 250,
    this.targetFats = 65,
  });
}
