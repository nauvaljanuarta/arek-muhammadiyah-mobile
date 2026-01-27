import 'dart:async';
import 'dart:ui'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import '../../config/theme/theme.dart';
import '../../services/user_service.dart';
import '../../services/ticket_service.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';
import '../article/article_page.dart';
import '../article/detail_article_page.dart';
import '../ticket/ticket_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/core/custom_bottom_nav.dart';
import '../../widgets/core/custom_app_bar.dart';
import '../../widgets/home/category_list.dart';
import '../../widgets/home/featured_article.dart';
import '../../widgets/home/article_card.dart';
import '../../widgets/home/home_header.dart'; 
import '../ticket/add_ticket_page.dart';

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
    initializeDateFormatting('id_ID', null); 
    WidgetsBinding.instance.addObserver(this);
    _loadUpdatedCount();
    _startAutoRefresh(); 
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUpdatedCount();
    } 
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUpdatedCount();
    });
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
      debugPrint('Error loading updated count: $e');
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
    final user = UserService.currentUser;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background, 
      child: Stack(
        children: [
          // 1. CONTENT LAYER
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: _pages[_currentIndex],
          ),
          
          // 2. BOTTOM NAV LAYER
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
                    builder: (context) => const AddTicketPage(),
                  ),
                ).then((_) {
                  _loadUpdatedCount();
                });
              },
              updatedCount: _updatedTicketsCount,
            ),
          ),
          
          // 3. APP BAR LAYER (HEADER)
          // ✅ PERBAIKAN: Tambahkan '&& _currentIndex == 0'
          // Header ini HANYA muncul jika User Login DAN sedang di Tab Home (Index 0)
          if (user != null && _currentIndex == 0)
             Positioned(
               top: 0,
               left: 0,
               right: 0,
               child: ClipRect(
                 child: BackdropFilter(
                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
                   child: Container(
                     color: AppTheme.background.withOpacity(0.85), 
                     child: SafeArea(
                       bottom: false, 
                       child: CustomAppBar(currentUser: user),
                     ),
                   ),
                 ),
               ),
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
    final user = UserService.currentUser; 

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)), 
        SliverToBoxAdapter(
          child: HomeHeader(user: user),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                  'Kategori',
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
                const Text(
                  'Artikel Terbaru',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
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
        
        // Article List
        SliverList(
          delegate: SliverChildListDelegate([
            FutureBuilder<List<Article>>(
              future: ArticleService.getArticles(limit: 5, published: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Gagal memuat artikel',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
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
    );
  }
}