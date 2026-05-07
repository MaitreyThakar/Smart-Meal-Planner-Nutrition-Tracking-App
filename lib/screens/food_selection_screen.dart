import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/food_item.dart';

class FoodSelectionScreen extends StatefulWidget {
  final DateTime? selectedDate;
  const FoodSelectionScreen({super.key, this.selectedDate});

  @override
  State<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _selectedMealType = 'Breakfast';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() {
      context.read<FoodProvider>().search(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLibraryView = widget.selectedDate == null;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(isLibraryView ? 'Food Library' : 'Select Food'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Food Database'),
            Tab(text: 'Custom Entry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FoodDatabaseTab(
            searchCtrl: _searchCtrl,
            selectedMealType: _selectedMealType,
            onMealTypeChanged: (t) => setState(() => _selectedMealType = t),
            selectedDate: widget.selectedDate,
          ),
          _CustomFoodTab(
            selectedMealType: _selectedMealType,
            onMealTypeChanged: (t) => setState(() => _selectedMealType = t),
            selectedDate: widget.selectedDate,
          ),
        ],
      ),
    );
  }
}

class _FoodDatabaseTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String selectedMealType;
  final ValueChanged<String> onMealTypeChanged;
  final DateTime? selectedDate;

  const _FoodDatabaseTab({
    required this.searchCtrl,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isLibraryView = selectedDate == null;
    return Consumer<FoodProvider>(
      builder: (context, foodP, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search food items...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchCtrl.clear();
                                foodP.clearSearch();
                              },
                              child: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                            )
                          : null,
                    ),
                  ),
                  if (!isLibraryView) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: MealProvider.mealTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final t = MealProvider.mealTypes[i];
                          return MealTypeChip(
                            label: t,
                            isSelected: selectedMealType == t,
                            onTap: () => onMealTypeChanged(t),
                            color: AppTheme.mealTypeColor(t),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: foodP.searchResults.isEmpty
                  ? const Center(
                      child: Text('No foods found',
                          style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: foodP.searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final food = foodP.searchResults[i];
                        return _FoodListTile(
                          food: food,
                          selectedMealType: selectedMealType,
                          selectedDate: selectedDate,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FoodListTile extends StatelessWidget {
  final FoodItem food;
  final String selectedMealType;
  final DateTime? selectedDate;

  const _FoodListTile({
    required this.food,
    required this.selectedMealType,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.mealTypeColor(selectedMealType);
    final isLibraryView = selectedDate == null;
    return GlassCard(
      onTap: isLibraryView ? null : () => _showAddDialog(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                food.name[0].toUpperCase(),
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _nutrientBadge('P: ${food.proteinPer100g.toInt()}g', AppTheme.secondary),
                    const SizedBox(width: 4),
                    _nutrientBadge('C: ${food.carbsPer100g.toInt()}g', AppTheme.warning),
                    const SizedBox(width: 4),
                    _nutrientBadge('F: ${food.fatsPer100g.toInt()}g', AppTheme.accent),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${food.caloriesPer100g.toInt()}',
                style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w800)),
              const Text('kcal/100g', style: TextStyle(color: AppTheme.textMuted, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutrientBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
  );

  void _showAddDialog(BuildContext context) {
    if (selectedDate == null) return;
    final qtyCtrl = TextEditingController(text: '100');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.mealTypeColor(selectedMealType),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(selectedMealType,
                          style: TextStyle(color: AppTheme.mealTypeColor(selectedMealType), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Quantity (grams)', suffixText: 'g'),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Enter a valid quantity > 0';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              StatefulBuilder(builder: (ctx, setSt) {
                final qty = double.tryParse(qtyCtrl.text) ?? 100;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _previewStat('Calories', '${food.getCalories(qty).toInt()} kcal', AppTheme.primary),
                      _previewStat('Protein', '${food.getProtein(qty).toStringAsFixed(1)}g', AppTheme.secondary),
                      _previewStat('Carbs', '${food.getCarbs(qty).toStringAsFixed(1)}g', AppTheme.warning),
                      _previewStat('Fats', '${food.getFats(qty).toStringAsFixed(1)}g', AppTheme.accent),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final qty = double.parse(qtyCtrl.text);
                    final mealP = context.read<MealProvider>();
                    final ok = await mealP.addMealEntry(
                      food: food,
                      mealType: selectedMealType,
                      quantity: qty,
                      date: selectedDate!,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? '${food.name} added to $selectedMealType!' : 'Invalid quantity'),
                          backgroundColor: ok ? AppTheme.primary : AppTheme.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  child: const Text('Add to Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewStat(String label, String value, Color color) => Column(
    children: [
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    ],
  );
}

class _CustomFoodTab extends StatefulWidget {
  final String selectedMealType;
  final ValueChanged<String> onMealTypeChanged;
  final DateTime? selectedDate;
  const _CustomFoodTab({required this.selectedMealType, required this.onMealTypeChanged, this.selectedDate});

  @override
  State<_CustomFoodTab> createState() => _CustomFoodTabState();
}

class _CustomFoodTabState extends State<_CustomFoodTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '100');
  final _catCtrl = TextEditingController();
  bool _saveToDb = true;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _calCtrl, _protCtrl, _carbCtrl, _fatCtrl, _qtyCtrl, _catCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLibraryView = widget.selectedDate == null;
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLibraryView) ...[
              const SectionHeader(title: 'Meal Type'),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: MealProvider.mealTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final t = MealProvider.mealTypes[i];
                    return MealTypeChip(
                      label: t, isSelected: widget.selectedMealType == t,
                      onTap: () => widget.onMealTypeChanged(t),
                      color: AppTheme.mealTypeColor(t),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SectionHeader(title: 'Food Details'),
            const SizedBox(height: 10),
            _field(_nameCtrl, 'Food Name *', required: true),
            const SizedBox(height: 10),
            _field(_catCtrl, 'Category (e.g. Indian, Grains)'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_calCtrl, 'Calories/100g *', required: true, isNum: true)),
              const SizedBox(width: 10),
              Expanded(child: _field(_qtyCtrl, 'Quantity (g) *', required: true, isNum: true)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_protCtrl, 'Protein/100g')),
              const SizedBox(width: 10),
              Expanded(child: _field(_carbCtrl, 'Carbs/100g')),
              const SizedBox(width: 10),
              Expanded(child: _field(_fatCtrl, 'Fats/100g')),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(value: _saveToDb, activeColor: AppTheme.primary, onChanged: (v) => setState(() => _saveToDb = v)),
                const SizedBox(width: 8),
                const Text('Save to food database', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(isLibraryView ? 'Add to Database' : 'Log Custom Food'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false, bool isNum = false}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: isNum ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (isNum && (double.tryParse(v) == null || double.parse(v) <= 0)) return '> 0';
                return null;
              }
            : null,
      );

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final foodP = context.read<FoodProvider>();
    final mealP = context.read<MealProvider>();

    final cal = double.parse(_calCtrl.text);
    final prot = double.tryParse(_protCtrl.text) ?? 0;
    final carb = double.tryParse(_carbCtrl.text) ?? 0;
    final fat = double.tryParse(_fatCtrl.text) ?? 0;
    final qty = double.parse(_qtyCtrl.text);

    FoodItem? food;
    if (_saveToDb) {
      await foodP.addCustomFood(
        name: _nameCtrl.text.trim(),
        calories: cal, protein: prot, carbs: carb, fats: fat,
        category: _catCtrl.text.trim(),
      );
      food = foodP.foods.lastWhere((f) => f.name == _nameCtrl.text.trim());
    } else {
      food = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        caloriesPer100g: cal, proteinPer100g: prot,
        carbsPer100g: carb, fatsPer100g: fat,
        isCustom: true, category: _catCtrl.text.trim(),
      );
    }

    if (widget.selectedDate != null) {
      await mealP.addMealEntry(
        food: food, mealType: widget.selectedMealType,
        quantity: qty, date: widget.selectedDate!,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.selectedDate != null ? '${food.name} logged!' : '${food.name} saved!'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      if (widget.selectedDate != null) Navigator.pop(context);
    }
  }
}

