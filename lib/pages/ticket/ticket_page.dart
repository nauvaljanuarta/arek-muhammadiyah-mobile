import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../data/dummy_data.dart';
import '../../widgets/ticket_history_card.dart';
import 'add_ticket_page.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = DummyData.users.first.id;
    final userTickets = DummyData.getTicketsByUser(currentUserId);

    return Container(
      color: AppTheme.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryMedium, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryMedium.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.doc_text_fill,
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Pengajuan',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: CupertinoColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lihat status pengajuan Anda',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: CupertinoColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const AddTicketPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: AppTheme.primaryMedium,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Title Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pengajuan Saya',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${userTickets.length} pengajuan',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Tickets List
          userTickets.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada pengajuan',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap tombol + untuk membuat pengajuan baru',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ticket = userTickets[index];
                      final category = DummyData.getCategoryById(ticket.categoryId);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: TicketHistoryCard(
                          title: ticket.title,
                          category: category?.name ?? 'Umum',
                          date: _formatDate(ticket.createdAt),
                          status: _getStatusText(ticket.status),
                          description: ticket.description,
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: Text(ticket.title),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ticket.description),
                                    if (ticket.adminNote != null) ...[
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Catatan Admin:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(ticket.adminNote!),
                                    ],
                                  ],
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Tutup'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: userTickets.length,
                  ),
                ),

          // Bottom padding agar navbar tidak menutupi konten
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
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
      if (difference.inDays == 1) {
        return '1 hari lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 minggu lalu' : '$weeks minggu lalu';
      } else {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 bulan lalu' : '$months bulan lalu';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}