import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';

class TicketReadService {
  // Prefix untuk key di SharedPreferences agar tidak bentrok
  static const String _prefixKey = 'ticket_last_read_';

  /// Menandai tiket sudah dibaca saat ini
  static Future<void> markTicketAsRead(String ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan waktu sekarang sebagai waktu terakhir baca
    await prefs.setString('$_prefixKey$ticketId', DateTime.now().toIso8601String());
  }

  /// Cek apakah tiket memiliki update baru yang belum dibaca
  /// Logika: Badge muncul jika (Ticket UpdatedAt > Local Last Read Time)
  static Future<bool> isTicketUnread(Ticket ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadString = prefs.getString('$_prefixKey${ticket.id}');

    // Jika belum pernah dibaca sama sekali, anggap unread (return true)
    if (lastReadString == null) {
      return true;
    }

    final lastReadTime = DateTime.parse(lastReadString);
    
    // Pastikan updatedAt tidak null, jika null pakai createdAt
    final ticketUpdateTime = ticket.updatedAt;

    // Badge muncul jika waktu update tiket SETELAH waktu terakhir baca
    // Tambahkan buffer 1-2 detik untuk toleransi perbedaan waktu server/lokal
    return ticketUpdateTime.isAfter(lastReadTime.add(const Duration(seconds: 2)));
  }

  /// Helper untuk mengambil semua status baca sekaligus (untuk performa list)
  static Future<Map<String, DateTime>> getAllReadTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefixKey));
    
    Map<String, DateTime> timestamps = {};
    for (var key in keys) {
      final ticketId = key.replaceAll(_prefixKey, '');
      final timeString = prefs.getString(key);
      if (timeString != null) {
        timestamps[ticketId] = DateTime.parse(timeString);
      }
    }
    return timestamps;
  }
}