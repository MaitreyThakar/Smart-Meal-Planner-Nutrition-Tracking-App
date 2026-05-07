import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/meal_entry.dart';
import 'food_selection_screen.dart';

class DailyTrackingScreen extends StatefulWidget {
  const DailyTrackingScreen({super.key});

  @override
  State<DailyTrackingScreen> createState() => _DailyTrackingScreenState();
}

class _DailyTrackingScreenState extends State<DailyTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MealProvider, GoalProvider>(
      builder: (context, mealP, goalP, _) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(mealP),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCalorieCard(mealP, goalP),
                  const SizedBox(height: 16),
                  _buildNutrientCards(mealP, goalP),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: "Today's Meals",
                    action: '+ Add Food',
                    onAction: () => _openFoodSelection(context, mealP),
                  ),
                  const SizedBox(height: 12),
                  _buildMealFilterChips(mealP),
                  const SizedBox(height: 12),
                  _buildMealList(context, mealP),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  SliverAppBar _buildAppBar(MealProvider mealP) {
    return SliverAppBar(
      backgroundColor: AppTheme.bgDark,
      floating: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Tracker',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(
            DateFormat('EEEE, MMM d').format(mealP.selectedDate),
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        _navBtn(Icons.chevron_left, () {
          final p = context.read<MealProvider>();
          p.setDate(p.selectedDate.subtract(const Duration(days: 1)));
        }),
        _navBtn(Icons.chevron_right, () {
          final p = context.read<MealProvider>();
          final next = p.selectedDate.add(const Duration(days: 1));
          if (!next.isAfter(DateTime.now())) p.setDate(next);
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      );

  Widget _buildCalorieCard(MealProvider mealP, GoalProvider goalP) {
    final mealCal = mealP.caloriesByMealType;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CalorieRingWidget(consumed: mealP.totalCalories, target: goalP.goal.targetCalories),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mealStat('Breakfast', mealCal['Breakfast'] ?? 0, AppTheme.breakfastColor),
                const SizedBox(height: 8),
                _mealStat('Lunch', mealCal['Lunch'] ?? 0, AppTheme.lunchColor),
                const SizedBox(height: 8),
                _mealStat('Dinner', mealCal['Dinner'] ?? 0, AppTheme.dinnerColor),
                const SizedBox(height: 8),
                _mealStat('Snacks', mealCal['Snacks'] ?? 0, AppTheme.snacksColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealStat(String label, double cal, Color color) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
          Text('${cal.toInt()} kcal', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _buildNutrientCards(MealProvider mealP, GoalProvider goalP) => GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            NutrientProgressBar(label: 'Protein', value: mealP.totalProtein, max: goalP.goal.targetProtein, color: AppTheme.secondary),
            const SizedBox(height: 14),
            NutrientProgressBar(label: 'Carbohydrates', value: mealP.totalCarbs, max: goalP.goal.targetCarbs, color: AppTheme.warning),
            const SizedBox(height: 14),
            NutrientProgressBar(label: 'Fats', value: mealP.totalFats, max: goalP.goal.targetFats, color: AppTheme.accent),
          ],
        ),
      );

  Widget _buildMealFilterChips(MealProvider mealP) {
    final types = ['All', ...MealProvider.mealTypes];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = types[i];
          return MealTypeChip(
            label: t,
            isSelected: mealP.filterMealType == t,
            onTap: () => mealP.setFilterMealType(t),
            color: t == 'All' ? AppTheme.primary : AppTheme.mealTypeColor(t),
          );
        },
      ),
    );
  }

  Widget _buildMealList(BuildContext context, MealProvider mealP) {
    final entries = mealP.filteredEntries;
    if (entries.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 48, color: AppTheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text('No meals logged yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Tap "+ Add Food" to log your first meal', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }
    return Column(
      children: entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _MealEntryCard(entry: e, onDelete: () => mealP.deleteMealEntry(e.id)),
      )).toList(),
    );
  }

  void _openFoodSelection(BuildContext context, MealProvider mealP) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodSelectionScreen(selectedDate: mealP.selectedDate)),
    ).then((_) => mealP.loadEntriesForDate(mealP.selectedDate));
  }
}

class _MealEntryCard extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onDelete;
  const _MealEntryCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.mealTypeColor(entry.mealType);
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.accent, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(AppTheme.mealTypeIcon(entry.mealType), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.foodItemName,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(entry.mealType, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.quantityGrams.toInt()}g', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.calories.toInt()}',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                const Text('kcal', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
