import 'package:flutter/material.dart';

import 'main_screen.dart' show AppColors;

// ---------------------------------------------------------------------------
// Palette (page-local accents; base greens come from AppColors in main.dart)
// ---------------------------------------------------------------------------

class GoalPalette {
  static const canvas = Color(0xFFF5F6F5);
  static const card = Colors.white;
  static const ink = Color(0xFF1E1E1E);

  static const amber = Color(0xFFE08A2E);
  static const amberLight = Color(0xFFF3B33D);
  static const amberBg = Color(0xFFFBEFD9);
  static const amberText = Color(0xFFC98A2E);

  static const lockBg = Color(0xFFE4EDE7);
  static const track = Color(0xFFE6E9E5);
  static const field = Color(0xFFEDF1EC);
  static const hairline = Color(0xFFECEFEB);
  static const faint = Color(0xFFAAB0AA);
}

const _numeric = TextStyle(fontFamily: 'monospace');

String egp(num v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'EGP ${v < 0 ? '-' : ''}$buf';
}

// ---------------------------------------------------------------------------
// Goal icon choices (same tinted-icon-tile pattern as the budget page)
// ---------------------------------------------------------------------------

class GoalIconOption {
  const GoalIconOption(this.key, this.icon, this.tint);

  final String key;
  final IconData icon;
  final Color tint;
}

const kGoalIconChoices = <GoalIconOption>[
  GoalIconOption('flight', Icons.flight_outlined, Color(0xFF3AA0C7)),
  GoalIconOption('shield', Icons.shield_outlined, Color(0xFF2E8B7A)),
  GoalIconOption('bank', Icons.account_balance_outlined, Color(0xFF8B5E3C)),
  GoalIconOption('laptop', Icons.laptop_mac_outlined, Color(0xFF5B6FD6)),
  GoalIconOption('car', Icons.directions_car_outlined, Color(0xFF2E5C4A)),
  GoalIconOption('home', Icons.home_outlined, Color(0xFFD9A62E)),
  GoalIconOption('education', Icons.menu_book_outlined, Color(0xFF4C8C6B)),
  GoalIconOption('graduation', Icons.school_outlined, Color(0xFF6B4FA0)),
  GoalIconOption('mosque', Icons.mosque_outlined, Color(0xFF2E5C4A)),
  GoalIconOption('ring', Icons.diamond_outlined, Color(0xFFB0559C)),
  GoalIconOption('beach', Icons.beach_access_outlined, Color(0xFF3AA0C7)),
  GoalIconOption('target', Icons.track_changes_outlined, Color(0xFFD9647A)),
  GoalIconOption('medicine', Icons.medication_outlined, Color(0xFFC0483C)),
  GoalIconOption('gift', Icons.card_giftcard_outlined, Color(0xFFD9506B)),
  GoalIconOption('sports', Icons.sports_soccer_outlined, Color(0xFF3B5FCB)),
  GoalIconOption('globe', Icons.public_outlined, Color(0xFF2E8B7A)),
  GoalIconOption('beauty', Icons.brush_outlined, Color(0xFFD9647A)),
];

GoalIconOption goalIconFor(String key) => kGoalIconChoices.firstWhere(
      (o) => o.key == key,
      orElse: () => kGoalIconChoices.first,
    );

const _months = [
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

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

enum GoalType { mandatory, flexible }

enum Cadence { monthly, weekly }

class SavingsGoal {
  SavingsGoal({
    required this.id,
    required this.icon,
    required this.name,
    required this.target,
    required this.saved,
    required this.type,
    required this.targetMonth,
    required this.targetYear,
    required this.cardLabel,
    this.installment,
    this.cadence = Cadence.monthly,
  });

  final String id;
  String icon;
  String name;
  double target;
  double saved;
  GoalType type;
  int targetMonth; // 1-12
  int targetYear;
  String cardLabel;
  double? installment;
  Cadence cadence;

  bool get isLocked => type == GoalType.mandatory;
  bool get hasPlan => installment != null && installment! > 0;
  double get remaining => (target - saved).clamp(0, double.infinity);
  double get progress => target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
  String get targetLabel => '${_months[targetMonth - 1]} $targetYear';

  int get monthsLeft {
    final now = DateTime.now();
    final months = (targetYear - now.year) * 12 + (targetMonth - now.month);
    return months < 0 ? 0 : months;
  }

  /// Amount that must land each month to finish on time.
  double get requiredMonthly =>
      monthsLeft == 0 ? remaining : remaining / monthsLeft;

  double get plannedMonthly {
    if (!hasPlan) return 0;
    return cadence == Cadence.weekly ? installment! * 52 / 12 : installment!;
  }

  /// null = no plan set, so there is nothing to be on or off track against.
  bool? get onTrack {
    if (!hasPlan) return null;
    return plannedMonthly + 0.5 >= requiredMonthly;
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  GoalType _tab = GoalType.mandatory;
  String? _expandedId;

  final List<SavingsGoal> _goals = [
    SavingsGoal(
      id: 'hajj',
      icon: 'mosque',
      name: 'Hajj Fund',
      target: 120000,
      saved: 45000,
      type: GoalType.mandatory,
      targetMonth: 6,
      targetYear: 2028,
      cardLabel: 'NBE Classic ••4821 (Debit)',
      installment: 3000,
    ),
    SavingsGoal(
      id: 'edu',
      icon: 'graduation',
      name: "Children's Education",
      target: 200000,
      saved: 82000,
      type: GoalType.mandatory,
      targetMonth: 9,
      targetYear: 2030,
      cardLabel: 'NBE Classic ••4821 (Debit)',
      installment: 2500,
    ),
    SavingsGoal(
      id: 'ret',
      icon: 'bank',
      name: 'Retirement Reserve',
      target: 1000000,
      saved: 310000,
      type: GoalType.mandatory,
      targetMonth: 1,
      targetYear: 2045,
      cardLabel: 'NBE Titanium ••7702 (Debit)',
      installment: 3500,
    ),
    SavingsGoal(
      id: 'japan',
      icon: 'flight',
      name: 'Japan Vacation',
      target: 45000,
      saved: 22400,
      type: GoalType.flexible,
      targetMonth: 12,
      targetYear: 2026,
      cardLabel: 'NBE Classic ••4821 (Debit)',
      installment: 4000,
    ),
    SavingsGoal(
      id: 'mac',
      icon: 'laptop',
      name: 'MacBook Pro',
      target: 18000,
      saved: 12600,
      type: GoalType.flexible,
      targetMonth: 10,
      targetYear: 2026,
      cardLabel: 'NBE Classic ••4821 (Debit)',
    ),
  ];

  List<SavingsGoal> get _visible =>
      _goals.where((g) => g.type == _tab).toList();

  double get _totalSaved => _visible.fold(0.0, (sum, g) => sum + g.saved);

  double get _totalTarget => _visible.fold(0.0, (sum, g) => sum + g.target);

  Color get _accent =>
      _tab == GoalType.mandatory ? AppColors.darkGreen : GoalPalette.amber;

  void _openNewGoal() async {
    final created = await showModalBottomSheet<SavingsGoal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewGoalSheet(initialType: _tab),
    );
    if (created != null && mounted) {
      setState(() {
        _goals.add(created);
        _tab = created.type;
        _expandedId = created.id;
      });
    }
  }

  void _deposit(SavingsGoal goal, double amount) {
    setState(() => goal.saved =
        (goal.saved + amount).clamp(0, double.infinity).toDouble());
  }

  void _withdraw(SavingsGoal goal, double amount) {
    setState(() => goal.saved =
        (goal.saved - amount).clamp(0, double.infinity).toDouble());
  }

  void _delete(SavingsGoal goal) {
    setState(() => _goals.removeWhere((g) => g.id == goal.id));
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Container(
      color: GoalPalette.canvas,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  tab: _tab,
                  onTab: (t) => setState(() {
                    _tab = t;
                    _expandedId = null;
                  }),
                  totalSaved: _totalSaved,
                  totalTarget: _totalTarget,
                  count: list.length,
                ),
              ),
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onAdd: _openNewGoal),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                  sliver: SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final goal = list[i];
                      return GoalCard(
                        goal: goal,
                        expanded: _expandedId == goal.id,
                        onToggle: () => setState(() => _expandedId =
                            _expandedId == goal.id ? null : goal.id),
                        onDeposit: (amt) => _deposit(goal, amt),
                        onWithdraw: (amt) => _withdraw(goal, amt),
                        onDelete: () => _delete(goal),
                        onEdit: () => setState(() {}),
                      );
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton.extended(
              onPressed: _openNewGoal,
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Goal',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: eyebrow, title, segmented tabs, totals card
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.tab,
    required this.onTab,
    required this.totalSaved,
    required this.totalTarget,
    required this.count,
  });

  final GoalType tab;
  final ValueChanged<GoalType> onTab;
  final double totalSaved;
  final double totalTarget;
  final int count;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalTarget <= 0 ? 0.0 : (totalSaved / totalTarget).clamp(0.0, 1.0);
    final label = tab == GoalType.mandatory ? 'MANDATORY' : 'FLEXIBLE';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGreen, AppColors.midGreen],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 14, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                'My Goals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _TypeToggle(value: tab, onChanged: onTab),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label — TOTAL SAVED',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          egp(totalSaved),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'of ${egp(totalTarget)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 7,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress == 0 ? 0.001 : progress,
                          child: Container(
                            height: 7,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  GoalPalette.amberLight,
                                  GoalPalette.amber,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    count == 1 ? '1 goal' : '$count goals',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});

  final GoalType value;
  final ValueChanged<GoalType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _segment('Mandatory', Icons.lock_outline_rounded, GoalType.mandatory),
          _segment('Flexible', Icons.lock_open_outlined, GoalType.flexible),
        ],
      ),
    );
  }

  Widget _segment(String label, IconData icon, GoalType type) {
    final selected = value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? AppColors.darkGreen : Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.darkGreen : Colors.white,
                  fontSize: 15,
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

// ---------------------------------------------------------------------------
// Goal card (collapsed row + expanded detail)
// ---------------------------------------------------------------------------

class GoalCard extends StatefulWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.expanded,
    required this.onToggle,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onDelete,
    required this.onEdit,
  });

  final SavingsGoal goal;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<double> onDeposit;
  final ValueChanged<double> onWithdraw;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit(bool deposit) {
    final v = double.tryParse(_amount.text.trim());
    if (v == null || v <= 0) return;
    deposit ? widget.onDeposit(v) : widget.onWithdraw(v);
    _amount.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    final accent = g.isLocked ? AppColors.darkGreen : GoalPalette.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: GoalPalette.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GoalIcon(
                          option: goalIconFor(g.icon), locked: g.isLocked),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: GoalPalette.ink,
                              ),
                            ),
                            if (g.isLocked || g.hasPlan) ...[
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (g.isLocked)
                                    const _Chip(
                                      label: 'LOCKED',
                                      bg: GoalPalette.lockBg,
                                      fg: AppColors.darkGreen,
                                    ),
                                  if (g.hasPlan)
                                    _Chip(
                                      label: g.cadence == Cadence.weekly
                                          ? 'WEEKLY'
                                          : 'MONTHLY',
                                      bg: GoalPalette.amberBg,
                                      fg: GoalPalette.amberText,
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '${g.monthsLeft} months',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const Text(
                                  '  ·  ',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  g.targetLabel,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${g.percent}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      _GoalMenu(
                        goal: g,
                        onDelete: widget.onDelete,
                        onEdit: widget.onEdit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Bar(progress: g.progress, locked: g.isLocked),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${egp(g.saved)} saved',
                        style: _numeric.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${egp(g.remaining)} to go',
                        style: _numeric.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: widget.expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _expandedBody(g, accent),
          ),
        ],
      ),
    );
  }

  Widget _expandedBody(SavingsGoal g, Color accent) {
    final track = g.onTrack;
    final trackLabel = track == null
        ? 'Manual'
        : track
            ? 'On track'
            : 'At risk';
    final trackColor = track == null
        ? AppColors.textMuted
        : track
            ? AppColors.darkGreen
            : GoalPalette.amber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: GoalPalette.hairline),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      label: g.cadence == Cadence.weekly ? 'WEEKLY' : 'MONTHLY',
                      value: g.hasPlan ? egp(g.installment!) : '—',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Stat(
                      label: 'MONTHS',
                      value: '${g.monthsLeft}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Stat(
                      label: 'TRACK',
                      value: trackLabel,
                      valueColor: trackColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (g.isLocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: GoalPalette.field,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 17, color: AppColors.darkGreen),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Locked — deposits only. Withdrawals not allowed.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (g.isLocked) const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: _numeric.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Amount in EGP...',
                        hintStyle: _numeric.copyWith(
                          fontSize: 14,
                          color: GoalPalette.faint,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 15),
                        filled: true,
                        fillColor: GoalPalette.card,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: GoalPalette.track),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.darkGreen),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _submit(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              if (!g.isLocked) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _submit(false),
                    icon: const Icon(Icons.north_east, size: 16),
                    label: const Text('Withdraw this amount'),
                    style: TextButton.styleFrom(
                      foregroundColor: GoalPalette.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalIcon extends StatelessWidget {
  const _GoalIcon({required this.option, required this.locked});

  final GoalIconOption option;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: option.tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(option.icon, color: option.tint, size: 22),
          ),
          if (locked)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: GoalPalette.lockBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.lock,
                    size: 10, color: AppColors.darkGreen),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.progress, required this.locked});

  final double progress;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Container(height: 7, color: GoalPalette.track),
          FractionallySizedBox(
            widthFactor: progress == 0 ? 0.001 : progress,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: locked
                      ? const [AppColors.midGreen, AppColors.darkGreen]
                      : const [GoalPalette.amberLight, GoalPalette.amber],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: fg,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.valueColor = GoalPalette.ink,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: GoalPalette.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: _numeric.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalMenu extends StatelessWidget {
  const _GoalMenu({
    required this.goal,
    required this.onDelete,
    required this.onEdit,
  });

  final SavingsGoal goal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFFB5B5AD)),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) async {
        if (v == 'edit') {
          final saved = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => EditGoalSheet(goal: goal),
          );
          if (saved == true) onEdit();
          return;
        }
        if (v == 'delete') {
          if (goal.isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mandatory goals can only be closed at branch.'),
              ),
            );
            return;
          }
          onDelete();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Goal')),
        const PopupMenuItem(
          value: 'delete',
          child: Text(
            'End Goal',
            style: TextStyle(color: Color(0xFFC0392B)),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 12),
          const Text(
            'No goals here yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: GoalPalette.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set a target and start putting money aside.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
            child: const Text('Create a goal'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New goal sheet
// ---------------------------------------------------------------------------

class BankCard {
  const BankCard(this.label, {this.isCredit = false});
  final String label;
  final bool isCredit;
}

const kCards = [
  BankCard('NBE Classic ••4821 (Debit)'),
  BankCard('NBE Titanium ••7702 (Debit)'),
  BankCard('NBE Platinum ••3391 (Credit)', isCredit: true),
];

class NewGoalSheet extends StatefulWidget {
  const NewGoalSheet({super.key, required this.initialType});

  final GoalType initialType;

  @override
  State<NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends State<NewGoalSheet> {
  late GoalType _type = widget.initialType;
  String _icon = 'target';
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _installment = TextEditingController();

  int _month = DateTime.now().month;
  int _year = DateTime.now().year + 1;
  String _withdrawCard = kCards.first.label;
  String _deductCard = kCards.first.label;
  bool _autoDeduct = true;
  Cadence _cadence = Cadence.monthly;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _installment.dispose();
    super.dispose();
  }

  void _create() {
    final name = _name.text.trim();
    final target = double.tryParse(_target.text.trim());
    final installment = double.tryParse(_installment.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Give the goal a name.');
      return;
    }
    if (target == null || target <= 0) {
      setState(() => _error = 'Enter a target amount above zero.');
      return;
    }
    final now = DateTime.now();
    if (_year < now.year || (_year == now.year && _month <= now.month)) {
      setState(() => _error = 'Pick a target period in the future.');
      return;
    }
    if (_autoDeduct && (installment == null || installment <= 0)) {
      setState(() => _error = 'Enter the amount to deduct each period.');
      return;
    }

    Navigator.pop(
      context,
      SavingsGoal(
        id: 'g${DateTime.now().microsecondsSinceEpoch}',
        icon: _icon,
        name: name,
        target: target,
        saved: 0,
        type: _type,
        targetMonth: _month,
        targetYear: _year,
        cardLabel: _withdrawCard,
        installment: _autoDeduct ? installment : null,
        cadence: _cadence,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 6),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'New Goal',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: GoalPalette.ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      size: 22, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 20 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sheetTypeToggle(),
                  const SizedBox(height: 20),
                  const _Label('CHOOSE ICON'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kGoalIconChoices.map((option) {
                      final selected = option.key == _icon;
                      return GestureDetector(
                        onTap: () => setState(() => _icon = option.key),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: option.tint.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  selected ? option.tint : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child:
                              Icon(option.icon, color: option.tint, size: 22),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  _field(controller: _name, hint: 'Goal name'),
                  const SizedBox(height: 10),
                  _field(
                    controller: _target,
                    hint: 'Target amount in EGP',
                    numeric: true,
                  ),
                  const SizedBox(height: 18),
                  const _Label('TARGET PERIOD'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdown<int>(
                          value: _month,
                          items: List.generate(12, (i) => i + 1),
                          labelOf: (m) => _months[m - 1],
                          onChanged: (m) => setState(() => _month = m!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dropdown<int>(
                          value: _year,
                          items:
                              List.generate(20, (i) => DateTime.now().year + i),
                          labelOf: (y) => '$y',
                          onChanged: (y) => setState(() => _year = y!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _Label('WITHDRAW FROM CARD'),
                  const SizedBox(height: 8),
                  _dropdown<String>(
                    value: _withdrawCard,
                    items: kCards.map((c) => c.label).toList(),
                    labelOf: (c) => c,
                    disabled: kCards
                        .where((c) => c.isCredit)
                        .map((c) => c.label)
                        .toSet(),
                    onChanged: (c) => setState(() => _withdrawCard = c!),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Credit cards cannot be used for goal deposits.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: GoalPalette.field,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Installments',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: GoalPalette.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Auto-deduct a fixed amount each month',
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoDeduct,
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.darkGreen,
                          onChanged: (v) => setState(() => _autoDeduct = v),
                        ),
                      ],
                    ),
                  ),
                  if (_autoDeduct) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GoalPalette.field,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('FREQUENCY'),
                          const SizedBox(height: 8),
                          _cadenceToggle(),
                          const SizedBox(height: 16),
                          const _Label('AMOUNT PER INSTALLMENT (EGP)'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _installment,
                            hint: 'e.g. 1000',
                            numeric: true,
                            fill: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const _Label('DEDUCT FROM CARD'),
                          const SizedBox(height: 8),
                          _dropdown<String>(
                            value: _deductCard,
                            items: kCards.map((c) => c.label).toList(),
                            labelOf: (c) => c,
                            fill: Colors.white,
                            disabled: kCards
                                .where((c) => c.isCredit)
                                .map((c) => c.label)
                                .toSet(),
                            onChanged: (c) => setState(() => _deductCard = c!),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: Color(0xFFC0392B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFC0392B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Create Goal',
                        style: TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetTypeToggle() {
    Widget seg(String label, IconData icon, GoalType t) {
      final selected = _type == t;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _type = t),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? (t == GoalType.flexible
                      ? GoalPalette.amber
                      : AppColors.darkGreen)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 15,
                    color: selected ? Colors.white : AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: GoalPalette.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          seg('Flexible', Icons.lock_open_outlined, GoalType.flexible),
          seg('Mandatory', Icons.lock_outline_rounded, GoalType.mandatory),
        ],
      ),
    );
  }

  Widget _cadenceToggle() {
    Widget seg(String label, Cadence c) {
      final selected = _cadence == c;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _cadence = c),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.darkGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkGreen,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          seg('Monthly', Cadence.monthly),
          seg('Weekly', Cadence.weekly),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool numeric = false,
    Color fill = GoalPalette.field,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      style: numeric
          ? _numeric.copyWith(fontSize: 15)
          : const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: (numeric ? _numeric : const TextStyle()).copyWith(
          fontSize: 15,
          color: GoalPalette.faint,
        ),
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoalPalette.track),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
    Set<T> disabled = const {},
    Color fill = GoalPalette.field,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GoalPalette.track),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          icon:
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          style: const TextStyle(fontSize: 15, color: GoalPalette.ink),
          padding: const EdgeInsets.symmetric(vertical: 6),
          items: items.map((item) {
            final off = disabled.contains(item);
            return DropdownMenuItem<T>(
              value: item,
              enabled: !off,
              child: Text(
                labelOf(item),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: off ? GoalPalette.faint : GoalPalette.ink,
                ),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v == null || disabled.contains(v)) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit goal sheet
// ---------------------------------------------------------------------------

class EditGoalSheet extends StatefulWidget {
  const EditGoalSheet({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  State<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<EditGoalSheet> {
  late final _target =
      TextEditingController(text: widget.goal.target.round().toString());
  late final _installment = TextEditingController(
      text: widget.goal.installment?.round().toString() ?? '');
  late int _month = widget.goal.targetMonth;
  late int _year = widget.goal.targetYear;
  late String _withdrawCard = widget.goal.cardLabel;
  late String _deductCard = widget.goal.cardLabel;
  late bool _autoDeduct = widget.goal.hasPlan;
  late Cadence _cadence = widget.goal.cadence;
  String? _error;

  @override
  void dispose() {
    _target.dispose();
    _installment.dispose();
    super.dispose();
  }

  void _save() {
    final target = double.tryParse(_target.text.trim());
    final installment = double.tryParse(_installment.text.trim());

    if (target == null || target <= 0) {
      setState(() => _error = 'Enter a target amount above zero.');
      return;
    }
    if (_autoDeduct && (installment == null || installment <= 0)) {
      setState(() => _error = 'Enter the amount to deduct each period.');
      return;
    }

    widget.goal
      ..target = target
      ..targetMonth = _month
      ..targetYear = _year
      ..cardLabel = _withdrawCard
      ..installment = _autoDeduct ? installment : null
      ..cadence = _cadence;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 6),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Goal',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: GoalPalette.ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      size: 22, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 20 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.goal.isLocked) ...[
                    const _Label('TARGET AMOUNT (EGP)'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _target,
                      hint: 'e.g. 50000',
                      numeric: true,
                    ),
                    const SizedBox(height: 18),
                    const _Label('TARGET PERIOD'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown<int>(
                            value: _month,
                            items: List.generate(12, (i) => i + 1),
                            labelOf: (m) => _months[m - 1],
                            onChanged: (m) => setState(() => _month = m!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdown<int>(
                            value: _year,
                            items: List.generate(
                                20, (i) => DateTime.now().year - 5 + i),
                            labelOf: (y) => '$y',
                            onChanged: (y) => setState(() => _year = y!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                  const _Label('WITHDRAW FROM CARD'),
                  const SizedBox(height: 8),
                  _dropdown<String>(
                    value: _withdrawCard,
                    items: kCards.map((c) => c.label).toList(),
                    labelOf: (c) => c,
                    disabled: kCards
                        .where((c) => c.isCredit)
                        .map((c) => c.label)
                        .toSet(),
                    onChanged: (c) => setState(() => _withdrawCard = c!),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Credit cards cannot be used for goal deposits.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: GoalPalette.field,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Installments',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: GoalPalette.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Auto-deduct a fixed amount each month',
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoDeduct,
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.darkGreen,
                          onChanged: (v) => setState(() => _autoDeduct = v),
                        ),
                      ],
                    ),
                  ),
                  if (_autoDeduct) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GoalPalette.field,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('FREQUENCY'),
                          const SizedBox(height: 8),
                          _cadenceToggle(),
                          const SizedBox(height: 16),
                          const _Label('AMOUNT PER INSTALLMENT (EGP)'),
                          const SizedBox(height: 8),
                          _field(
                            controller: _installment,
                            hint: 'e.g. 1000',
                            numeric: true,
                            fill: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const _Label('DEDUCT FROM CARD'),
                          const SizedBox(height: 8),
                          _dropdown<String>(
                            value: _deductCard,
                            items: kCards.map((c) => c.label).toList(),
                            labelOf: (c) => c,
                            fill: Colors.white,
                            disabled: kCards
                                .where((c) => c.isCredit)
                                .map((c) => c.label)
                                .toSet(),
                            onChanged: (c) => setState(() => _deductCard = c!),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: Color(0xFFC0392B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFC0392B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              side: BorderSide.none,
                              backgroundColor: GoalPalette.field,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                  fontSize: 16.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cadenceToggle() {
    Widget seg(String label, Cadence c) {
      final selected = _cadence == c;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _cadence = c),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.darkGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkGreen,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          seg('Monthly', Cadence.monthly),
          seg('Weekly', Cadence.weekly),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool numeric = false,
    bool enabled = true,
    Color fill = GoalPalette.field,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      style: numeric
          ? _numeric.copyWith(fontSize: 15)
          : const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: (numeric ? _numeric : const TextStyle()).copyWith(
          fontSize: 15,
          color: GoalPalette.faint,
        ),
        filled: true,
        fillColor: enabled ? fill : GoalPalette.hairline,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoalPalette.track),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GoalPalette.track),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?>? onChanged,
    Set<T> disabled = const {},
    Color fill = GoalPalette.field,
  }) {
    final locked = onChanged == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: locked ? GoalPalette.hairline : fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GoalPalette.track),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          icon:
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          style: const TextStyle(fontSize: 15, color: GoalPalette.ink),
          padding: const EdgeInsets.symmetric(vertical: 6),
          items: items.map((item) {
            final off = disabled.contains(item);
            return DropdownMenuItem<T>(
              value: item,
              enabled: !off,
              child: Text(
                labelOf(item),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: off ? GoalPalette.faint : GoalPalette.ink,
                ),
              ),
            );
          }).toList(),
          onChanged: locked
              ? null
              : (v) {
                  if (v == null || disabled.contains(v)) return;
                  onChanged(v);
                },
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.textMuted,
      ),
    );
  }
}
