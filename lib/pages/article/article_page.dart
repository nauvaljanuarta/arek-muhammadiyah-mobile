import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Butuh Colors untuk shadow/decorations
import '../../config/theme/theme.dart';
import '../../models/article.dart';
import '../../services/article_service.dart';
import 'detail_article_page.dart';
import '../../widgets/home/article_card.dart';

class ArticlePage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ArticlePage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // State Variables
  final List<Article> _articles = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 10;
  
  // Search State
  String _searchQuery = "";
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArticles(isRefresh: true);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- LOGIC ---

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchArticles(isRefresh: true);
    });
  }

  Future<void> _fetchArticles({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        if (_articles.isEmpty) _isLoadingInitial = true; 
      });
    }

    try {
      List<Article> newArticles;
      
      if (widget.categoryId != null) {
        newArticles = await ArticleService.getArticlesByCategory(
          widget.categoryId!,
          page: _currentPage,
          limit: _limit,
        );
      } else {
        newArticles = await ArticleService.getArticles(
          page: _currentPage,
          limit: _limit,
        );
      }

      if (_searchQuery.isNotEmpty) {
        newArticles = newArticles.where((element) => 
          element.title.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }

      if (mounted) {
        setState(() {
          if (isRefresh) {
            _articles.clear();
          }
          
          _articles.addAll(newArticles);
          _hasMore = newArticles.length >= _limit; 
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
          _isLoadingMore = false;
        });
      }
      debugPrint('Error fetching articles: $e');
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore || !_hasMore || _isLoadingInitial) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _fetchArticles(isRefresh: false);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) { 
      _loadMoreArticles();
    }
  }

  String _getPageTitle() {
    return widget.categoryName ?? 'Articles';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background, 
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // 1. Navigation Bar
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              _getPageTitle(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: CupertinoColors.white.withOpacity(0.9),
            border: null, 
          ),

          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await _fetchArticles(isRefresh: true);
            },
          ),

          // 3. Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  placeholder: 'Search articles..',
                  backgroundColor: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  style: const TextStyle(fontFamily: 'Montserrat'),
                  prefixIcon: const Icon(CupertinoIcons.search, color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),

          // 4. Content List
          if (_isLoadingInitial)
            const SliverFillRemaining(
              hasScrollBody: false, // Agar spinner berada di tengah viewport
              child: Center(child: CupertinoActivityIndicator(radius: 15)),
            )
          else if (_articles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false, 
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.news, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty 
                          ? 'No Articles Available "$_searchQuery"'
                          : 'No Articles Available',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _articles.length) {
                    return _isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CupertinoActivityIndicator()),
                          )
                        : const SizedBox(height: 40); 
                  }

                  final article = _articles[index];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    child: ArticleCard(
                      article: article,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => DetailArticlePage(article: article),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: _articles.length + 1,
              ),
            ),
        ],
      ),
    );
  }
}