import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../news/news_page.dart';
import '../submission/submission_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const NewsPage(),
    const SubmissionPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppTheme.primaryDark,
        middle: Text(
          'Muhammadiyah App',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(child: _pages[_currentIndex]),
          CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
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
                colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamu\'alaikum',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: CupertinoColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selamat datang di aplikasi Muhammadiyah',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: CupertinoColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildMenuCard(
                icon: CupertinoIcons.book_fill,
                title: 'Kajian',
                color: AppTheme.primaryMedium,
              ),
              _buildMenuCard(
                icon: CupertinoIcons.calendar,
                title: 'Agenda',
                color: AppTheme.accent,
              ),
              _buildMenuCard(
                icon: CupertinoIcons.group_solid,
                title: 'Komunitas',
                color: AppTheme.primaryLight,
              ),
              _buildMenuCard(
                icon: CupertinoIcons.info_circle_fill,
                title: 'Informasi',
                color: AppTheme.lightAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}