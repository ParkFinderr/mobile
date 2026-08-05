import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.timestamp,
  });
}
