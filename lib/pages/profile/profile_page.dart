import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Keluar'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryMedium],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.person_fill,
                    size: 40,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ahmad Fauzi',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ahmad.fauzi@muhammadiyah.org',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Member Aktif',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            title: 'Akun',
            items: [
              _ProfileItem(
                icon: CupertinoIcons.person_circle,
                title: 'Edit Profile',
                color: AppTheme.primaryMedium,
                onTap: () {},
              ),
              _ProfileItem(
                icon: CupertinoIcons.lock_circle,
                title: 'Ubah Password',
                color: AppTheme.accent,
                onTap: () {},
              ),
              _ProfileItem(
                icon: CupertinoIcons.bell_circle,
                title: 'Notifikasi',
                color: AppTheme.lightAccent,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfileSection(
            title: 'Aplikasi',
            items: [
              _ProfileItem(
                icon: CupertinoIcons.settings,
                title: 'Pengaturan',
                color: AppTheme.primaryLight,
                onTap: () {},
              ),
              _ProfileItem(
                icon: CupertinoIcons.question_circle,
                title: 'Bantuan',
                color: AppTheme.primaryMedium,
                onTap: () {},
              ),
              _ProfileItem(
                icon: CupertinoIcons.info_circle,
                title: 'Tentang Aplikasi',
                color: AppTheme.accent,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfileSection(
            title: 'Lainnya',
            items: [
              _ProfileItem(
                icon: CupertinoIcons.star_circle,
                title: 'Beri Rating',
                color: AppTheme.lightAccent,
                onTap: () {},
              ),
              _ProfileItem(
                icon: CupertinoIcons.square_arrow_right,
                title: 'Keluar',
                color: CupertinoColors.systemRed,
                onTap: () => _logout(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Versi 1.0.0',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<_ProfileItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              return Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            color: AppTheme.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      margin: const EdgeInsets.only(left: 72),
                      height: 0.5,
                      color: AppTheme.textSecondary.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  _ProfileItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}