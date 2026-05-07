import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
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
    final mealP = context.read<MealProvider>();
    final entries = mealP.getWeeklyData(); // This is just for dummy logic, let's use actual data
    
    // In a real app, we'd fetch entries for this specific date
    // For now, let's just show a summary card that navigates to the tracker
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () {
          mealP.setDate(date);
          // Navigate to tracking or stay in main nav? 
          // Since we are in a tab, we should probably tell the main nav to switch or just push.
          // But here, let's just update the provider date and show a message.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Date set to ${DateFormat('MMM d').format(date)}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(DateFormat('dd').format(date),
                      style: TextStyle(
                          color: isToday ? Colors.black : AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text(DateFormat('MMM').format(date),
                      style: TextStyle(
                          color: isToday ? Colors.black : AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isToday ? 'Today' : DateFormat('EEEE').format(date),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Text('No meals planned yet', 
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
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
