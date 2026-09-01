import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/rendering.dart';
import 'notifications_page.dart' show NotificationsPage;
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

void main() {
  runApp(const NBEApp());
}

class NBEApp extends StatelessWidget {
  const NBEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NBE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F6F5),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------- Palette ----------
class AppColors {
  static const darkGreen = Color(0xFF1F4033);
  static const midGreen = Color(0xFF2C5443);
  static const cardGreenTop = Color(0xFF2E5A47);
  static const cardGreenBottom = Color(0xFF1B3A2C);
  static const gold = Color(0xFFD98E2C);
  static const goldLight = Color(0xFFE8A63E);
  static const textMuted = Color(0xFF8C9B93);
  static const cream = Color(0xFFFBF7EE);
  static const barTrackFood = Color(0xFFEBDCC0);
  static const barFillFood = Color(0xFFD98E2C);
  static const barTrackShop = Color(0xFFEDE7D6);
  static const barFillShop = Color(0xFFC7A94A);
  static const barTrackEnt = Color(0xFFDCE8DE);
  static const barFillEnt = Color(0xFF2C5443);
}

// ---------- Models ----------
class Transaction {
  final String title;
  final String category;
  final String time;
  final String amount;
  final bool isCredit;

  const Transaction({
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    required this.isCredit,
  });

  Transaction copyWith({String? category}) {
    return Transaction(
      title: title,
      category: category ?? this.category,
      time: time,
      amount: amount,
      isCredit: isCredit,
    );
  }

  IconData get icon => metaFor(category).icon;
  Color get iconBg => metaFor(category).bg;
  Color get iconColor => metaFor(category).color;
}

class CategoryMeta {
  final IconData icon;
  final Color bg;
  final Color color;
  const CategoryMeta(this.icon, this.bg, this.color);
}

const Map<String, CategoryMeta> kCategoryMeta = {
  'Food & Dining': CategoryMeta(
      Icons.ramen_dining_outlined, Color(0xFFFBE4E0), Color(0xFFD9773B)),
  'Groceries': CategoryMeta(
      Icons.shopping_cart_outlined, Color(0xFFEDEDED), Color(0xFF5B6B63)),
  'Shopping': CategoryMeta(
      Icons.shopping_bag_outlined, Color(0xFFE1EAF7), Color(0xFF3A6DB8)),
  'Transport': CategoryMeta(Icons.directions_car_filled_outlined,
      Color(0xFFFBE4E4), Color(0xFFD9573B)),
  'Entertainment': CategoryMeta(
      Icons.movie_creation_outlined, Color(0xFFEDE3FB), Color(0xFF7A4BC7)),
  'Income':
      CategoryMeta(Icons.work_outline, Color(0xFFF3E3E0), Color(0xFF7A4B3A)),
  'Health': CategoryMeta(
      Icons.medical_services_outlined, Color(0xFFFBE4E8), Color(0xFFD9467B)),
  'Utilities':
      CategoryMeta(Icons.bolt_outlined, Color(0xFFFFF3D6), Color(0xFFD9A62E)),
  'Beauty':
      CategoryMeta(Icons.brush_outlined, Color(0xFFFBE4EF), Color(0xFFC23B8A)),
  'Cash': CategoryMeta(
      Icons.payments_outlined, Color(0xFFE1F5E6), Color(0xFF2E9E52)),
  'Other':
      CategoryMeta(Icons.folder_outlined, Color(0xFFFBEFCB), Color(0xFFC79A2E)),
};

CategoryMeta metaFor(String category) =>
    kCategoryMeta[category] ?? kCategoryMeta['Other']!;

class CardData {
  final String type;
  final String balanceLabel;
  final String balanceValue;
  final String last4;
  final String cardName;

  const CardData({
    required this.type,
    required this.balanceLabel,
    required this.balanceValue,
    required this.last4,
    required this.cardName,
  });
}

const _debitCard = CardData(
  type: 'DEBIT',
  balanceLabel: 'AVAILABLE BALANCE',
  balanceValue: 'EGP 24,851.42',
  last4: '4821',
  cardName: 'NBE Classic',
);

const _creditCard = CardData(
  type: 'CREDIT',
  balanceLabel: 'AVAILABLE LIMIT',
  balanceValue: 'EGP 142,500.00',
  last4: '2941',
  cardName: 'Investment',
);

class BudgetItem {
  final String label;
  final double spent;
  final double limit;
  final Color trackColor;
  final Color fillColor;

  const BudgetItem({
    required this.label,
    required this.spent,
    required this.limit,
    required this.trackColor,
    required this.fillColor,
  });

  double get progress => (spent / limit).clamp(0.0, 1.0);
}

// ---------- Home Screen ----------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _frontCardIndex = 0;
  bool _balanceHidden = false;

  final List<BudgetItem> budgetItems = const [
    BudgetItem(
      label: 'Food & Dining',
      spent: 2430,
      limit: 3500,
      trackColor: AppColors.barTrackFood,
      fillColor: AppColors.barFillFood,
    ),
    BudgetItem(
      label: 'Shopping',
      spent: 1890,
      limit: 3000,
      trackColor: AppColors.barTrackShop,
      fillColor: AppColors.barFillShop,
    ),
    BudgetItem(
      label: 'Entertainment',
      spent: 540,
      limit: 1000,
      trackColor: AppColors.barTrackEnt,
      fillColor: AppColors.barFillEnt,
    ),
  ];

  List<Transaction> transactions = [
    const Transaction(
      title: 'Netflix',
      category: 'Entertainment',
      time: 'Today',
      amount: 'EGP 149.99',
      isCredit: false,
    ),
    const Transaction(
      title: 'Carrefour',
      category: 'Groceries',
      time: 'Today',
      amount: 'EGP 432.5',
      isCredit: false,
    ),
    const Transaction(
      title: 'Salary Deposit',
      category: 'Income',
      time: 'Yesterday',
      amount: '+EGP 28,000',
      isCredit: true,
    ),
    const Transaction(
      title: 'Uber Eats',
      category: 'Food & Dining',
      time: 'Yesterday',
      amount: 'EGP 215',
      isCredit: false,
    ),
    const Transaction(
      title: 'Amazon.eg',
      category: 'Shopping',
      time: 'Aug 10',
      amount: 'EGP 876',
      isCredit: false,
    ),
  ];

  void _openSheet(Widget Function(BuildContext) builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  void _openAddCardSheet() {
    _openSheet(
      (ctx) => _AddCardOptionsSheet(
        onScanCard: () {
          Navigator.pop(ctx);
          _openCameraAccessSheet();
        },
        onEnterManually: () {
          Navigator.pop(ctx);
          _openCardDetailsSheet();
        },
      ),
    );
  }

  void _openCameraAccessSheet() {
    _openSheet(
      (ctx) => _CameraAccessSheet(
        onAllow: () => Navigator.pop(ctx),
        onEnterManually: () {
          Navigator.pop(ctx);
          _openCardDetailsSheet();
        },
      ),
    );
  }

  void _openCardDetailsSheet() {
    _openSheet((ctx) => const _CardDetailsSheet());
  }

  void _openSendMoneySheet() {
    _openSheet((ctx) => const _SendMoneySheet());
  }

  void _openRequestMoneySheet() {
    _openSheet((ctx) => const _RequestMoneySheet());
  }

  void _openPaySheet() {
    _openSheet(
      (ctx) => _PaySheet(
        onEnterManually: () {
          Navigator.pop(ctx);
          _openCardDetailsSheet();
        },
      ),
    );
  }

  void _openAddTransactionSheet() {
    _openSheet((ctx) => const _AddTransactionSheet());
  }

  void _openProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const _ProfilePage()),
    );
  }

  void _openNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const NotificationsPage()),
    );
  }

  void _openEditCategorySheet(int index) {
    _openSheet(
      (ctx) => _EditCategorySheet(
        current: transactions[index].category,
        onSelect: (category) {
          setState(() {
            transactions[index] =
                transactions[index].copyWith(category: category);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidgets = <Widget>[
      _BankCard(
        data: _debitCard,
        hidden: _balanceHidden,
        onToggleHidden: () => setState(() => _balanceHidden = !_balanceHidden),
      ),
      _BankCard(
        data: _creditCard,
        hidden: _balanceHidden,
        onToggleHidden: () => setState(() => _balanceHidden = !_balanceHidden),
      ),
      _BankCardPlaceholder(onTap: _openAddCardSheet),
    ];

    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _GreenHeader(
                topInset: topInset,
                cards: cardWidgets,
                frontIndex: _frontCardIndex,
                onFrontChanged: (i) => setState(() => _frontCardIndex = i),
                onAddCard: _openAddCardSheet,
                onProfileTap: _openProfilePage,
                onNotificationsTap: _openNotificationsPage,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuickActionsRow(
                      onSend: _openSendMoneySheet,
                      onRequest: _openRequestMoneySheet,
                      onPay: _openPaySheet,
                    ),
                    const SizedBox(height: 24),
                    _MonthlySnapshotSection(items: budgetItems),
                    const SizedBox(height: 24),
                    _RecentActivityHeader(),
                    const SizedBox(height: 12),
                    _AddManualTransactionButton(
                        onTap: _openAddTransactionSheet),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final t = transactions[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _TransactionTile(
                      transaction: t,
                      onMenuTap: () => _openEditCategorySheet(index),
                    ),
                  );
                },
                childCount: transactions.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ],
    );
  }
}

// ---------- Header with Card ----------
class _GreenHeader extends StatelessWidget {
  final double topInset;
  final List<Widget> cards;
  final int frontIndex;
  final ValueChanged<int> onFrontChanged;
  final VoidCallback? onAddCard;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;

  const _GreenHeader({
    required this.topInset,
    required this.cards,
    required this.frontIndex,
    required this.onFrontChanged,
    this.onAddCard,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Nour Hassan El-Sayed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: onNotificationsTap,
                customBorder: const CircleBorder(),
                child: _CircleIconButton(
                  icon: Icons.notifications_none_rounded,
                  background: Colors.white.withOpacity(0.15),
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onProfileTap,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.gold,
                  child: const Text(
                    'NS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: _CardStack(
              cards: cards,
              onFrontChanged: onFrontChanged,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cards.length, (i) {
              final active = i == frontIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                      active ? AppColors.gold : Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          _AddCardButton(onTap: onAddCard),
        ],
      ),
    );
  }
}

// ---------- Card Stack (swipeable, layered) ----------
class _CardStack extends StatefulWidget {
  final List<Widget> cards;
  final ValueChanged<int>? onFrontChanged;

  const _CardStack({required this.cards, this.onFrontChanged});

  @override
  State<_CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<_CardStack> {
  late List<int> _order;
  double _dragDx = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _order = List.generate(widget.cards.length, (i) => i);
  }

  @override
  void didUpdateWidget(covariant _CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards.length != widget.cards.length) {
      _order = List.generate(widget.cards.length, (i) => i);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    const threshold = 70.0;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldSwipe = _dragDx.abs() > threshold || velocity.abs() > 600;
    if (shouldSwipe && _order.length > 1) {
      final direction = (_dragDx < 0 || velocity < 0) ? -1 : 1;
      setState(() {
        _dragging = false;
        _dragDx = direction * 480.0;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          final front = _order.removeAt(0);
          _order.add(front);
          _dragDx = 0;
        });
        widget.onFrontChanged?.call(_order.first);
      });
    } else {
      setState(() {
        _dragging = false;
        _dragDx = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.cards.length;
    final layers = <Widget>[];

    for (int depth = n - 1; depth >= 0; depth--) {
      final cardIndex = _order[depth];
      final isFront = depth == 0;

      final dx = isFront ? _dragDx : depth * 10.0;
      final dy = isFront ? 0.0 : depth * 12.0;
      final scale = isFront ? 1.0 : (1 - depth * 0.045).clamp(0.85, 1.0);
      final opacity = isFront ? 1.0 : (1 - depth * 0.14).clamp(0.45, 1.0);
      final rotation = isFront ? (_dragDx / 900) : 0.0;

      Widget layer = AnimatedContainer(
        duration: (_dragging && isFront)
            ? Duration.zero
            : const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(dx, dy)
          ..scale(scale)
          ..rotateZ(rotation),
        transformAlignment: Alignment.center,
        child: AnimatedOpacity(
          duration: (_dragging && isFront)
              ? Duration.zero
              : const Duration(milliseconds: 240),
          opacity: opacity,
          child: widget.cards[cardIndex],
        ),
      );

      if (isFront) {
        layer = GestureDetector(
          onHorizontalDragStart: (_) => setState(() => _dragging = true),
          onHorizontalDragUpdate: (d) => setState(() => _dragDx += d.delta.dx),
          onHorizontalDragEnd: _handleDragEnd,
          child: layer,
        );
      }

      layers.add(Positioned.fill(child: layer));
    }

    return Stack(children: layers);
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _BankCard extends StatelessWidget {
  final CardData data;
  final bool hidden;
  final VoidCallback? onToggleHidden;

  const _BankCard({
    required this.data,
    this.hidden = false,
    this.onToggleHidden,
  });

  Widget _networkBadge() {
    if (data.type == 'CREDIT') {
      return SizedBox(
        width: 34,
        height: 20,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: Color(0xFFEB5757), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              left: 13,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2A93B).withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        fontSize: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardGreenTop, AppColors.cardGreenBottom],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.goldLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NBE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'NATIONAL BANK OF EGYPT',
                      style: TextStyle(
                        color: Color(0xFFBFCFC6),
                        fontSize: 8.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.type,
                    style: const TextStyle(
                      color: Color(0xFFBFCFC6),
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _networkBadge(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 34,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD9B76A), Color(0xFFB68F45)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.balanceLabel,
                    style: const TextStyle(
                      color: Color(0xFFBFCFC6),
                      fontSize: 9,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        hidden ? '•••••••••' : data.balanceValue,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onToggleHidden,
                        child: Icon(
                          hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFBFCFC6),
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '••••  ••••  ••••  ${data.last4}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                data.cardName,
                style: const TextStyle(color: Color(0xFFBFCFC6), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankCardPlaceholder extends StatelessWidget {
  final VoidCallback? onTap;
  const _BankCardPlaceholder({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add_card_outlined,
            color: Colors.white.withOpacity(0.5),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddCardButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Add Card',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Quick Actions ----------
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback? onSend;
  final VoidCallback? onRequest;
  final VoidCallback? onPay;

  const _QuickActionsRow({this.onSend, this.onRequest, this.onPay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.send_rounded,
            label: 'Send',
            background: AppColors.darkGreen,
            iconColor: Colors.white,
            labelColor: Colors.white,
            onTap: onSend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.arrow_upward_rounded,
            label: 'Request',
            background: AppColors.gold,
            iconColor: Colors.white,
            labelColor: Colors.white,
            onTap: onRequest,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.credit_card_outlined,
            label: 'Pay',
            background: Colors.white,
            iconColor: AppColors.gold,
            labelColor: const Color(0xFF2E2E2E),
            border: Border.all(color: const Color(0xFFE7E4DC)),
            onTap: onPay,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final Color labelColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    required this.labelColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: background == Colors.white
                      ? const Color(0xFFFBF0DC)
                      : Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Monthly Snapshot ----------
class _MonthlySnapshotSection extends StatelessWidget {
  final List<BudgetItem> items;
  const _MonthlySnapshotSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Monthly Snapshot',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'Aug 2026',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF3A3A3A)),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Color(0xFF3A3A3A)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'See all',
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _BudgetRow(item: item),
            )),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final BudgetItem item;
  const _BudgetRow({required this.item});

  String _fmt(double v) {
    final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i != 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return parts.length > 1 ? '${buf.toString()}.${parts[1]}' : buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E2E2E),
                  fontWeight: FontWeight.w500),
            ),
            Text(
              'EGP ${_fmt(item.spent)} / ${_fmt(item.limit)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B63)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                Container(height: 8, color: item.trackColor),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 8,
                  width: constraints.maxWidth * item.progress,
                  color: item.fillColor,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ---------- Recent Activity ----------
class _RecentActivityHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
        Text(
          'See all',
          style: TextStyle(
              color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AddManualTransactionButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddManualTransactionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3E0D6), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, size: 18, color: Color(0xFF3A3A3A)),
              SizedBox(width: 8),
              Text(
                'Add Manual / Cash Transaction',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A3A3A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onMenuTap;
  const _TransactionTile({required this.transaction, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: transaction.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(transaction.icon, color: transaction.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} · ${transaction.time}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            transaction.amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: transaction.isCredit
                  ? const Color(0xFF2C5443)
                  : const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onMenuTap,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.more_vert, size: 18, color: Color(0xFFB5B5AD)),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet: Edit Category ----------
// =====================================================================

class _EditCategorySheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _EditCategorySheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
            title: 'Edit Category',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 6),
          ...kCategoryMeta.entries.map((entry) {
            final name = entry.key;
            final meta = entry.value;
            final selected = name == current;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected ? meta.bg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    onSelect(name);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: meta.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(meta.icon, color: meta.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: AppColors.midGreen, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Shared bottom-sheet building blocks ----------
// =====================================================================

class _SheetContainer extends StatelessWidget {
  final Widget child;
  const _SheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E0D6),
                  borderRadius: BorderRadius.circular(4),
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

class _SheetTitleRow extends StatelessWidget {
  final String title;
  final Widget? leading;
  final VoidCallback? onClose;
  final bool centered;

  const _SheetTitleRow({
    required this.title,
    this.leading,
    this.onClose,
  }) : centered = false;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E1E1E),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: centered ? Center(child: titleWidget) : titleWidget,
          ),
          if (onClose != null)
            InkWell(
              onTap: onClose,
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

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8C9B93),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SheetInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;

  const _SheetInputField({
    required this.hint,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E1E1E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAB0AA)),
        filled: true,
        fillColor: const Color(0xFFF2F2ED),
        suffixIcon: suffixIcon,
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

class _SheetDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SheetDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8C9B93)),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final BoxBorder? border;

  const _SheetButton({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 1: Add a Card ----------
// =====================================================================

class _AddCardOptionsSheet extends StatelessWidget {
  final VoidCallback onScanCard;
  final VoidCallback onEnterManually;

  const _AddCardOptionsSheet({
    required this.onScanCard,
    required this.onEnterManually,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Add a Card',
              style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E)),
            ),
          ),
          const SizedBox(height: 18),
          _OptionTile(
            icon: Icons.camera_alt_outlined,
            title: 'Scan Card',
            subtitle: 'Use your camera to scan card details',
            background: AppColors.darkGreen,
            iconBg: Colors.white.withOpacity(0.18),
            titleColor: Colors.white,
            subtitleColor: const Color(0xFFCBD8D0),
            iconColor: Colors.white,
            onTap: onScanCard,
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.credit_card,
            title: 'Enter Manually',
            subtitle: 'Type in your card number, expiry & CVV',
            background: const Color(0xFFF2F2ED),
            iconBg: Colors.white,
            titleColor: const Color(0xFF1E1E1E),
            subtitleColor: const Color(0xFF8C9B93),
            iconColor: const Color(0xFF3A3A3A),
            onTap: onEnterManually,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF8C9B93), fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color iconBg;
  final Color titleColor;
  final Color subtitleColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.iconBg,
    required this.titleColor,
    required this.subtitleColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(color: subtitleColor, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 2: Allow Camera Access ----------
// =====================================================================

class _CameraAccessSheet extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onEnterManually;

  const _CameraAccessSheet({
    required this.onAllow,
    required this.onEnterManually,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.darkGreen, size: 26),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Allow Camera Access',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 10),
          const Text(
            'NBE needs access to your camera to scan your card details automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.5, color: Color(0xFF8C9B93), height: 1.4),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your camera feed is processed on-device and never stored or shared.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.5, color: Color(0xFF8C9B93), height: 1.4),
          ),
          const SizedBox(height: 20),
          _SheetButton(
              label: 'Allow Camera Access',
              color: AppColors.darkGreen,
              onTap: onAllow),
          const SizedBox(height: 10),
          _SheetButton(
            label: 'Enter Manually Instead',
            color: const Color(0xFFF2F2ED),
            textColor: const Color(0xFF3A3A3A),
            onTap: onEnterManually,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF8C9B93), fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 3: Card Details (Enter Manually) ----------
// =====================================================================

class _CardDetailsSheet extends StatefulWidget {
  const _CardDetailsSheet();

  @override
  State<_CardDetailsSheet> createState() => _CardDetailsSheetState();
}

class _CardDetailsSheetState extends State<_CardDetailsSheet> {
  String _network = 'Visa';

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitleRow(
                title: 'Card Details', onClose: () => Navigator.pop(context)),
            const _SheetLabel('CARDHOLDER NAME'),
            const _SheetInputField(hint: 'As printed on card'),
            const _SheetLabel('CARD NUMBER'),
            const _SheetInputField(
                hint: '•••• •••• •••• ••••',
                keyboardType: TextInputType.number),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SheetLabel('EXPIRY'),
                      _SheetInputField(hint: 'MM/YY'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SheetLabel('CVV'),
                      _SheetInputField(
                          hint: '•••', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _NetworkToggle(
                    label: 'Visa',
                    selected: _network == 'Visa',
                    onTap: () => setState(() => _network = 'Visa'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NetworkToggle(
                    label: 'Mastercard',
                    selected: _network == 'Mastercard',
                    onTap: () => setState(() => _network = 'Mastercard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SheetButton(
                label: 'Add Card',
                color: AppColors.darkGreen,
                onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _NetworkToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NetworkToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.darkGreen : const Color(0xFFF2F2ED),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF3A3A3A),
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 4: Request Money ----------
// =====================================================================

class _RequestMoneySheet extends StatelessWidget {
  const _RequestMoneySheet();

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
            title: 'Request Money',
            leading: const Icon(Icons.arrow_upward_rounded,
                color: AppColors.gold, size: 18),
            onClose: () => Navigator.pop(context),
          ),
          const _SheetLabel('REQUEST FROM'),
          const _SheetInputField(hint: 'Phone number or account'),
          const _SheetLabel('AMOUNT (EGP)'),
          const _SheetInputField(
              hint: '0.00', keyboardType: TextInputType.number),
          const _SheetLabel('NOTE (optional)'),
          const _SheetInputField(hint: 'e.g. Dinner split'),
          const SizedBox(height: 18),
          _SheetButton(
              label: 'Send Request',
              color: AppColors.gold,
              onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 5: Send Money ----------
// =====================================================================

class _SendMoneySheet extends StatefulWidget {
  const _SendMoneySheet();

  @override
  State<_SendMoneySheet> createState() => _SendMoneySheetState();
}

class _SendMoneySheetState extends State<_SendMoneySheet> {
  String _fromCard = 'NBE Classic — EGP 24,851.42';

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
            title: 'Send Money',
            leading: const Icon(Icons.send_rounded,
                color: AppColors.darkGreen, size: 16),
            onClose: () => Navigator.pop(context),
          ),
          const _SheetLabel('FROM CARD'),
          _SheetDropdown(
            value: _fromCard,
            items: const ['NBE Classic — EGP 24,851.42'],
            onChanged: (v) => setState(() => _fromCard = v!),
          ),
          const _SheetLabel('TO (PHONE OR ACCOUNT NO.)'),
          const _SheetInputField(hint: '01x-xxxx-xxxx or account number'),
          const _SheetLabel('AMOUNT (EGP)'),
          const _SheetInputField(
              hint: '0.00', keyboardType: TextInputType.number),
          const SizedBox(height: 18),
          _SheetButton(
              label: 'Send Now',
              color: AppColors.darkGreen,
              onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 6: Pay ----------
// =====================================================================

class _PaySheet extends StatelessWidget {
  final VoidCallback onEnterManually;
  const _PaySheet({required this.onEnterManually});

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(title: 'Pay', onClose: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cardGreenTop, AppColors.cardGreenBottom],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.wifi, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tap to Pay',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hold your phone near the payment terminal to pay with your NBE card.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFCBD8D0), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.gold),
                    SizedBox(width: 6),
                    Text(
                      'NBE Classic ••4821',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SheetButton(
            label: 'Enter Manually Instead',
            color: const Color(0xFFF2F2ED),
            textColor: const Color(0xFF3A3A3A),
            onTap: onEnterManually,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ---------- Sheet 7: Add Transaction ----------
// =====================================================================

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet();

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  bool _isExpense = true;
  String _category = 'Other';
  final _dateController = TextEditingController();

  static const _categories = [
    'Other',
    'Food & Dining',
    'Shopping',
    'Entertainment',
    'Groceries',
    'Income',
    'Transport',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitleRow(
                title: 'Add Transaction',
                onClose: () => Navigator.pop(context)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TypeToggle(
                    label: 'Expense',
                    icon: Icons.arrow_downward_rounded,
                    selected: _isExpense,
                    color: AppColors.gold,
                    onTap: () => setState(() => _isExpense = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TypeToggle(
                    label: 'Income',
                    icon: Icons.arrow_upward_rounded,
                    selected: !_isExpense,
                    color: AppColors.darkGreen,
                    onTap: () => setState(() => _isExpense = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _SheetInputField(hint: 'Transaction name'),
            const SizedBox(height: 12),
            const _SheetInputField(
                hint: 'Amount in EGP', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _SheetInputField(
              hint: 'mm/dd/yyyy',
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF8C9B93)),
            ),
            const SizedBox(height: 12),
            _SheetDropdown(
              value: _category,
              items: _categories,
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 18),
            _SheetButton(
                label: 'Add Transaction',
                color: AppColors.darkGreen,
                onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : const Color(0xFFF2F2ED),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? Colors.white : const Color(0xFF3A3A3A)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF3A3A3A),
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ---------- Profile Page ----------
// =====================================================================

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _darkMode = false;
  String _language = 'EN';
  bool _faceId = true;
  bool _smartInsights = false;
  late final Future<UserProfile> _profile = UserService().getProfile();

  void _openBottomSheet(WidgetBuilder builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  void _confirmLogOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content:
            const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                  color: Color(0xFFC0392B), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
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
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left,
                                size: 18, color: Colors.white),
                            SizedBox(width: 2),
                            Text('Back',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              child: FutureBuilder<UserProfile>(
                                  future: _profile,
                                  builder: (context, snapshot) => Text(
                                        snapshot.data?.initials ?? '--',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      )),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Change profile photo')),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: AppColors.gold,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.edit,
                                      size: 11, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: FutureBuilder<UserProfile>(
                                        future: _profile,
                                        builder: (context, snapshot) => Text(
                                              snapshot.data?.fullName ??
                                                  (snapshot.hasError
                                                      ? 'Profile unavailable'
                                                      : 'Loading…'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17),
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => _openBottomSheet(
                                        (ctx) => const _EditProfileSheet()),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.edit_outlined,
                                          size: 13, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              FutureBuilder<UserProfile>(
                                  future: _profile,
                                  builder: (context, snapshot) => Text(
                                        snapshot.hasData
                                            ? '${snapshot.data!.email} · Since ${snapshot.data!.createdAt.year}'
                                            : '',
                                        style: TextStyle(
                                            color: Color(0xFFBFCFC6),
                                            fontSize: 12.5),
                                      )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SheetLabel('PREFERENCES'),
                    _ProfileCard(children: [
                      _ProfileToggleRow(
                        icon: Icons.dark_mode_outlined,
                        iconBg: const Color(0xFFFFF3D6),
                        iconColor: const Color(0xFFD9A62E),
                        label: 'Dark Mode',
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                      ),
                      _ProfileLanguageRow(
                        language: _language,
                        onChanged: (v) => setState(() => _language = v),
                      ),
                      _ProfileToggleRow(
                        icon: Icons.remove_red_eye_outlined,
                        iconBg: const Color(0xFFF3E3E0),
                        iconColor: const Color(0xFF7A4B3A),
                        label: 'Face ID',
                        value: _faceId,
                        onChanged: (v) => setState(() => _faceId = v),
                      ),
                      _ProfileToggleRow(
                        icon: Icons.lightbulb_outline,
                        iconBg: const Color(0xFFFFF3D6),
                        iconColor: const Color(0xFFD9A62E),
                        label: 'Smart Insights',
                        value: _smartInsights,
                        onChanged: (v) => setState(() => _smartInsights = v),
                      ),
                    ]),
                    const _SheetLabel('ACCOUNT'),
                    _ProfileCard(children: [
                      _ProfileListTile(
                        icon: Icons.notifications_none_rounded,
                        iconBg: const Color(0xFFFFF3D6),
                        iconColor: const Color(0xFFD9A62E),
                        label: 'Notifications',
                        onTap: () => _openBottomSheet(
                            (ctx) => const _NotificationPreferencesSheet()),
                      ),
                      _ProfileListTile(
                        icon: Icons.lock_outline,
                        iconBg: const Color(0xFFFBE9D6),
                        iconColor: const Color(0xFFD9773B),
                        label: 'Security & Privacy',
                        onTap: () => _openBottomSheet(
                            (ctx) => const _SecurityPrivacySheet()),
                      ),
                      _ProfileListTile(
                        icon: Icons.credit_card,
                        iconBg: const Color(0xFFE1EAF7),
                        iconColor: const Color(0xFF3A6DB8),
                        label: 'Card Management',
                        onTap: () => _openBottomSheet(
                            (ctx) => const _CardManagementSheet()),
                      ),
                      _ProfileListTile(
                        icon: Icons.description_outlined,
                        iconBg: const Color(0xFFEDE3FB),
                        iconColor: const Color(0xFF7A4BC7),
                        label: 'Account Statements',
                        onTap: () => _openBottomSheet(
                            (ctx) => const _AccountStatementsSheet()),
                      ),
                      _ProfileListTile(
                        icon: Icons.folder_outlined,
                        iconBg: const Color(0xFFFBEFCB),
                        iconColor: const Color(0xFFC79A2E),
                        label: 'Categories',
                        onTap: () => _openBottomSheet(
                            (ctx) => const _CategoriesListSheet()),
                      ),
                    ]),
                    const _SheetLabel('SUPPORT'),
                    _ProfileCard(children: [
                      _ProfileListTile(
                        icon: Icons.help_outline,
                        iconBg: const Color(0xFFFBE4E0),
                        iconColor: const Color(0xFFD9467B),
                        label: 'FAQs',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const _FAQPage()),
                        ),
                      ),
                      _ProfileListTile(
                        icon: Icons.headset_mic_outlined,
                        iconBg: const Color(0xFFEDEDED),
                        iconColor: const Color(0xFF5B6B63),
                        label: 'Get Help',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const _GetHelpPage()),
                        ),
                      ),
                      _ProfileListTile(
                        icon: Icons.balance_outlined,
                        iconBg: const Color(0xFFFFF3D6),
                        iconColor: const Color(0xFFD9A62E),
                        label: 'Terms & Conditions',
                        onTap: () => _openBottomSheet(
                            (ctx) => const _TermsConditionsSheet()),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _SheetButton(
                      label: 'Log Out',
                      color: Colors.transparent,
                      textColor: const Color(0xFFC0392B),
                      border: Border.all(color: const Color(0xFFC0392B)),
                      onTap: _confirmLogOut,
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'NBE Mobile v2.4.1 · © 2026 National Bank of Egypt',
                        style:
                            TextStyle(fontSize: 10.5, color: Color(0xFFAAB0AA)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 14,
                  endIndent: 14,
                  color: Color(0xFFF0F0EA)),
          ],
        ],
      ),
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const _ProfileListTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFB5B5AD)),
          ],
        ),
      ),
    );
  }
}

class _ProfileToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProfileToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E)),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.midGreen,
          ),
        ],
      ),
    );
  }
}

class _ProfileLanguageRow extends StatelessWidget {
  final String language;
  final ValueChanged<String> onChanged;
  const _ProfileLanguageRow({required this.language, required this.onChanged});

  Widget _pill(String code) {
    final selected = code == language;
    return GestureDetector(
      onTap: () => onChanged(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          code,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF8C9B93),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: const Color(0xFFE1EEFA),
                borderRadius: BorderRadius.circular(9)),
            child:
                const Icon(Icons.language, size: 17, color: Color(0xFF3A8DDE)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Language',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E))),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: const Color(0xFFF2F2ED),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_pill('EN'), _pill('AR')],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Edit Profile ----------
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameCtrl = TextEditingController(text: 'Nour Hassan El-Sayed');

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
              title: 'Edit Profile', onClose: () => Navigator.pop(context)),
          const _SheetLabel('FULL NAME'),
          _SheetInputField(hint: 'Full name', controller: _nameCtrl),
          const SizedBox(height: 18),
          _SheetButton(
            label: 'Save Changes',
            color: AppColors.darkGreen,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------- Notification Preferences ----------
class _NotificationPreferencesSheet extends StatefulWidget {
  const _NotificationPreferencesSheet();

  @override
  State<_NotificationPreferencesSheet> createState() =>
      _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState
    extends State<_NotificationPreferencesSheet> {
  bool _budget = true;
  bool _transaction = true;
  bool _promotion = false;
  bool _insights = true;

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
              title: 'Notification Preferences',
              onClose: () => Navigator.pop(context)),
          const SizedBox(height: 6),
          _ProfileToggleRow(
            icon: Icons.bar_chart_rounded,
            iconBg: const Color(0xFFE1EAF7),
            iconColor: const Color(0xFF3A6DB8),
            label: 'Budget Alerts',
            value: _budget,
            onChanged: (v) => setState(() => _budget = v),
          ),
          _ProfileToggleRow(
            icon: Icons.credit_card,
            iconBg: const Color(0xFFE1EAF7),
            iconColor: const Color(0xFF3A6DB8),
            label: 'Transaction Alerts',
            value: _transaction,
            onChanged: (v) => setState(() => _transaction = v),
          ),
          _ProfileToggleRow(
            icon: Icons.card_giftcard,
            iconBg: const Color(0xFFFBE4E0),
            iconColor: const Color(0xFFD9773B),
            label: 'Promotion Alerts',
            value: _promotion,
            onChanged: (v) => setState(() => _promotion = v),
          ),
          _ProfileToggleRow(
            icon: Icons.lightbulb_outline,
            iconBg: const Color(0xFFFFF3D6),
            iconColor: const Color(0xFFD9A62E),
            label: 'Insights',
            value: _insights,
            onChanged: (v) => setState(() => _insights = v),
          ),
        ],
      ),
    );
  }
}

// ---------- Security & Privacy ----------
class _SecurityPrivacySheet extends StatefulWidget {
  const _SecurityPrivacySheet();

  @override
  State<_SecurityPrivacySheet> createState() => _SecurityPrivacySheetState();
}

class _SecurityPrivacySheetState extends State<_SecurityPrivacySheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _twoFactor = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (_currentCtrl.text.isEmpty ||
        _newCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetTitleRow(
                  title: 'Security & Privacy',
                  onClose: () => Navigator.pop(context)),
              const _SheetLabel('CHANGE PASSWORD'),
              _SheetInputField(
                  hint: 'Current password',
                  controller: _currentCtrl,
                  obscureText: true),
              const SizedBox(height: 10),
              _SheetInputField(
                  hint: 'New password',
                  controller: _newCtrl,
                  obscureText: true),
              const SizedBox(height: 10),
              _SheetInputField(
                  hint: 'Confirm new password',
                  controller: _confirmCtrl,
                  obscureText: true),
              const SizedBox(height: 14),
              _SheetButton(
                  label: 'Update Password',
                  color: AppColors.darkGreen,
                  onTap: _updatePassword),
              const Divider(height: 32, color: Color(0xFFEFEFE8)),
              _ProfileToggleRow(
                icon: Icons.verified_user_outlined,
                iconBg: const Color(0xFFFBE9D6),
                iconColor: const Color(0xFFD9773B),
                label: 'Two-Factor Authentication',
                value: _twoFactor,
                onChanged: (v) => setState(() => _twoFactor = v),
              ),
              const _SheetLabel('LOGIN HISTORY'),
              const _LoginHistoryRow(
                  device: 'iPhone 15 Pro',
                  location: 'Cairo, Egypt · Today, 9:42 AM',
                  current: true),
              const _LoginHistoryRow(
                  device: 'MacBook Pro',
                  location: 'Cairo, Egypt · Aug 17, 2026, 3:15 PM'),
              const _LoginHistoryRow(
                  device: 'iPad Air',
                  location: 'Alexandria, Egypt · Aug 15, 2026, 11:08 AM'),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHistoryRow extends StatelessWidget {
  final String device;
  final String location;
  final bool current;
  const _LoginHistoryRow(
      {required this.device, required this.location, this.current = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(device,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E))),
              if (current) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE1F5E6),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E9E52)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(location,
              style:
                  const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ---------- Card Management ----------
class _CardManagementSheet extends StatefulWidget {
  const _CardManagementSheet();

  @override
  State<_CardManagementSheet> createState() => _CardManagementSheetState();
}

class _CardManagementSheetState extends State<_CardManagementSheet> {
  final List<Map<String, dynamic>> _cards = [
    {
      'name': 'NBE Classic',
      'last4': '4821',
      'icon': Icons.credit_card,
      'bg': const Color(0xFFE1EAF7),
      'color': const Color(0xFF3A6DB8),
      'frozen': false,
    },
    {
      'name': 'Savings',
      'last4': '3370',
      'icon': Icons.account_balance_outlined,
      'bg': const Color(0xFFEDEDED),
      'color': const Color(0xFF5B6B63),
      'frozen': false,
    },
    {
      'name': 'Investment',
      'last4': '2941',
      'icon': Icons.trending_up,
      'bg': const Color(0xFFEDE3FB),
      'color': const Color(0xFF7A4BC7),
      'frozen': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
              title: 'Card Management', onClose: () => Navigator.pop(context)),
          const SizedBox(height: 6),
          for (final card in _cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: card['bg'] as Color,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(card['icon'] as IconData,
                        color: card['color'] as Color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${card['name']} ••${card['last4']}',
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1E1E)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (card['frozen'] as bool) ? 'Frozen' : 'Active',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: (card['frozen'] as bool)
                                ? const Color(0xFFC0392B)
                                : const Color(0xFF2E9E52),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => setState(
                        () => card['frozen'] = !(card['frozen'] as bool)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: (card['frozen'] as bool)
                          ? AppColors.midGreen
                          : const Color(0xFFD9773B),
                      side: BorderSide(
                          color: (card['frozen'] as bool)
                              ? AppColors.midGreen
                              : const Color(0xFFD9773B)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      (card['frozen'] as bool) ? 'Unfreeze' : 'Freeze',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
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

// ---------- Account Statements ----------
class _AccountStatementsSheet extends StatelessWidget {
  const _AccountStatementsSheet();

  @override
  Widget build(BuildContext context) {
    final periods = [
      {
        'title': 'Last Month',
        'subtitle': 'July 2026',
        'icon': Icons.description_outlined
      },
      {
        'title': 'Last 3 Months',
        'subtitle': 'May – July 2026',
        'icon': Icons.article_outlined
      },
      {
        'title': 'Last Year',
        'subtitle': 'Jan – Dec 2025',
        'icon': Icons.folder_outlined
      },
    ];
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitleRow(
              title: 'Account Statements',
              onClose: () => Navigator.pop(context)),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Download your bank statement as a PDF for any of the periods below.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ),
          for (final p in periods)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F7F3),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(p['icon'] as IconData,
                      size: 18, color: AppColors.midGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title'] as String,
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E))),
                        Text(p['subtitle'] as String,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Downloading ${p['title']} statement…')),
                    ),
                    child: const Text(
                      'Download',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.midGreen),
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

// ---------- Categories List ----------
class _CategoriesListSheet extends StatelessWidget {
  const _CategoriesListSheet();

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitleRow(
                title: 'Categories', onClose: () => Navigator.pop(context)),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: kCategoryMeta.entries.map((entry) {
                  final meta = entry.value;
                  return _ProfileListTile(
                    icon: meta.icon,
                    iconBg: meta.bg,
                    iconColor: meta.color,
                    label: entry.key,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Showing ${entry.key} transactions')),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Terms & Conditions ----------
class _TermsConditionsSheet extends StatelessWidget {
  const _TermsConditionsSheet();

  static const _sections = [
    [
      '1. Account Usage and Eligibility',
      'By accessing or using the National Bank of Egypt (NBE) mobile application, you confirm that you are at least 18 years of age and a legally registered account holder with NBE. Unauthorized access, sharing of credentials, or fraudulent use of the application is strictly prohibited and may result in account suspension, legal action, or both. NBE reserves the right to terminate access at any time if terms are violated.',
    ],
    [
      '2. Data Privacy and Security',
      "NBE is committed to protecting your personal and financial data in accordance with Egyptian law and international data protection standards. Your data is encrypted in transit and at rest. We do not sell or share your personal information with third parties for marketing purposes without your explicit consent. You are responsible for maintaining the confidentiality of your PIN, password, and biometric credentials.",
    ],
    [
      '3. Transaction Liability and Disputes',
      'Transactions initiated through the NBE mobile app are processed in real time. Once a transaction is confirmed, it cannot be reversed without a formal dispute request. NBE is not liable for losses arising from unauthorized transactions that result from your failure to secure your account credentials. To dispute a transaction, you must notify NBE within 60 days of the transaction date.',
    ],
    [
      '4. Fees and Charges',
      "Certain services within the app, including expedited transfers and card replacements, may incur fees as disclosed in NBE's published fee schedule. Fees are subject to change with prior notice through the app or official NBE channels.",
    ],
    [
      '5. Termination of Service',
      'NBE may suspend or terminate your access to the mobile application at its discretion, including for suspected fraud, prolonged inactivity, or violation of these terms. You may also close your account at any time by contacting a branch or customer support.',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitleRow(
                title: 'Terms & Conditions',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in _sections)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s[0],
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E1E1E))),
                            const SizedBox(height: 6),
                            Text(s[1],
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ---------- FAQ Page ----------
// =====================================================================

class _FAQPage extends StatefulWidget {
  const _FAQPage();

  @override
  State<_FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<_FAQPage> {
  static const _faqs = [
    [
      'How do I reset my PIN?',
      'Go to Security & Privacy from your profile, then choose Change Password. For your card PIN, visit any NBE ATM and select "Change PIN," or call our support line to request a reset.',
    ],
    [
      'How long do transfers take?',
      'Transfers between NBE accounts are instant. Transfers to other local banks typically complete within a few hours, while international transfers can take 1–3 business days.',
    ],
    [
      'What is the daily transfer limit?',
      'The default daily transfer limit is EGP 50,000 for individual accounts. You can request a higher limit by visiting a branch or contacting customer support.',
    ],
    [
      'How do I dispute a transaction?',
      'Open Get Help within 60 days of the transaction date and describe the issue. Our team will review the transaction and follow up with you within 5 business days.',
    ],
    [
      'How do I freeze my card?',
      'Go to your Profile, select Card Management, then tap Freeze next to the card you want to lock. You can unfreeze it at any time the same way.',
    ],
    [
      'What is the savings account interest rate?',
      'NBE savings accounts currently earn up to 27% annual interest, calculated daily and paid monthly. Rates may vary by account type and are subject to change.',
    ],
  ];

  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
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
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left,
                              size: 18, color: Colors.white),
                          SizedBox(width: 2),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('FAQs',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final expanded = _expanded == index;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
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
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(
                              () => _expanded = expanded ? null : index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _faqs[index][0],
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E1E1E)),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: expanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xFF8C9B93)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (expanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              _faqs[index][1],
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.5,
                                  color: AppColors.textMuted),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ---------- Get Help Page ----------
// =====================================================================

class _GetHelpPage extends StatefulWidget {
  const _GetHelpPage();

  @override
  State<_GetHelpPage> createState() => _GetHelpPageState();
}

class _GetHelpPageState extends State<_GetHelpPage> {
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _messageCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Message sent — we'll get back to you soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
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
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left,
                              size: 18, color: Colors.white),
                          SizedBox(width: 2),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Get Help',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.call_outlined,
                            iconColor: const Color(0xFFC0392B),
                            title: 'Call Us',
                            subtitle: '19623',
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling 19623…')),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.chat_bubble_outline,
                            iconColor: const Color(0xFF8C8FE0),
                            title: 'WhatsApp',
                            subtitle: '+20 10 0010 1929',
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Opening WhatsApp…')),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Send a Message',
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E))),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _messageCtrl,
                            maxLines: 4,
                            style: const TextStyle(
                                fontSize: 13.5, color: Color(0xFF1E1E1E)),
                            decoration: InputDecoration(
                              hintText: 'How can we help you?',
                              hintStyle: const TextStyle(
                                  fontSize: 13, color: Color(0xFFAAB0AA)),
                              filled: true,
                              fillColor: const Color(0xFFF2F2ED),
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SheetButton(
                              label: 'Send Message',
                              color: AppColors.darkGreen,
                              onTap: _sendMessage),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Working Hours',
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E))),
                          const SizedBox(height: 10),
                          const _WorkingHoursRow(
                              day: 'Sun — Thu', hours: '9:00 AM – 5:00 PM'),
                          const _WorkingHoursRow(
                              day: 'Saturday', hours: '9:00 AM – 1:00 PM'),
                          const _WorkingHoursRow(
                              day: 'Friday', hours: 'Closed', last: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: iconColor),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E))),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.midGreen,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkingHoursRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool last;
  const _WorkingHoursRow(
      {required this.day, required this.hours, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF0F0EA))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day,
              style:
                  const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          Text(hours,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E))),
        ],
      ),
    );
  }
}
