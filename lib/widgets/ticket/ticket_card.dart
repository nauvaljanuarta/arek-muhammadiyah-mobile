import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../models/ticket.dart';
import '../../data/dummy_data.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF34C759);
      case 'rejected':
        return const Color(0xFFFF3B30);
      case 'review':
        return const Color(0xFFFF9500);
      case 'pending':
        return const Color(0xFF5AC8FA);
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'pending':
        return 'Menunggu';
      case 'rejected':
        return 'Ditolak';
      case 'review':
        return 'Review';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return '1 hari lalu';
      if (difference.inDays < 7) return '${difference.inDays} hari lalu';
      if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 minggu lalu' : '$weeks minggu lalu';
      }
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 bulan lalu' : '$months bulan lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = DummyData.getCategoryById(ticket.categoryId);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul dan Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(ticket.status),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(ticket.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Kategori & Tanggal
            Row(
              children: [
                Icon(
                  CupertinoIcons.tag,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  category?.name ?? 'Umum',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(ticket.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Deskripsi singkat
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
