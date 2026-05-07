import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/database_service.dart';
import 'daily_tracking_screen.dart';

class MealPlanningScreen extends StatelessWidget {
  const MealPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showGoalSettings(context),
          ),
        ],
      ),
      body: Consumer<MealProvider>(
        builder: (context, mealP, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Upcoming Plan'),
              const SizedBox(height: 12),
              ...List.generate(7, (index) {
                final date = DateTime.now().add(Duration(days: index));
                return _buildPlanCard(context, date);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primary.withOpacity(0.1),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan Your Success',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                SizedBox(height: 4),
                Text('Structured meal planning helps you stay consistent with your nutrition goals.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.auto_awesome_rounded, color: AppTheme.primary.withOpacity(0.5), size: 40),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final mealP = context.watch<MealProvider>();
    final entries = DatabaseService.getMealEntriesForDate(date);
    final totalCal = entries.fold(0.0, (sum, e) => sum + e.calories);
    final goalP = context.read<GoalProvider>();
    final isTargetMet = totalCal >= goalP.goal.targetCalories * 0.9;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () {
          mealP.setDate(date);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing data for ${DateFormat('EEEE, MMM d').format(date)}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: AppTheme.primary,
            ),
          );
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50, height: 55,
              decoration: BoxDecoration(
                gradient: isToday ? AppTheme.primaryGradient : null,
                color: isToday ? null : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isToday ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('dd').format(date),
                      style: TextStyle(
                          color: isToday ? Colors.black : AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                  Text(DateFormat('MMM').format(date),
                      style: TextStyle(
                          color: isToday ? Colors.black.withOpacity(0.7) : AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isToday ? 'Today' : DateFormat('EEEE').format(date),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        totalCal > 0 ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
                        size: 14,
                        color: totalCal > 0 ? (isTargetMet ? AppTheme.primary : AppTheme.warning) : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        totalCal > 0 
                            ? '${totalCal.toInt()} kcal logged' 
                            : 'No meals planned yet', 
                        style: TextStyle(
                          color: totalCal > 0 ? AppTheme.textSecondary : AppTheme.textMuted, 
                          fontSize: 13,
                          fontWeight: totalCal > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (totalCal > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isTargetMet ? AppTheme.primary : AppTheme.warning).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isTargetMet ? Icons.star_rounded : Icons.trending_up_rounded,
                  color: isTargetMet ? AppTheme.primary : AppTheme.warning,
                  size: 20,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }


  void _showGoalSettings(BuildContext context) {
    final goalP = context.read<GoalProvider>();
    final calCtrl = TextEditingController(text: goalP.goal.targetCalories.toInt().toString());
    final protCtrl = TextEditingController(text: goalP.goal.targetProtein.toInt().toString());
    final carbCtrl = TextEditingController(text: goalP.goal.targetCarbs.toInt().toString());
    final fatCtrl = TextEditingController(text: goalP.goal.targetFats.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Nutrition Goals', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            TextField(
              controller: calCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Calories (kcal)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: protCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: carbCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: fatCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Fats (g)'),
                )),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await goalP.saveGoal(
                    calories: double.tryParse(calCtrl.text) ?? 2000,
                    protein: double.tryParse(protCtrl.text) ?? 150,
                    carbs: double.tryParse(carbCtrl.text) ?? 200,
                    fats: double.tryParse(fatCtrl.text) ?? 60,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Goals'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
