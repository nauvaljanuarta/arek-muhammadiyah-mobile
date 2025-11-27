// services/ticket_read_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class TicketReadService {
  static const String _readTicketsKey = 'read_tickets';
  static const String _lastUpdateKey = 'last_ticket_update';

  static Future<void> markTicketAsRead(int ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final readTickets = prefs.getStringList(_readTicketsKey) ?? [];
    
    if (!readTickets.contains(ticketId.toString())) {
      readTickets.add(ticketId.toString());
      await prefs.setStringList(_readTicketsKey, readTickets);
      print('✅ Ticket $ticketId marked as read');
    }
  }

  static Future<void> markTicketAsUnreadForNewUpdates(int ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final readTickets = prefs.getStringList(_readTicketsKey) ?? [];
    
    if (readTickets.contains(ticketId.toString())) {
      readTickets.remove(ticketId.toString());
      await prefs.setStringList(_readTicketsKey, readTickets);
      print('🔄 Ticket $ticketId marked as UNREAD (new updates)');
    }
  }

  static Future<bool> isTicketRead(int ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final readTickets = prefs.getStringList(_readTicketsKey) ?? [];
    return readTickets.contains(ticketId.toString());
  }

  static Future<List<int>> getReadTicketIds() async {
    final prefs = await SharedPreferences.getInstance();
    final readTickets = prefs.getStringList(_readTicketsKey) ?? [];
    return readTickets.map((id) => int.tryParse(id) ?? 0).toList();
  }

  static Future<void> saveLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  static Future<bool> hasNewUpdatesSinceLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_lastUpdateKey);
    if (lastUpdate == null) return true;
    
    final lastUpdateTime = DateTime.parse(lastUpdate);
    return DateTime.now().difference(lastUpdateTime).inMinutes > 5; 
  }
}