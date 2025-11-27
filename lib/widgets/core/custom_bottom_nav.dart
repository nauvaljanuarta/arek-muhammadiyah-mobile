import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTicketPressed;
  final int updatedCount; // ✅ Tambahkan parameter updatedCount

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTicketPressed,
    this.updatedCount = 0, // ✅ Default 0
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryLight.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
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
                label: 'News',
                index: 1,
                isActive: currentIndex == 1,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onAddTicketPressed,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.plus_app_fill,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add Tickets',
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
                label: 'Tickets',
                index: 2,
                isActive: currentIndex == 2,
                showBadge: updatedCount > 0, // ✅ Tampilkan badge jika ada update
                badgeCount: updatedCount, // ✅ Pass jumlah update
              ),
              _buildNavItem(
                icon: CupertinoIcons.person_fill,
                label: 'Profile',
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
        children: [
          Column(
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
          if (showBadge && badgeCount > 0)
            _buildBadge(badgeCount),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
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
    );
  }
}