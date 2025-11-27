import 'dart:async';

import 'package:MuhammadiyahApp/pages/ticket/add_ticket_page.dart';
import 'package:MuhammadiyahApp/services/user_service.dart';
import 'package:MuhammadiyahApp/services/ticket_service.dart';
import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../article/article_page.dart';
import '../article/detail_article_page.dart';
import '../ticket/ticket_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/core/custom_bottom_nav.dart';
import '../../widgets/core/custom_app_bar.dart';
import '../../widgets/home/category_list.dart';
import '../../widgets/home/featured_article.dart';
import '../../widgets/home/article_card.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  int _updatedTicketsCount = 0;
  Timer? _refreshTimer;

  List<Widget> get _pages => [
    const HomeContent(),
    const ArticlePage(),
    TicketPage(onTicketOpened: _onTicketOpened),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUpdatedCount();
    _startWhatsAppAutoRefresh(); 
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startWhatsAppAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print('🔄 WhatsApp-style auto refresh checking for new updates...');
      _loadUpdatedCount();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUpdatedCount();
    }
  }

  Future<void> _loadUpdatedCount() async {
    try {
      final count = await TicketService.getUpdatedTicketsCount();
      if (mounted) {
        setState(() {
          _updatedTicketsCount = count;
        });
      }
    } catch (e) {
      print('Error loading updated count: $e');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 2) {
      _loadUpdatedCount();
    }
  }

  void _onTicketOpened() {
    _loadUpdatedCount();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: _pages[_currentIndex],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNav(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                onAddTicketPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => AddTicketPage(),
                    ),
                  ).then((_) {
                    _loadUpdatedCount();
                  });
                },
                updatedCount: _updatedTicketsCount, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.currentUser;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Assalamu\'alaikum',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selamat datang di aplikasi Muhammadiyah. Semoga hari Anda penuh berkah',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.black.withOpacity(0.7),
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
                 child: StackedFeaturedArticles(), 
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: CategoriesList()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Artikel Terbaru',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppTheme.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 14,
                            color: AppTheme.primaryDark,
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const ArticlePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            SliverList(
              delegate: SliverChildListDelegate([
                FutureBuilder<List<Article>>(
                  future: ArticleService.getArticles(limit: 5, published: true),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 200,
                        child: const Center(child: CupertinoActivityIndicator()),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SizedBox(
                        height: 200,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.doc_text,
                                size: 48,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada artikel tersedia',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final articles = snapshot.data!;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: articles.map((article) => ArticleCard(
                          article: article,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => DetailArticlePage(article: article),
                              ),
                            );
                          },
                        )).toList(),
                      ),
                    );
                  },
                ),
              ]),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        CustomAppBar(currentUser: currentUser),
      ],
    );
  }
}