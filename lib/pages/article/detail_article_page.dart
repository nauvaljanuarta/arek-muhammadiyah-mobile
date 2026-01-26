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
              article.title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: CupertinoColors.white.withOpacity(0.95),
            border: const Border(
              bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
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

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Image dengan framing
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

                // Info Container yang rapi
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
                        // Meta Information
                        Row(
                          children: [
                            // Author
                            Expanded(
                              child: _buildInfoItem(
                                icon: CupertinoIcons.person_fill,
                                title: 'Penulis',
                                value: article.authorName,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Category
                            Expanded(
                              child: _buildInfoItem(
                                icon: CupertinoIcons.tag_fill,
                                title: 'Kategori',
                                value: article.categoryName,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            // Date
                            Expanded(
                              child: _buildInfoItem(
                                icon: CupertinoIcons.calendar,
                                title: 'Tanggal',
                                value: article.formattedDate,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),

                        const SizedBox(height: 20),
                        
                        Container(height: 2, color: AppTheme.surface),
                        const SizedBox(height: 20),
                        Html(
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
                            "strong": Style(
                              fontWeight: FontWeight.bold,
                            ),
                            "em": Style(
                              fontStyle: FontStyle.italic,
                            ),
                            "a": Style(
                              color: AppTheme.primaryDark,
                              textDecoration: TextDecoration.none,
                            ),
                            "ul": Style(
                              margin: Margins.only(bottom: 16),
                            ),
                            "ol": Style(
                              margin: Margins.only(bottom: 16),
                            ),
                            "li": Style(
                              margin: Margins.only(bottom: 8),
                            ),
                            "blockquote": Style(
                              padding: HtmlPaddings.all(16),
                              margin: Margins.only(bottom: 16),
                              backgroundColor: AppTheme.surface,
                              border: Border(
                                left: BorderSide(
                                  color: AppTheme.primaryDark,
                                  width: 4,
                                ),
                              ),
                            ),
                          },
                          onLinkTap: (url, attributes, element) {
                            if (url != null) {
                              debugPrint("Opening URL: $url");
                            }
                          },
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

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}