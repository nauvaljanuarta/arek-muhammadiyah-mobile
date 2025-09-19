import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../models/article.dart';
import '../../data/dummy_data.dart';

class DetailNewsPage extends StatefulWidget {
  final Article article;

  const DetailNewsPage({
    super.key,
    required this.article,
  });

  @override
  State<DetailNewsPage> createState() => _DetailNewsPageState();
}

class _DetailNewsPageState extends State<DetailNewsPage> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.article.views;
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = DummyData.getCategoryById(widget.article.categoryId);
    final author = DummyData.getUserById(widget.article.authorId);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                CupertinoSliverNavigationBar(
                  backgroundColor: CupertinoColors.white.withValues(alpha: 0.95),
                  border: const Border(
                    bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
                  ),
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Share functionality
                    },
                    child: const Icon(
                      CupertinoIcons.share,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    height: 250,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(widget.article.photo),
                        fit: BoxFit.cover,
                      ),
                      color: AppTheme.surface,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category tag
                        if (category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(int.parse('0xFF${category.color.substring(1)}')).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: Color(int.parse('0xFF${category.color.substring(1)}')),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Article title
                        Text(
                          widget.article.title,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Article meta info
                        Row(
                          children: [
                            // Author info
                            if (author != null) ...[
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: author.photo != null
                                      ? DecorationImage(
                                          image: NetworkImage(author.photo!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: AppTheme.primaryDark,
                                ),
                                child: author.photo == null
                                    ? const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 16,
                                        color: CupertinoColors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                author.name,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            
                            // Publish date
                            Text(
                              _formatDate(widget.article.publishedAt),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Views count
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.eye,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.article.views}',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Article content
                        Text(
                          widget.article.content,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Engagement section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Like button
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _toggleLike,
                                child: Column(
                                  children: [
                                    Icon(
                                      isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                      color: isLiked ? CupertinoColors.systemRed : AppTheme.textSecondary,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$likeCount',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Share button
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  // Share functionality
                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.share,
                                      color: AppTheme.textSecondary,
                                      size: 24,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Bagikan',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Bookmark button
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  // Bookmark functionality
                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.bookmark,
                                      color: AppTheme.textSecondary,
                                      size: 24,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Related articles section
                        const Text(
                          'Artikel Terkait',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final relatedArticles = DummyData.getArticlesByCategory(widget.article.categoryId)
                          .where((article) => article.id != widget.article.id)
                          .take(3)
                          .toList();
                      
                      if (index >= relatedArticles.length) return null;
                      
                      final article = relatedArticles[index];
                      final articleCategory = DummyData.getCategoryById(article.categoryId);
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => DetailNewsPage(article: article),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    image: article.photo != null
                                        ? DecorationImage(
                                            image: NetworkImage(article.photo!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: article.photo == null
                                      ? const Icon(
                                          CupertinoIcons.doc_text,
                                          color: AppTheme.textSecondary,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (articleCategory != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse('0xFF${articleCategory.color.substring(1)}')).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            articleCategory.name,
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              color: Color(int.parse('0xFF${articleCategory.color.substring(1)}')),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDate(article.publishedAt),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: DummyData.getArticlesByCategory(widget.article.categoryId)
                        .where((article) => article.id != widget.article.id)
                        .take(3)
                        .length,
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
