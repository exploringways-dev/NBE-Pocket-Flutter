// budget_screen.dart
//
// A single-file Flutter implementation of the Budget screen with a month picker.
// No external packages required — pure Material.
//
// Drop this in lib/ and set `home: const BudgetScreen()` (or run this file directly).

import 'dart:math' as math;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Theme tokens
// ---------------------------------------------------------------------------

class AppColors {
  static const green = Color(0xFF2E5C4A);
  static const greenDeep = Color(0xFF244A3C);
  static const surface = Color(0xFFF4F5F2);
  static const card = Colors.white;
  static const gold = Color(0xFFD9A62E);
  static const orange = Color(0xFFDE7B33);
  static const red = Color(0xFFC0483C);
  static const bar = Color(0xFF3F7A5E);
  static const barDeep = Color(0xFF2A6349);
  static const track = Color(0xFFE9EBE7);
  static const muted = Color(0xFF9AA39F);
  static const ink = Color(0xFF1E2B26);
}

class AppText {
  static const display = TextStyle(
    fontFamily: 'Georgia', // swap for your serif (e.g. Playfair Display)
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.1,
  );
  static const eyebrow = TextStyle(
    fontSize: 13,
    letterSpacing: 1.6,
    fontWeight: FontWeight.w600,
    color: Color(0xCCFFFFFF),
  );
  static const sectionLabel = TextStyle(
    fontSize: 13,
    letterSpacing: 1.6,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );
  static const categoryName = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const amount = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );
}

// ---------------------------------------------------------------------------
// Category icon choices
// ---------------------------------------------------------------------------

class CategoryIconOption {
  const CategoryIconOption(this.key, this.icon, this.tint);

  final String key;
  final IconData icon;
  final Color tint;
}

const _categoryIconChoices = <CategoryIconOption>[
  CategoryIconOption('food', Icons.ramen_dining_outlined, Color(0xFFE07B39)),
  CategoryIconOption(
      'shopping', Icons.shopping_bag_outlined, Color(0xFF3B5FCB)),
  CategoryIconOption(
      'transport', Icons.directions_car_outlined, Color(0xFF2E8B7A)),
  CategoryIconOption(
      'entertainment', Icons.theaters_outlined, Color(0xFF7C5CFC)),
  CategoryIconOption(
      'fitness', Icons.fitness_center_outlined, Color(0xFFD9506B)),
  CategoryIconOption('utilities', Icons.bolt_outlined, Color(0xFFD9A62E)),
  CategoryIconOption('mobile', Icons.smartphone_outlined, Color(0xFF5B6FD6)),
  CategoryIconOption('travel', Icons.flight_outlined, Color(0xFF3AA0C7)),
  CategoryIconOption('home', Icons.home_outlined, Color(0xFF8B5E3C)),
  CategoryIconOption('education', Icons.menu_book_outlined, Color(0xFF4C8C6B)),
  CategoryIconOption('medicine', Icons.medication_outlined, Color(0xFFC0483C)),
  CategoryIconOption(
      'gaming', Icons.sports_esports_outlined, Color(0xFF6B4FA0)),
  CategoryIconOption(
      'groceries', Icons.shopping_cart_outlined, Color(0xFF5B6B63)),
  CategoryIconOption('coffee', Icons.local_cafe_outlined, Color(0xFFA3703E)),
  CategoryIconOption('music', Icons.music_note_outlined, Color(0xFFB0559C)),
  CategoryIconOption('files', Icons.folder_outlined, Color(0xFF6B7280)),
  CategoryIconOption('beauty', Icons.brush_outlined, Color(0xFFD9647A)),
];

CategoryIconOption categoryIconFor(String key) => _categoryIconChoices
    .firstWhere((o) => o.key == key, orElse: () => _categoryIconChoices.first);

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class CategoryTransaction {
  const CategoryTransaction({
    required this.title,
    required this.time,
    required this.amount,
  });

  final String title;
  final String time;
  final double amount;
}

class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.spent,
    required this.limit,
    this.transactions = const [],
  });

  final String id;
  final String name;

  /// Key into [_categoryIconChoices] — resolve with [categoryIconFor].
  final String icon;
  final double spent;
  final double limit;
  final List<CategoryTransaction> transactions;

  double get ratio => limit <= 0 ? 0 : spent / limit;
  int get percent => (ratio * 100).round();
  double get remaining => limit - spent;

  /// Bar colour escalates as the category approaches (and passes) its limit.
  Color get color {
    if (percent >= 100) return AppColors.red;
    if (percent >= 65) return AppColors.orange;
    if (percent >= 60) return AppColors.gold;
    if (percent >= 50) return AppColors.bar;
    return AppColors.barDeep;
  }

  BudgetCategory copyWith({
    String? name,
    String? icon,
    double? spent,
    double? limit,
  }) {
    return BudgetCategory(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      spent: spent ?? this.spent,
      limit: limit ?? this.limit,
      transactions: transactions,
    );
  }
}

class MonthlyBudget {
  const MonthlyBudget({required this.month, required this.categories});

  /// Always normalised to the first day of the month.
  final DateTime month;
  final List<BudgetCategory> categories;

  double get totalSpent =>
      categories.fold<double>(0, (sum, c) => sum + c.spent);
  double get totalLimit =>
      categories.fold<double>(0, (sum, c) => sum + c.limit);
  double get remaining => totalLimit - totalSpent;
  double get ratio => totalLimit <= 0 ? 0 : totalSpent / totalLimit;
  int get percent => (ratio * 100).round();

  bool get isEmpty => categories.isEmpty;
}

// ---------------------------------------------------------------------------
// Data source
// ---------------------------------------------------------------------------
//
// Replace this with your repository / API call. The screen only needs
// `budgetFor(DateTime month)` to return a MonthlyBudget.

class BudgetRepository {
  BudgetRepository();

  static const _template = <BudgetCategory>[
    BudgetCategory(
        id: 'food',
        name: 'Food & Dining',
        icon: 'food',
        spent: 2430,
        limit: 3500,
        transactions: [
          CategoryTransaction(title: 'Uber Eats', time: 'Today', amount: 215),
          CategoryTransaction(
              title: 'KFC Mohandessin', time: 'Yesterday', amount: 180),
          CategoryTransaction(
              title: 'Costa Coffee', time: 'Aug 10', amount: 95),
        ]),
    BudgetCategory(
        id: 'shopping',
        name: 'Shopping',
        icon: 'shopping',
        spent: 1890,
        limit: 3000,
        transactions: [
          CategoryTransaction(title: 'Amazon.eg', time: 'Today', amount: 876),
          CategoryTransaction(
              title: 'Carrefour', time: 'Yesterday', amount: 432.5),
          CategoryTransaction(title: 'H&M', time: 'Aug 9', amount: 310),
        ]),
    BudgetCategory(
        id: 'transport',
        name: 'Transport',
        icon: 'transport',
        spent: 680,
        limit: 1500,
        transactions: [
          CategoryTransaction(title: 'Uber', time: 'Today', amount: 120),
          CategoryTransaction(
              title: 'Gas Station', time: 'Aug 11', amount: 300),
          CategoryTransaction(title: 'Parking', time: 'Aug 8', amount: 40),
        ]),
    BudgetCategory(
        id: 'entertainment',
        name: 'Entertainment',
        icon: 'entertainment',
        spent: 540,
        limit: 1000,
        transactions: [
          CategoryTransaction(title: 'Netflix', time: 'Today', amount: 149.99),
          CategoryTransaction(title: 'Cinema', time: 'Aug 12', amount: 220),
        ]),
    BudgetCategory(
        id: 'health',
        name: 'Health & Fitness',
        icon: 'fitness',
        spent: 320,
        limit: 800,
        transactions: [
          CategoryTransaction(
              title: 'Gym Membership', time: 'Aug 1', amount: 250),
          CategoryTransaction(title: 'Pharmacy', time: 'Aug 6', amount: 70),
        ]),
    BudgetCategory(
        id: 'utilities',
        name: 'Utilities',
        icon: 'utilities',
        spent: 1260,
        limit: 1800,
        transactions: [
          CategoryTransaction(
              title: 'Electricity Bill', time: 'Aug 5', amount: 610),
          CategoryTransaction(title: 'Internet', time: 'Aug 3', amount: 350),
          CategoryTransaction(title: 'Water Bill', time: 'Aug 2', amount: 300),
        ]),
  ];

  final Map<String, MonthlyBudget> _cache = {};

  static String _key(DateTime m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  MonthlyBudget budgetFor(DateTime month) {
    final normalised = DateTime(month.year, month.month);
    return _cache.putIfAbsent(_key(normalised), () => _generate(normalised));
  }

  void save(MonthlyBudget budget) {
    _cache[_key(budget.month)] = budget;
  }

  /// Demo data: August 2026 matches the design exactly, other months get
  /// deterministic variation so switching months visibly changes the screen.
  MonthlyBudget _generate(DateTime month) {
    if (month.year == 2026 && month.month == 8) {
      return MonthlyBudget(month: month, categories: _template);
    }

    final now = DateTime.now();
    final isFuture = month.isAfter(DateTime(now.year, now.month));
    final rand = math.Random(month.year * 100 + month.month);

    final categories = _template.map((c) {
      if (isFuture) return c.copyWith(spent: 0); // planned, nothing spent yet
      final factor = 0.35 + rand.nextDouble() * 0.75; // 35%–110% of the limit
      return c.copyWith(spent: (c.limit * factor / 10).round() * 10);
    }).toList();

    return MonthlyBudget(month: month, categories: categories);
  }
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String monthLabel(DateTime m) => '${_monthNames[m.month - 1]} ${m.year}';

String money(num value) {
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}EGP ${buffer.toString()}';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _repo = BudgetRepository();

  /// The month currently on screen. Normalised to day 1.
  late DateTime _selectedMonth;

  /// The furthest month a user is allowed to open.
  /// Bump this to `+1` month if you want forward planning.
  late final DateTime _lastAllowedMonth;
  final DateTime _firstAllowedMonth = DateTime(2024, 1);

  String? _expandedId;

  @override
  void initState() {
    super.initState();
    // Demo pins "today" to the design's month. In production use DateTime.now().
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _lastAllowedMonth = DateTime(now.year, now.month);
  }

  MonthlyBudget get _budget => _repo.budgetFor(_selectedMonth);

  bool get _canGoBack => _selectedMonth.isAfter(_firstAllowedMonth);
  bool get _canGoForward => _selectedMonth.isBefore(_lastAllowedMonth);
  bool get _isCurrentMonth => _selectedMonth == _lastAllowedMonth;

  void _shiftMonth(int delta) {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    if (next.isBefore(_firstAllowedMonth) || next.isAfter(_lastAllowedMonth)) {
      return;
    }
    setState(() {
      _selectedMonth = next;
      _expandedId = null;
    });
  }

  Future<void> _openMonthPicker() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MonthPickerSheet(
        selected: _selectedMonth,
        firstAllowed: _firstAllowedMonth,
        lastAllowed: _lastAllowedMonth,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _expandedId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final budget = _budget;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                topInset: topInset,
                month: _selectedMonth,
                budget: budget,
                canGoBack: _canGoBack,
                canGoForward: _canGoForward,
                isCurrentMonth: _isCurrentMonth,
                onPrevious: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
                onTapMonth: _openMonthPicker,
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text('CATEGORIES', style: AppText.sectionLabel),
              ),
            ),
            SliverList.builder(
              itemCount: budget.categories.length,
              itemBuilder: (context, index) {
                final category = budget.categories[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: CategoryCard(
                    key: ValueKey(
                        '${monthLabel(_selectedMonth)}-${category.id}'),
                    category: category,
                    expanded: _expandedId == category.id,
                    onToggle: () => setState(() {
                      _expandedId =
                          _expandedId == category.id ? null : category.id;
                    }),
                    onAction: (action) =>
                        _handleCategoryAction(category, action),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: _NewCategoryButton(onTap: _addCategory),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),

        // Keeps the status bar area green while the header scrolls away.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(height: topInset, color: const Color(0xFF1F4033)),
        ),
      ],
    );
  }

  void _handleCategoryAction(BudgetCategory category, String action) {
    switch (action) {
      case 'edit':
        _editCategory(category);
        break;
      case 'removeLimit':
        _updateCategory(category.copyWith(limit: 0));
        break;
      case 'delete':
        setState(() {
          final updated =
              _budget.categories.where((c) => c.id != category.id).toList();
          _repo.save(MonthlyBudget(month: _selectedMonth, categories: updated));
        });
        break;
    }
  }

  void _updateCategory(BudgetCategory updated) {
    setState(() {
      final categories = _budget.categories
          .map((c) => c.id == updated.id ? updated : c)
          .toList();
      _repo.save(MonthlyBudget(month: _selectedMonth, categories: categories));
    });
  }

  Future<void> _editCategory(BudgetCategory category) async {
    final result = await showModalBottomSheet<BudgetCategory>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditCategorySheet(category: category),
    );
    if (result != null) _updateCategory(result);
  }

  Future<void> _addCategory() async {
    final result = await showModalBottomSheet<BudgetCategory>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _EditCategorySheet(),
    );
    if (result == null) return;

    setState(() {
      final categories = [..._budget.categories, result];
      _repo.save(MonthlyBudget(month: _selectedMonth, categories: categories));
    });
  }
}

// ---------------------------------------------------------------------------
// Header + summary
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.topInset,
    required this.month,
    required this.budget,
    required this.canGoBack,
    required this.canGoForward,
    required this.isCurrentMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onTapMonth,
  });

  final double topInset;
  final DateTime month;
  final MonthlyBudget budget;
  final bool canGoBack;
  final bool canGoForward;
  final bool isCurrentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTapMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1F4033),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, topInset + 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              'My Budget',
              textAlign: TextAlign.center,
              style: AppText.display,
            ),
          ),
          const SizedBox(height: 10),
          // ---- Month selector row -------------------------------------
          Row(
            children: [
              _ArrowButton(
                icon: Icons.chevron_left_rounded,
                enabled: canGoBack,
                onTap: onPrevious,
                tooltip: 'Previous month',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  onTap: onTapMonth,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            monthLabel(month).toUpperCase(),
                            style: AppText.eyebrow,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20, color: Color(0xCCFFFFFF)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _ArrowButton(
                icon: Icons.chevron_right_rounded,
                enabled: canGoForward,
                onTap: onNext,
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SummaryCard(budget: budget),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: 22,
        child: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: enabled ? 0.14 : 0.05),
          ),
          child: Icon(
            icon,
            size: 22,
            color: Colors.white.withValues(alpha: enabled ? 0.95 : 0.28),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.budget});

  final MonthlyBudget budget;

  @override
  Widget build(BuildContext context) {
    final over = budget.remaining < 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProgressRing(
            // Key forces the tween to replay when the month changes.
            key: ValueKey(monthLabel(budget.month)),
            value: budget.ratio.clamp(0.0, 1.0),
            label: '${budget.percent}%',
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL SPENDING',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  money(budget.totalSpent),
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'of ${money(budget.totalLimit)} budget',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  over
                      ? '${money(budget.remaining.abs())} over budget'
                      : '${money(budget.remaining)} left to spend',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: over
                        ? AppColors.red
                        : Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({super.key, required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return SizedBox(
          height: 108,
          width: 108,
          child: CustomPaint(
            painter: _RingPainter(
              progress: animated,
              color: value >= 1 ? AppColors.red : AppColors.gold,
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.16);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------------------------------------------------------------------
// Category card
// ---------------------------------------------------------------------------

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.expanded,
    required this.onToggle,
    required this.onAction,
  });

  final BudgetCategory category;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final option = categoryIconFor(category.icon);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E2B26),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: option.tint.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(option.icon, color: option.tint, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: AppText.categoryName),
                          const SizedBox(height: 3),
                          Text(
                            '${money(category.spent)} / ${money(category.limit)}',
                            style: AppText.amount,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${category.percent}%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: category.percent >= 100
                            ? AppColors.red
                            : AppColors.green,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: onAction,
                      icon: const Icon(Icons.more_vert_rounded,
                          size: 20, color: AppColors.muted),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Category'),
                        ),
                        PopupMenuItem(
                          value: 'removeLimit',
                          child: Text('Remove Limit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Remove Category',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                      ],
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.muted),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ProgressBar(
                    value: category.ratio,
                    color: category.color,
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: _CategoryDetails(category: category),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animated,
            minHeight: 8,
            backgroundColor: AppColors.track,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );
      },
    );
  }
}

class _CategoryDetails extends StatelessWidget {
  const _CategoryDetails({required this.category});

  final BudgetCategory category;

  @override
  Widget build(BuildContext context) {
    final over = category.remaining < 0;
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppColors.track),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stat(
                label: over ? 'Over budget' : 'Left to spend',
                value: money(category.remaining.abs()),
                color: over ? AppColors.red : AppColors.green,
              ),
              const SizedBox(width: 40),
              _Stat(
                label: 'Daily average',
                value: money(category.spent / 30),
                color: AppColors.ink,
              ),
            ],
          ),
          if (category.transactions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  for (var i = 0; i < category.transactions.length; i++)
                    _CategoryTransactionTile(
                      transaction: category.transactions[i],
                      showDivider: i != category.transactions.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTransactionTile extends StatelessWidget {
  const _CategoryTransactionTile({
    required this.transaction,
    this.showDivider = true,
  });

  final CategoryTransaction transaction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title,
                        style: AppText.categoryName.copyWith(fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(transaction.time,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Text(
                money(transaction.amount),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.track),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 15.5, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _NewCategoryButton extends StatelessWidget {
  const _NewCategoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: const SizedBox(
          height: 62,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: AppColors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'New Category',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.muted.withValues(alpha: 0.55);

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    final path = Path()..addRRect(rrect);

    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Edit category sheet
// ---------------------------------------------------------------------------

class _EditCategorySheet extends StatefulWidget {
  const _EditCategorySheet({this.category});

  /// Null when adding a brand-new category.
  final BudgetCategory? category;

  @override
  State<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<_EditCategorySheet> {
  late String _icon = widget.category?.icon ?? _categoryIconChoices.first.key;
  late final _nameController =
      TextEditingController(text: widget.category?.name ?? '');
  late final _limitController = TextEditingController(
      text: widget.category != null
          ? widget.category!.limit.round().toString()
          : '');

  bool get _isNew => widget.category == null;

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final limit = double.tryParse(_limitController.text.trim());
    if (name.isEmpty || limit == null || limit <= 0) return;

    final category = widget.category;
    final result = category != null
        ? category.copyWith(
            name: name,
            icon: _icon,
            limit: limit,
          )
        : BudgetCategory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            icon: _icon,
            spent: 0,
            limit: limit,
          );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.track,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isNew ? 'Add Category' : 'Edit Category',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child:
                            Icon(Icons.close, size: 22, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const _FieldLabel('CHOOSE ICON'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in _categoryIconChoices)
                      _IconChoice(
                        option: option,
                        selected: option.key == _icon,
                        onTap: () => setState(() => _icon = option.key),
                      ),
                  ],
                ),
                const _FieldLabel('CATEGORY NAME'),
                _EditField(controller: _nameController),
                const _FieldLabel('MONTHLY LIMIT (EGP)'),
                _EditField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.muted,
                          side: BorderSide.none,
                          backgroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(text, style: AppText.sectionLabel),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    this.keyboardType,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CategoryIconOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: option.tint.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? option.tint : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(option.icon, color: option.tint, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month picker sheet
// ---------------------------------------------------------------------------

class MonthPickerSheet extends StatefulWidget {
  const MonthPickerSheet({
    super.key,
    required this.selected,
    required this.firstAllowed,
    required this.lastAllowed,
  });

  final DateTime selected;
  final DateTime firstAllowed;
  final DateTime lastAllowed;

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.selected.year;
  }

  bool _isAllowed(int month) {
    final candidate = DateTime(_year, month);
    return !candidate.isBefore(widget.firstAllowed) &&
        !candidate.isAfter(widget.lastAllowed);
  }

  bool get _canPrevYear => _year > widget.firstAllowed.year;
  bool get _canNextYear => _year < widget.lastAllowed.year;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.track,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Select month',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 18),

          // ---- Year stepper -------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed:
                      _canPrevYear ? () => setState(() => _year--) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: AppColors.green,
                ),
                Text(
                  '$_year',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  onPressed:
                      _canNextYear ? () => setState(() => _year++) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: AppColors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---- Month grid ---------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final enabled = _isAllowed(month);
                final isSelected = widget.selected.year == _year &&
                    widget.selected.month == month;

                return Material(
                  color: isSelected ? AppColors.green : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: enabled
                        ? () => Navigator.pop(context, DateTime(_year, month))
                        : null,
                    child: Center(
                      child: Text(
                        _monthShort[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : enabled
                                  ? AppColors.ink
                                  : AppColors.muted.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ---- Jump to current month ----------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context, widget.lastAllowed),
                child: Text('Go to ${monthLabel(widget.lastAllowed)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
