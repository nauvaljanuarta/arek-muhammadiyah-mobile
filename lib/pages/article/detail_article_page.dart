import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../config/theme/theme.dart';
import '../../models/article.dart';

class DetailArticlePage extends StatelessWidget {
  final Article article;

  const DetailArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              article.categoryName.isNotEmpty 
                  ? article.categoryName
                  : article.authorName.isNotEmpty
                      ? article.authorName
                      : 'Artikel',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: CupertinoColors.white.withOpacity(0.95),
            border: const Border(
              bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      height: 1.2,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.authorName,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.formattedDate,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: AppTheme.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (article.featureImage != null && article.featureImage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          article.featureImage!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryLight.withOpacity(0.7),
                                    AppTheme.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.photo_fill,
                                  size: 60,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryLight.withOpacity(0.7),
                            AppTheme.primaryDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.doc_text_fill,
                          size: 60,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meta Information (bisa dihapus karena sudah ada di atas)
                        const SizedBox(height: 0), // Kosongkan karena sudah ada di atas
                        
                        Container(height: 2, color: AppTheme.surface),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child : Html(
                          data: article.content,
                          style: {
                            "body": Style(
                              fontFamily: 'Montserrat',
                              fontSize: FontSize(16),
                              color: AppTheme.textPrimary,
                              lineHeight: LineHeight(1.6),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "p": Style(
                              fontFamily: 'Montserrat',
                              fontSize: FontSize(16),
                              color: AppTheme.textPrimary,
                              lineHeight: LineHeight(1.6),
                              margin: Margins.only(bottom: 16),
                            ),
                            "h1": Style(
                              fontFamily: 'Montserrat',
                              fontSize: FontSize(20),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              margin: Margins.only(bottom: 16, top: 24),
                            ),
                            "h2": Style(
                              fontFamily: 'Montserrat',
                              fontSize: FontSize(18),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              margin: Margins.only(bottom: 14, top: 20),
                            ),
                            "h3": Style(
                              fontFamily: 'Montserrat',
                              fontSize: FontSize(16),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              margin: Margins.only(bottom: 12, top: 18),
                            ),
                            "blockquote": Style(
                              padding: HtmlPaddings.all(16),
                              margin: Margins.only(bottom: 16),
                              backgroundColor: AppTheme.surface,
                              border: const Border(
                                left: BorderSide(
                                  color: AppTheme.primaryDark,
                                  width: 4,
                                ),
                              ),
                            ),
                          },
                            extensions: [
                              ImageExtension(
                                builder: (context) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        context.attributes['src']!,
                                        fit: BoxFit.contain, 
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          onLinkTap: (url, attributes, element) {
                            if (url != null) {
                            }
                          },
                        ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

}