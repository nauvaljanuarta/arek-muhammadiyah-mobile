import 'package:flutter/cupertino.dart';
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
  late Future<List<Article>> _articlesFuture;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final List<Article> _articles = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialArticles();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialArticles() {
    setState(() {
      _articlesFuture = _fetchArticles(page: 1);
    });
  }

  Future<List<Article>> _fetchArticles({int page = 1}) async {
    if (widget.categoryId != null) {
      // Gunakan endpoint get articles by category
      return await ArticleService.getArticlesByCategory(
        widget.categoryId!,
        page: page,
        limit: _limit,
      );
    } else {
      // Gunakan endpoint get all articles
      return await ArticleService.getArticles(
        page: page,
        limit: _limit,
      );
    }
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      _hasMore = true;
      _articlesFuture = _fetchArticles(page: 1);
    });
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newArticles = await _fetchArticles(page: nextPage);

      setState(() {
        _articles.addAll(newArticles);
        _currentPage = nextPage;
        _hasMore = newArticles.length == _limit;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('Error loading more articles: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreArticles();
    }
  }

  String _getPageTitle() {
    if (widget.categoryName != null) {
      return widget.categoryName!;
    }
    return 'Artikel';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              _getPageTitle(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppTheme.background.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
          ),

          CupertinoSliverRefreshControl(
            onRefresh: _refreshArticles,
          ),

          FutureBuilder<List<Article>>(
            future: _articlesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _articles.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                );
              } else if (snapshot.hasError && _articles.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              size: 48,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gagal memuat artikel: ${snapshot.error}',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              onPressed: _refreshArticles,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Gabungkan articles dari initial load dan load more
              final allArticles = _articles.isEmpty && snapshot.hasData 
                  ? snapshot.data! 
                  : _articles;

              if (allArticles.isEmpty) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.doc_text,
                              size: 48,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.categoryId != null 
                                ? 'Belum ada artikel dalam kategori ini'
                                : 'Belum ada artikel',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Loading indicator untuk load more
                    if (index == allArticles.length) {
                      return _isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CupertinoActivityIndicator()),
                            )
                          : _hasMore
                              ? const SizedBox.shrink()
                              : const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'Tidak ada artikel lagi',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                    }

                    final article = allArticles[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  childCount: allArticles.length + 1, // +1 untuk loading indicator
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}