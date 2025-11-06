import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../auth/login_page.dart';
import '../profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (UserService.currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = await UserService.getUserById(
        UserService.currentUser!.id.toString(),
      );
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error load user: $e');
      setState(() => _isLoading = false);
    }
  }

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
              UserService.currentUser = null;
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profil'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _user == null
                ? const Center(
                    child: Text(
                      "Gagal memuat data pengguna",
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                              _buildProfileSection(
                                title: 'Akun',
                                items: [
                                  _ProfileItem(
                                    icon: CupertinoIcons.person_circle,
                                    title: 'Edit Profil',
                                    color: AppTheme.primaryMedium,
                                    onTap: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) =>
                                              EditProfilePage(user: _user!),
                                        ),
                                      );
                                      if (updated == true) _loadUserData();
                                    },
                                  ),
                                  _ProfileItem(
                                    icon: CupertinoIcons.lock_circle,
                                    title: 'Ubah Password',
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
                                    icon:
                                        CupertinoIcons.square_arrow_right_fill,
                                    title: 'Keluar',
                                    color: CupertinoColors.systemRed,
                                    onTap: () => _logout(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 80), // ✅ ruang untuk bottom nav
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Text(
            _user?.name ?? '-',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.nik ?? '-',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: CupertinoColors.white,
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
