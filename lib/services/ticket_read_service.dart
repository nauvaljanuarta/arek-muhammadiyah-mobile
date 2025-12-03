import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';
import 'user_service.dart'; // Import UserService untuk akses currentUser

class TicketReadService {
  static const String _basePrefix = 'ticket_last_read_';

  // Helper: Membuat key unik berdasarkan User ID + Ticket ID
  // Format: ticket_last_read_123_456 (User 123, Ticket 456)
  static String _getKey(String ticketId) {
    final userId = UserService.currentUser?.id.toString() ?? 'guest';
    return '${_basePrefix}${userId}_$ticketId';
  }

  static Future<void> markTicketAsRead(String ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan dengan key spesifik user
    await prefs.setString(_getKey(ticketId), DateTime.now().toIso8601String());
  }

  static Future<bool> isTicketUnread(Ticket ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadString = prefs.getString(_getKey(ticket.id.toString()));

    if (lastReadString == null) {
      return true;
    }

    final lastReadTime = DateTime.parse(lastReadString);
    
    final ticketUpdateTime = ticket.updatedAt;

    return ticketUpdateTime.isAfter(lastReadTime.add(const Duration(seconds: 2)));
  }

  static Future<Map<String, DateTime>> getAllReadTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = UserService.currentUser?.id.toString() ?? 'guest';
    final userSpecificPrefix = '${_basePrefix}${userId}_';

    final keys = prefs.getKeys().where((k) => k.startsWith(userSpecificPrefix));
    
    Map<String, DateTime> timestamps = {};
    for (var key in keys) {
      // Bersihkan prefix untuk mendapatkan ID Tiket murni
      final ticketId = key.replaceFirst(userSpecificPrefix, '');
      final timeString = prefs.getString(key);
      if (timeString != null) {
        timestamps[ticketId] = DateTime.parse(timeString);
      }
    }
    return timestamps;
  }
}