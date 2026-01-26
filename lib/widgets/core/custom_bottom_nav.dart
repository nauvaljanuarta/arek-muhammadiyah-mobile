import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTicketPressed;
  final int updatedCount; 

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTicketPressed,
    this.updatedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryLight.withOpacity(0.2), 
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false, 
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: CupertinoIcons.home,
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                icon: CupertinoIcons.news_solid,
                label: 'Artikel',
                index: 1,
                isActive: currentIndex == 1,
              ),
              // Tombol Tambah Tengah
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onAddTicketPressed,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.plus_app_fill,
                      color: AppTheme.textSecondary,
                      size: 28, // Sedikit diperbesar agar menonjol
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tambah Tiket',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNavItem(
                icon: CupertinoIcons.doc_text_fill,
                label: 'Tiket',
                index: 2,
                isActive: currentIndex == 2,
                showBadge: updatedCount > 0, // Logika Badge
                badgeCount: updatedCount,
              ),
              _buildNavItem(
                icon: CupertinoIcons.person_fill,
                label: 'Profil',
                index: 3,
                isActive: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTap(index),
      child: Stack(
        alignment: Alignment.topRight,
        clipBehavior: Clip.none, // Agar badge tidak terpotong
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppTheme.primaryDark : AppTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: isActive ? AppTheme.primaryDark : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (showBadge && badgeCount > 0)
            Positioned(
              top: 0,
              right: 8, // Sedikit digeser agar pas di ikon
              child: _buildBadge(badgeCount),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surface, width: 1.5), // Border putih agar kontras
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}