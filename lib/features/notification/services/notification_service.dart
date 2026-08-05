import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../scan/services/scan_service.dart';
import '../../history/services/history_service.dart';
import '../../profile/services/profile_service.dart';
import '../models/notification_item.dart';

class NotificationService {
  static const String _kLocalNotifsKey = 'local_custom_notifications_v1';
  final AccessService _accessService = AccessService();
  final HistoryService _historyService = HistoryService();
  final ProfileService _profileService = ProfileService();

  /// Menambahkan notifikasi event lokal (perubahan profil, swap slot, timer dsb)
  static Future<void> addNotification({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJsonStrList = prefs.getStringList(_kLocalNotifsKey) ?? [];

      final newItem = {
        'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'subtitle': subtitle,
        'iconCodePoint': icon.codePoint,
        'iconColorValue': iconColor.toARGB32(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      existingJsonStrList.insert(0, jsonEncode(newItem));
      // Cap at 20 most recent custom notifications
      if (existingJsonStrList.length > 20) {
        existingJsonStrList.removeRange(20, existingJsonStrList.length);
      }

      await prefs.setStringList(_kLocalNotifsKey, existingJsonStrList);
    } catch (_) {}
  }

  Future<List<NotificationItem>> getNotifications() async {
    final List<NotificationItem> list = [];

    try {
      // 1. Fetch custom local notifications
      final prefs = await SharedPreferences.getInstance();
      final localStrList = prefs.getStringList(_kLocalNotifsKey) ?? [];

      for (final str in localStrList) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          final ts = DateTime.parse(map['timestamp'] as String);
          final cp = map['iconCodePoint'] as int?;
          IconData iconData = Icons.notifications_active_rounded;
          if (cp == Icons.person_outline_rounded.codePoint) {
            iconData = Icons.person_outline_rounded;
          } else if (cp == Icons.account_circle_outlined.codePoint) {
            iconData = Icons.account_circle_outlined;
          } else if (cp == Icons.swap_horiz_rounded.codePoint) {
            iconData = Icons.swap_horiz_rounded;
          } else if (cp == Icons.qr_code_scanner_rounded.codePoint) {
            iconData = Icons.qr_code_scanner_rounded;
          } else if (cp == Icons.check_circle_outline_rounded.codePoint) {
            iconData = Icons.check_circle_outline_rounded;
          } else if (cp == Icons.local_parking_rounded.codePoint) {
            iconData = Icons.local_parking_rounded;
          } else if (cp == Icons.task_alt_rounded.codePoint) {
            iconData = Icons.task_alt_rounded;
          } else if (cp == Icons.cancel_outlined.codePoint) {
            iconData = Icons.cancel_outlined;
          }

          list.add(
            NotificationItem(
              id: map['id'] as String,
              title: map['title'] as String,
              subtitle: map['subtitle'] as String,
              time: _formatRelativeTime(ts),
              icon: iconData,
              iconColor: Color(map['iconColorValue'] as int),
              timestamp: ts,
            ),
          );
        } catch (_) {}
      }

      // 2. Fetch active ticket from backend
      final activeTicket = await _accessService.getActiveTicket();
      if (activeTicket != null) {
        final areaName = activeTicket.areaName.isNotEmpty
            ? activeTicket.areaName
            : 'Fakultas Teknik Unila';
        list.add(
          NotificationItem(
            id: 'ticket_${activeTicket.ticketCode}',
            title: 'Tiket Masuk Aktif',
            subtitle: 'Tiket ${activeTicket.ticketCode} aktif di $areaName.',
            time: 'Baru saja',
            icon: Icons.qr_code_scanner_rounded,
            iconColor: const Color(0xFF2563EB),
            timestamp: DateTime.now(),
          ),
        );
      }

      // 3. Fetch reservation history from backend
      final profile = await _profileService.getProfile();
      final userId = profile?.userId ?? '';
      final history = await _historyService.getHistory(userId);

      for (final item in history) {
        final status = item.status.toLowerCase();
        final slotStr = item.slotName.isNotEmpty ? 'Slot ${item.slotName}' : 'Slot Parkir';
        final areaStr = item.areaId.isNotEmpty ? item.areaId : 'Area Parkir';

        DateTime parsedTime = DateTime.now();
        final createdStr = item.timestamps.created;
        if (createdStr != null && createdStr.isNotEmpty) {
          try {
            parsedTime = DateTime.parse(createdStr);
          } catch (_) {}
        }

        final timeStr = _formatRelativeTime(parsedTime);

        if (status == 'booked' || status == 'claimed') {
          list.add(
            NotificationItem(
              id: 'res_${item.reservationId}',
              title: 'Reservasi Slot Berhasil',
              subtitle: '$slotStr di $areaStr berhasil direservasi.',
              time: timeStr,
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF10B981),
              timestamp: parsedTime,
            ),
          );
        } else if (status == 'arrived' || status == 'active') {
          list.add(
            NotificationItem(
              id: 'res_${item.reservationId}',
              title: 'Sesi Parkir Berjalan',
              subtitle: 'Kendaraan Anda sedang parkir di $areaStr ($slotStr).',
              time: timeStr,
              icon: Icons.local_parking_rounded,
              iconColor: const Color(0xFF2563EB),
              timestamp: parsedTime,
            ),
          );
        } else if (status == 'completed') {
          list.add(
            NotificationItem(
              id: 'res_${item.reservationId}',
              title: 'Sesi Parkir Selesai',
              subtitle: 'Sesi parkir $slotStr di $areaStr telah selesai.',
              time: timeStr,
              icon: Icons.task_alt_rounded,
              iconColor: const Color(0xFF10B981),
              timestamp: parsedTime,
            ),
          );
        } else if (status == 'cancelled') {
          list.add(
            NotificationItem(
              id: 'res_${item.reservationId}',
              title: 'Reservasi Dibatalkan',
              subtitle: 'Reservasi $slotStr di $areaStr telah dibatalkan.',
              time: timeStr,
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFFEF4444),
              timestamp: parsedTime,
            ),
          );
        }
      }

      // Sort by newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {}

    if (list.isEmpty) {
      list.add(
        NotificationItem(
          id: 'empty_notif',
          title: 'Tidak Ada Notifikasi Baru',
          subtitle: 'Aktivitas tiket dan reservasi parkir Anda akan muncul di sini secara otomatis.',
          time: 'Sekarang',
          icon: Icons.notifications_none_rounded,
          iconColor: const Color(0xFF94A3B8),
          timestamp: DateTime.now(),
        ),
      );
    }

    return list;
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hr yang lalu';
  }
}
