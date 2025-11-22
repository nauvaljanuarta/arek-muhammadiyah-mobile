import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Article Image
              _buildArticleImage(),
              const SizedBox(width: 16),
              
              // Article Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    if (article.categoryName != 'Uncategorized')
                      _buildCategoryChip(),
                    
                    const SizedBox(height: 8),
                    
                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Author & Date
                    _buildArticleMeta(),
                  ],
                ),
              ),
              
              // Chevron Icon
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
  }

  Widget _buildArticleImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: article.featureImage != null && article.featureImage!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(article.featureImage!),
                fit: BoxFit.cover,
              )
            : null,
        color: article.featureImage == null ? AppTheme.primaryLight : null,
        gradient: article.featureImage == null
            ? LinearGradient(
                colors: [
                  AppTheme.primaryLight.withOpacity(0.8),
                  AppTheme.primaryDark.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: article.featureImage == null
          ? const Center(
              child: Icon(
                CupertinoIcons.doc_text_fill,
                color: CupertinoColors.white,
                size: 32,
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        article.categoryName,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          color: AppTheme.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildArticleMeta() {
    return Row(
      children: [
        // Author
        const Icon(
          CupertinoIcons.person_circle,
          size: 14,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            article.authorName,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        
        // Date
        const Icon(
          CupertinoIcons.calendar,
          size: 12,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          article.formattedDate,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}