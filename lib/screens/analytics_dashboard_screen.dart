import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(title: const Text('Insights & Analytics')),
      body: Consumer2<MealProvider, GoalProvider>(
        builder: (context, mealP, goalP, _) {
          final weeklyData = mealP.getWeeklyData();
          final achievement = mealP.weeklyGoalAchievement(goalP.goal.targetCalories);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAchievementCard(achievement),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Weekly Calorie Trend'),
              const SizedBox(height: 12),
              _buildChartCard(weeklyData, goalP.goal.targetCalories),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Nutrient Distribution'),
              const SizedBox(height: 12),
              _buildNutrientSummary(mealP, goalP),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(double percentage) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: AppTheme.secondary.withOpacity(0.1),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text('${percentage.toInt()}%', 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goal Achievement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('You reached 80% of your daily calorie goal on 5 out of 7 days this week.', 
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<Map<String, dynamic>> data, double target) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(10, 24, 20, 16),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: target * 1.5 > 0 ? target * 1.5 : 3000,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppTheme.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} kcal',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 || value.toInt() >= data.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(data[value.toInt()]['label'], 
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              final idx = entry.key;
              final val = entry.value['calories'] as double;
              final isToday = idx == data.length - 1;
              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    toY: val,
                    color: val > target ? AppTheme.accent : (isToday ? AppTheme.primary : AppTheme.primary.withOpacity(0.5)),
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: target,
                      color: AppTheme.surface,
                    ),
                  ),
                ],
              );
            }).toList(),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: target,
                  color: AppTheme.textMuted.withOpacity(0.3),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
                    labelResolver: (_) => 'Goal: ${target.toInt()}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientSummary(MealProvider mealP, GoalProvider goalP) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nutrientCircle('Protein', mealP.totalProtein, goalP.goal.targetProtein, AppTheme.secondary),
              _nutrientCircle('Carbs', mealP.totalCarbs, goalP.goal.targetCarbs, AppTheme.warning),
              _nutrientCircle('Fats', mealP.totalFats, goalP.goal.targetFats, AppTheme.accent),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Daily Average (Last 7 Days)', 
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _nutrientCircle(String label, double val, double target, Color color) {
    final progress = target > 0 ? (val / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        SizedBox(
          width: 50, height: 50,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: AppTheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Text('${val.toInt()}g', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
