import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../widgets/ticket_history_card.dart';
import 'add_ticket_page.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  List<Map<String, dynamic>> _getMockSubmissions() {
    return [
      {
        'title': 'Pengajuan Bantuan Pendidikan',
        'category': 'Pendidikan',
        'date': '2 hari yang lalu',
        'status': 'Review',
        'description': 'Permohonan bantuan biaya pendidikan untuk anak yatim di daerah terpencil',
      },
      {
        'title': 'Proposal Kegiatan Dakwah',
        'category': 'Dakwah',
        'date': '5 hari yang lalu',
        'status': 'Approved',
        'description': 'Pengajuan kegiatan dakwah rutin di masjid Al-Hidayah setiap hari Jumat',
      },
      {
        'title': 'Bantuan Kesehatan Lansia',
        'category': 'Kesehatan',
        'date': '1 minggu yang lalu',
        'status': 'Pending',
        'description': 'Program pemeriksaan kesehatan gratis untuk lansia di lingkungan RT 05',
      },
      {
        'title': 'Pengembangan UMKM',
        'category': 'Ekonomi',
        'date': '2 minggu yang lalu',
        'status': 'Rejected',
        'description': 'Proposal bantuan modal untuk pengembangan usaha kecil menengah',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final submissions = _getMockSubmissions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryMedium, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
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
                          fontSize: 20,
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
                        builder: (context) => const AddSubmissionPage(),
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
          const SizedBox(height: 24),
          Row(
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
                '${submissions.length} pengajuan',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          submissions.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.doc_text,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pengajuan',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final submission = submissions[index];
                    return TicketHistoryCard(
                      title: submission['title'],
                      category: submission['category'],
                      date: submission['date'],
                      status: submission['status'],
                      description: submission['description'],
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text(submission['title']),
                            content: Text(submission['description']),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('Tutup'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
