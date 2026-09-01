// lib/screens/app_shell.dart
//
// The ONE Scaffold that owns the ONE bottom bar.
// HomeScreen, BudgetScreen etc. are plain bodies with no Scaffold of their own.

import 'package:flutter/material.dart';

import 'benefits_page.dart' show BenefitsPage;
import 'budget_screen.dart' show BudgetScreen;
import 'goals_page.dart' show GoalsPage;
import 'main_screen.dart' show HomeScreen, AppColors;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final List<Widget?> _pages = <Widget?>[
    const HomeScreen(),
    null,
    null,
    null,
  ];

  Widget _createPage(int index) => switch (index) {
        0 => const HomeScreen(),
        1 => const BudgetScreen(),
        2 => const GoalsPage(),
        3 => const BenefitsPage(),
        _ => const SizedBox.shrink(),
      };

  void _selectPage(int index) {
    setState(() {
      _index = index;
      _pages[index] ??= _createPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      body: IndexedStack(
        index: _index,
        children: List<Widget>.generate(
          _pages.length,
          (index) => _pages[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onChanged: _selectPage,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The single bottom bar — delete _BottomNavBar and _BottomNav from the
// other two files and use this everywhere instead.
// ---------------------------------------------------------------------------

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.receipt_long_outlined, 'Budget'),
    (Icons.track_changes_outlined, 'Goals'),
    (Icons.star_border_rounded, 'Benefits'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == index;
              final (icon, label) = _items[i];
              final color =
                  selected ? AppColors.darkGreen : const Color(0xFFAAB0AA);

              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Indicator sits ABOVE the icon, matching the design.
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: selected ? 26 : 0,
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Icon(icon, size: 24, color: color),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
