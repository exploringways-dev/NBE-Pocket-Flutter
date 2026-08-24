import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LoginRole { client, employee }

/// The pill-shaped "Client / Employee" switch on the login header.
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final LoginRole selected;
  final ValueChanged<LoginRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _segment(
            label: 'Client',
            icon: Icons.person_outline,
            role: LoginRole.client,
          ),
          _segment(
            label: 'Employee',
            icon: Icons.account_balance_outlined,
            role: LoginRole.employee,
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required IconData icon,
    required LoginRole role,
  }) {
    final bool isSelected = selected == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primaryGreen : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
