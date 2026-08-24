import 'package:flutter/material.dart';

import 'main_screen.dart' show AppColors;

class AppNotification {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final String timeAgo;

  const AppNotification({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.timeAgo,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<AppNotification> _notifications = [
    const AppNotification(
      icon: Icons.savings_rounded,
      iconBg: Color(0xFFFBEFCB),
      iconColor: Color(0xFFC79A2E),
      title: 'Salary Deposited',
      description: 'Your salary of EGP 28,000 has been deposited.',
      timeAgo: 'Yesterday',
    ),
    const AppNotification(
      icon: Icons.warning_amber_rounded,
      iconBg: Color(0xFFFBE9D6),
      iconColor: Color(0xFFD9773B),
      title: 'Budget Alert',
      description: 'Food & Dining limit at 85% — EGP 432 left this month.',
      timeAgo: '2h ago',
    ),
    const AppNotification(
      icon: Icons.card_giftcard_rounded,
      iconBg: Color(0xFFFBE4E0),
      iconColor: Color(0xFFC0392B),
      title: 'New Benefit',
      description: '5% cashback on all grocery purchases is now active.',
      timeAgo: 'Today',
    ),
  ];

  void _dismiss(int index) {
    setState(() => _notifications.removeAt(index));
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
                  const Text(
                    'Notifications',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(
                            fontSize: 13.5, color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final n = _notifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    color: n.iconBg,
                                    borderRadius: BorderRadius.circular(10)),
                                child:
                                    Icon(n.icon, size: 18, color: n.iconColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E1E1E)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.description,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textMuted,
                                          height: 1.35),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.timeAgo,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFAAB0AA)),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _dismiss(index),
                                child: const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(Icons.close,
                                      size: 17, color: Color(0xFFB5B5AD)),
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
