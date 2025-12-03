import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../models/article.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isFeatured;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12), 
          
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(_isHovered ? 0.15 : 0.1), 
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Image section
              _buildImageSection(),
              const SizedBox(width: 16),
              // Content section
              Expanded(
                child: _buildContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        height: 100,
        child: widget.article.featureImage != null && widget.article.featureImage!.isNotEmpty
            ? Image.network(
                widget.article.featureImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight.withOpacity(0.25),
            AppTheme.primaryLight.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          CupertinoIcons.doc_text_fill,
          color: AppTheme.primaryDark,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    final plainTextContent = _parseHtmlToPlainText(widget.article.content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.article.title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          plainTextContent,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          maxLines: 2, // Saya ubah ke 2 baris agar layout tidak terlalu penuh
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Category and metadata in row
        Row(
          children: [
            // Flexible agar teks kategori panjang tidak overflow
            Flexible(
              child: Text(
                widget.article.categoryName,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '•',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.article.formattedDate,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
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
    
    return text.isNotEmpty ? text : 'Tidak ada konten yang tersedia';
  }
}