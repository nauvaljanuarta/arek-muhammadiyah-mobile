import 'package:flutter/material.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';
import '../../config/theme/theme.dart';

class FeaturedArticle extends StatelessWidget {
  const FeaturedArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: ArticleService.getArticles(limit: 1, published: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No featured articles available'));
        }
        
        final articles = snapshot.data!;
        final featuredArticle = articles.first;
        
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🌟 Artikel Pilihan',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppTheme.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                featuredArticle.title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                featuredArticle.content,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              // ...existing code...
            ],
          ),
        );
      },
    );
  }
}