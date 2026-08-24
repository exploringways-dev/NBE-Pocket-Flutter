import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_screen.dart' show AppColors;

// =====================================================================
// ---------- Data ----------
// =====================================================================

enum BenefitCategory {
  promo,
  cashback,
  event,
  savings,
  transfer,
  lounge,
  insurance
}

String categoryLabel(BenefitCategory c) {
  switch (c) {
    case BenefitCategory.promo:
      return 'Promo';
    case BenefitCategory.cashback:
      return 'Cashback';
    case BenefitCategory.event:
      return 'Event';
    case BenefitCategory.savings:
      return 'Savings';
    case BenefitCategory.transfer:
      return 'Transfer';
    case BenefitCategory.lounge:
      return 'Lounge';
    case BenefitCategory.insurance:
      return 'Insurance';
  }
}

Color categoryColor(BenefitCategory c) {
  switch (c) {
    case BenefitCategory.promo:
      return const Color(0xFFD98E2C);
    case BenefitCategory.cashback:
      return AppColors.midGreen;
    case BenefitCategory.event:
      return const Color(0xFF3A6DB8);
    case BenefitCategory.savings:
      return const Color(0xFF7A4BC7);
    case BenefitCategory.transfer:
      return const Color(0xFF2E9E8E);
    case BenefitCategory.lounge:
      return const Color(0xFF5B6BC0);
    case BenefitCategory.insurance:
      return const Color(0xFFB0524A);
  }
}

class Benefit {
  final BenefitCategory category;
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? expiry;
  final String? cardTag;
  final String? eventDate;
  final String? eventLocation;
  final String? eventEntry;
  final bool accentDark;

  const Benefit({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.expiry,
    this.cardTag,
    this.eventDate,
    this.eventLocation,
    this.eventEntry,
    required this.accentDark,
  });
}

const List<Benefit> kBenefits = [
  Benefit(
    category: BenefitCategory.promo,
    title: '20% off at Carrefour',
    description: 'Use your NBE card and get 20% off groceries up to EGP 300.',
    icon: Icons.shopping_cart_outlined,
    iconBg: Color(0xFFFBE4E0),
    iconColor: Color(0xFFC0703B),
    expiry: 'Aug 31 2026',
    accentDark: false,
  ),
  Benefit(
    category: BenefitCategory.promo,
    title: '15% off Noon.com',
    description: 'Shop on Noon and get 15% off your cart when paying with NBE.',
    icon: Icons.shopping_bag_outlined,
    iconBg: Color(0xFFFBEFCB),
    iconColor: Color(0xFFC79A2E),
    expiry: 'Sep 5 2026',
    accentDark: true,
  ),
  Benefit(
    category: BenefitCategory.cashback,
    title: '5% Cashback on Fuel',
    description:
        'Earn 5% cashback at petrol stations nationwide with your NBE Classic.',
    icon: Icons.local_gas_station_outlined,
    iconBg: Color(0xFFEDEDED),
    iconColor: Color(0xFFC0392B),
    expiry: 'Sep 30 2026',
    cardTag: 'NBE Classic ••4821',
    accentDark: true,
  ),
  Benefit(
    category: BenefitCategory.cashback,
    title: 'Dining Cashback 10%',
    description:
        'Get 10% cashback at partner restaurants when paying with NBE cards.',
    icon: Icons.restaurant_outlined,
    iconBg: Color(0xFFEDE3FB),
    iconColor: Color(0xFF7A4BC7),
    expiry: 'Oct 15 2026',
    cardTag: 'NBE Classic ••4821',
    accentDark: false,
  ),
  Benefit(
    category: BenefitCategory.event,
    title: 'Egypt Economic Forum',
    description:
        'Join NBE at the annual Egypt Economic Forum. Exclusive client access.',
    icon: Icons.account_balance_outlined,
    iconBg: Color(0xFFEDEDED),
    iconColor: Color(0xFF5B6B63),
    eventDate: 'Sep 14 2026',
    eventLocation: 'Cairo Marriott, Zamalek',
    eventEntry: 'Free Entry',
    accentDark: true,
  ),
  Benefit(
    category: BenefitCategory.event,
    title: 'Investment Masterclass',
    description: 'Learn portfolio management from top NBE investment advisors.',
    icon: Icons.show_chart_rounded,
    iconBg: Color(0xFFFBEFCB),
    iconColor: Color(0xFFC79A2E),
    eventDate: 'Aug 28 2026',
    eventLocation: 'NBE Head Office, Cairo',
    eventEntry: 'Free Entry',
    accentDark: false,
  ),
  Benefit(
    category: BenefitCategory.savings,
    title: 'Higher Savings Rate',
    description:
        'Earn up to 27% annual interest with an NBE Savings Plus account.',
    icon: Icons.savings_outlined,
    iconBg: Color(0xFFEDE3FB),
    iconColor: Color(0xFF7A4BC7),
    accentDark: true,
  ),
  Benefit(
    category: BenefitCategory.transfer,
    title: 'Free International Transfers',
    description:
        'Enjoy 2 free SWIFT transfers this month with your NBE Classic card.',
    icon: Icons.swap_horiz_rounded,
    iconBg: Color(0xFFDCF0EC),
    iconColor: Color(0xFF2E9E8E),
    expiry: 'Aug 31 2026',
    accentDark: false,
  ),
  Benefit(
    category: BenefitCategory.lounge,
    title: 'Airport Lounge Access',
    description:
        'Enjoy free access to Cairo International Airport lounges with your NBE card.',
    icon: Icons.airplanemode_active_rounded,
    iconBg: Color(0xFFEDEDED),
    iconColor: Color(0xFF5B6BC0),
    cardTag: 'NBE Classic ••4821',
    accentDark: true,
  ),
  Benefit(
    category: BenefitCategory.insurance,
    title: 'Travel Insurance Included',
    description:
        'Get free travel insurance on purchases over EGP 5,000 abroad.',
    icon: Icons.health_and_safety_outlined,
    iconBg: Color(0xFFFBE4E0),
    iconColor: Color(0xFFB0524A),
    accentDark: false,
  ),
];

// =====================================================================
// ---------- Benefits Page ----------
// =====================================================================

class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key});

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage> {
  BenefitCategory? _selected; // null = All

  List<Benefit> get _filtered => _selected == null
      ? kBenefits
      : kBenefits.where((b) => b.category == _selected).toList();

  void _openSheet(WidgetBuilder builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  void _onBenefitTap(Benefit b) {
    switch (b.category) {
      case BenefitCategory.promo:
        _openSheet((ctx) => _PromoCodeSheet(benefit: b));
        break;
      case BenefitCategory.cashback:
        _openSheet((ctx) => _CashbackDetailsSheet(benefit: b));
        break;
      case BenefitCategory.event:
        _openSheet((ctx) => _EventRsvpSheet(benefit: b));
        break;
      case BenefitCategory.lounge:
        _openSheet((ctx) => _LoungePassSheet(benefit: b));
        break;
      case BenefitCategory.savings:
      case BenefitCategory.transfer:
      case BenefitCategory.insurance:
        _openSheet((ctx) => _BenefitInfoSheet(benefit: b));
        break;
    }
  }

  String _actionLabel(BenefitCategory c) {
    switch (c) {
      case BenefitCategory.promo:
        return 'View Promo Code';
      case BenefitCategory.cashback:
        return 'View';
      case BenefitCategory.event:
        return 'RSVP Now';
      case BenefitCategory.lounge:
        return 'Show Pass';
      case BenefitCategory.savings:
      case BenefitCategory.transfer:
      case BenefitCategory.insurance:
        return 'Learn More';
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final topInset = MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
          padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Benefits',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.1),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: BenefitCategory.values.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final cat =
                        isAll ? null : BenefitCategory.values[index - 1];
                    final selected = _selected == cat;
                    return _CategoryChip(
                      label: isAll ? 'All' : categoryLabel(cat!),
                      selected: selected,
                      onTap: () => setState(() => _selected = cat),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.midGreen, Color(0xFF3E7A5F)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are eligible for ${items.length} benefit${items.length == 1 ? '' : 's'} this week',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Based on your NBE Classic card',
                      style:
                          TextStyle(color: Color(0xFFD7E5DC), fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final b in items) ...[
                _BenefitCard(
                  benefit: b,
                  actionLabel: _actionLabel(b.category),
                  onAction: () => _onBenefitTap(b),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.gold : Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.darkGreen : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final Benefit benefit;
  final String actionLabel;
  final VoidCallback onAction;

  const _BenefitCard(
      {required this.benefit,
      required this.actionLabel,
      required this.onAction});

  @override
  Widget build(BuildContext context) {
    final accent = benefit.accentDark ? AppColors.darkGreen : AppColors.gold;
    final accentText = benefit.accentDark ? Colors.white : AppColors.darkGreen;
    final catColor = categoryColor(benefit.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: benefit.iconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(benefit.icon, size: 20, color: benefit.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit.title,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E1E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit.description,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: catColor.withOpacity(0.4)),
                ),
                child: Text(
                  categoryLabel(benefit.category),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: catColor),
                ),
              ),
              if (benefit.expiry != null)
                Text('Expires ${benefit.expiry}',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted)),
              if (benefit.eventDate != null)
                Text(benefit.eventDate!,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
          if (benefit.cardTag != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F2ED),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  benefit.cardTag!,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Material(
            color: accent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onAction,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                      color: accentText,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Shared sheet chrome ----------
// =====================================================================

class _SheetShell extends StatelessWidget {
  final Widget child;
  const _SheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE3E0D6),
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final Benefit benefit;
  final String? subtitleOverride;

  const _SheetHeader({required this.benefit, this.subtitleOverride});

  @override
  Widget build(BuildContext context) {
    final subtitle = subtitleOverride ??
        (benefit.expiry != null
            ? '${categoryLabel(benefit.category)} · Expires ${benefit.expiry}'
            : categoryLabel(benefit.category));
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: benefit.iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(benefit.icon, size: 19, color: benefit.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 20, color: Color(0xFF8C9B93)),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Promo code sheet (view only) ----------
// =====================================================================

class _PromoCodeSheet extends StatelessWidget {
  final Benefit benefit;
  const _PromoCodeSheet({required this.benefit});

  String get _code {
    final letters = benefit.title.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    final upper = letters.toUpperCase();
    final tag =
        upper.length >= 3 ? upper.substring(0, 3) : upper.padRight(3, 'X');
    return 'NBE20$tag';
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(benefit: benefit),
          Text(
            benefit.description,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your promo code',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Clipboard.setData(ClipboardData(text: _code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Promo code copied!')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE3E0D6)),
              ),
              child: Text(
                _code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: Color(0xFFD98E2C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap the code to copy it',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Cashback details sheet (view only, no action button) ----------
// =====================================================================

class _CashbackDetailsSheet extends StatelessWidget {
  final Benefit benefit;
  const _CashbackDetailsSheet({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(benefit: benefit),
          Text(
            benefit.description,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
          if (benefit.expiry != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F2ED),
                  borderRadius: BorderRadius.circular(12)),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  children: [
                    const TextSpan(text: 'Expires '),
                    TextSpan(
                      text: benefit.expiry,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E1E)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (benefit.cardTag != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                benefit.cardTag!,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Event RSVP sheet ----------
// =====================================================================

class _EventRsvpSheet extends StatefulWidget {
  final Benefit benefit;
  const _EventRsvpSheet({required this.benefit});

  @override
  State<_EventRsvpSheet> createState() => _EventRsvpSheetState();
}

class _EventRsvpSheetState extends State<_EventRsvpSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in your name and phone number')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('RSVP confirmed for ${widget.benefit.title}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.benefit;
    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(benefit: b, subtitleOverride: categoryLabel(b.category)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFF2F2ED),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 15, color: AppColors.midGreen),
                    const SizedBox(width: 8),
                    Text(b.eventDate ?? '',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E1E))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 15, color: Color(0xFFC0392B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(b.eventLocation ?? '',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF1E1E1E))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  b.eventEntry ?? '',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.midGreen),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(b.description,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E1E1E)),
            decoration: InputDecoration(
              hintText: 'Full Name',
              hintStyle:
                  const TextStyle(fontSize: 13, color: Color(0xFFAAB0AA)),
              filled: true,
              fillColor: const Color(0xFFF2F2ED),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E1E1E)),
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle:
                  const TextStyle(fontSize: 13, color: Color(0xFFAAB0AA)),
              filled: true,
              fillColor: const Color(0xFFF2F2ED),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _confirm,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text(
                  'Confirm RSVP',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Lounge pass sheet ----------
// =====================================================================

class _LoungePassSheet extends StatelessWidget {
  final Benefit benefit;
  const _LoungePassSheet({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(
              benefit: benefit,
              subtitleOverride: categoryLabel(benefit.category)),
          Text(
            benefit.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 190,
              height: 190,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: const _QrCode(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Show this at Cairo Airport lounges (Terminal 2)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            '${benefit.cardTag ?? 'NBE Classic'} · Nour Hassan',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.midGreen),
          ),
          const SizedBox(height: 18),
          Material(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text(
                  'Close',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCode extends StatelessWidget {
  const _QrCode();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _QrPainter(), child: const SizedBox.expand());
  }
}

class _QrPainter extends CustomPainter {
  static const int moduleCount = 21;

  bool _finderModule(int r, int c, int baseR, int baseC) {
    final rr = r - baseR;
    final cc = c - baseC;
    if (rr < 0 || rr > 6 || cc < 0 || cc > 6) return false;
    if (rr == 0 || rr == 6 || cc == 0 || cc == 6) return true;
    if (rr >= 2 && rr <= 4 && cc >= 2 && cc <= 4) return true;
    return false;
  }

  bool _isFinderZone(int r, int c) {
    if (r < 7 && c < 7) return true;
    if (r < 7 && c >= moduleCount - 7) return true;
    if (r >= moduleCount - 7 && c < 7) return true;
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / moduleCount;
    final bg = Paint()..color = Colors.white;
    final fg = Paint()..color = const Color(0xFF1F4033);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final rng = math.Random(7);
    for (int r = 0; r < moduleCount; r++) {
      for (int c = 0; c < moduleCount; c++) {
        bool on;
        if (_isFinderZone(r, c)) {
          if (r < 7 && c < 7) {
            on = _finderModule(r, c, 0, 0);
          } else if (r < 7 && c >= moduleCount - 7) {
            on = _finderModule(r, c, 0, moduleCount - 7);
          } else {
            on = _finderModule(r, c, moduleCount - 7, 0);
          }
        } else {
          on = rng.nextDouble() > 0.56;
        }
        if (on) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), fg);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => false;
}

// =====================================================================
// ---------- Generic benefit info sheet (Savings / Transfer / Insurance) ----------
// =====================================================================

class _BenefitInfoSheet extends StatelessWidget {
  final Benefit benefit;
  const _BenefitInfoSheet({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHeader(benefit: benefit),
          Text(
            benefit.description,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
          if (benefit.expiry != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F2ED),
                  borderRadius: BorderRadius.circular(12)),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  children: [
                    const TextSpan(text: 'Expires '),
                    TextSpan(
                      text: benefit.expiry,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E1E)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Material(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text(
                  'Got It',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
