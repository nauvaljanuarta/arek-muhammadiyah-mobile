// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import '../../config/theme/theme.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';
import '../../pages/article/detail_article_page.dart';
import 'dart:ui';

class StackedFeaturedArticles extends StatefulWidget {
  const StackedFeaturedArticles({super.key});

  @override
  State<StackedFeaturedArticles> createState() => _StackedFeaturedArticlesState();
}

class _StackedFeaturedArticlesState extends State<StackedFeaturedArticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  List<Article> _articles = [];

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
        });
      }
    } catch (e) {
      print('Error loading articles: $e');
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
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_articles.isEmpty) {
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
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _onSwipe,
                child: const Text(
                  'Swipe it for other articles',
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
                _articles.length.clamp(0, 3),
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

    // Parse HTML content ke plain text
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
      onTap: stackIndex == 0
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
            // Background pattern atau image jika ada
            if (article.featureImage != null && article.featureImage!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  article.featureImage!, // Ganti dari imageUrl ke featureImage
                  fit: BoxFit.cover,
                ),
              ),
            
            // Overlay gradient
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

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        const Text(
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
                  
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Content Preview
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Author & Date
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.person_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          article.authorName, // Ini sudah benar dari getter
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article.formattedDate, // Ini sudah benar dari getter
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            )
                          ],
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

  // Helper function untuk parse HTML ke plain text
  String _parseHtmlToPlainText(String htmlString) {
    String text = htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '') // Hapus semua tag HTML
        .replaceAll('&nbsp;', ' ') // Ganti &nbsp; dengan spasi
        .replaceAll('&amp;', '&') // Ganti &amp; dengan &
        .replaceAll('&lt;', '<') // Ganti &lt; dengan <
        .replaceAll('&gt;', '>') // Ganti &gt; dengan >
        .replaceAll('&quot;', '"') // Ganti &quot; dengan "
        .replaceAll('&#39;', "'") // Ganti &#39; dengan '
        .trim(); // Hapus spasi di awal dan akhir
    
    // Hapus multiple spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    
    return text;
  }
}