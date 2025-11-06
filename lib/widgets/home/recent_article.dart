import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../pages/article/detail_article_page.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';

class RecentArticles extends StatelessWidget {
  const RecentArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: ArticleService.getArticles(limit: 5, published: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Container(
              height: 200,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Container(
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
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 200,
              child: const Center(
                child: Text(
                  'No articles available',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }
        
        final articles = snapshot.data!;
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final article = articles[index];
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => DetailArticlePage(article: article),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryLight.withOpacity(0.3),
                                AppTheme.primaryDark.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.doc_text_fill,
                            color: CupertinoColors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category display (if available in your Article model)
                              if (article.categoryId != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Category ${article.categoryId}', // Replace with actual category name if available
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),  
                              const SizedBox(height: 8),
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                article.content,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: articles.length,
          ),
        );
      },
    );
  }
}