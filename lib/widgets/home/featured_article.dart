// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import '../../config/theme/theme.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';
import '../../pages/article/detail_article_page.dart';

class StackedFeaturedArticles extends StatefulWidget {
  const StackedFeaturedArticles({super.key});

  @override
  State<StackedFeaturedArticles> createState() => _StackedFeaturedArticlesState();
}

class _StackedFeaturedArticlesState extends State<StackedFeaturedArticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  List<Article> _articles = [];
  bool _isLoading = true; // State untuk membedakan proses loading

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addStatusListener(_handleAnimationStatus);
    _loadArticles();
  }

  void _loadArticles() async {
    try {
      final articles = await ArticleService.getArticles(limit: 4, published: true);
      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false; // Loading selesai, data berhasil diambil
        });
      }
    } catch (e) {
      debugPrint('Error loading articles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Loading selesai meski terjadi error
        });
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _articles.length;
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onSwipe() {
    if (_articles.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Kondisi saat masih loading
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_articles.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    'Artikel Pilihan',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_articles.length > 1)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _onSwipe,
                  child: const Text(
                    'Swipe untuk artikel lain',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: AppTheme.primaryMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 200) {
                _onSwipe();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(
                _articles.length.clamp(0, 3), // Maksimal 3 kartu di stack
                (index) {
                  final itemIndex = (_currentIndex + index) % _articles.length;
                  final article = _articles[itemIndex];
                  return _buildCard(article, index);
                },
              ).reversed.toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Article article, int stackIndex) {
    final topCardAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final positionOffset = (stackIndex * 12.0) - (_controller.value * 12.0);
    final scale = 1.0 - (stackIndex * 0.05) + (_controller.value * 0.05);

    final plainTextContent = _parseHtmlToPlainText(article.content);

    Widget card = Transform.scale(
      scale: scale,
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _buildCardContent(article, plainTextContent, stackIndex),
      ),
    );

    if (stackIndex == 0) {
      return AnimatedBuilder(
        animation: topCardAnimation,
        child: card,
        builder: (context, child) {
          final slideOffset = Offset(-topCardAnimation.value * 1.5, 0);
          final fadeValue = 1.0 - topCardAnimation.value;
          return Opacity(
            opacity: fadeValue.clamp(0.0, 1.0),
            child: FractionalTranslation(
              translation: slideOffset,
              child: child,
            ),
          );
        },
      );
    }

    return Transform.translate(
      offset: Offset(0, positionOffset),
      child: card,
    );
  }

  Widget _buildCardContent(Article article, String content, int stackIndex) {
    return GestureDetector(
      onTap: (stackIndex == 0 && !_controller.isAnimating)
          ? () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => DetailArticlePage(article: article),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight.withOpacity(0.8),
              AppTheme.primaryDark.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            if (article.featureImage != null && article.featureImage!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  article.featureImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppTheme.primaryLight),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.star_fill, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Artikel Pilihan',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.person_circle, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          article.authorName,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        article.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 12),
            Text(
              'Memuat artikel...',
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

  String _parseHtmlToPlainText(String htmlString) {
    String text = htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text;
  }
}