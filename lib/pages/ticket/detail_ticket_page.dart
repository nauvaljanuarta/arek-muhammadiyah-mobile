import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import '../../config/theme/theme.dart';
import '../../models/ticket.dart';
import '../../models/category.dart';
import '../../models/document.dart';
import '../../models/enums.dart';
import '../../services/category_service.dart';

class TicketDetailPage extends StatefulWidget {
  final Ticket ticket; 

  const TicketDetailPage({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getCategories(activeOnly: true);
      
      setState(() {
        _categories = categories;
        _selectedCategory = _findCategoryById(widget.ticket.categoryId);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Category? _findCategoryById(int? categoryId) {
    if (categoryId == null) return null;
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Document document) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryLight.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _getFileIcon(document.fileName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(document.fileSize),
                  style: const TextStyle(
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
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
    
    if (isImage) {
      return const Icon(
        CupertinoIcons.photo,
        color: CupertinoColors.systemBlue,
        size: 24,
      );
    } else {
      return const Icon(
        CupertinoIcons.doc,
        color: CupertinoColors.systemGrey,
        size: 24,
      );
    }
  }

  Widget _buildResolutionSection() {
  final hasResolution = widget.ticket.resolution != null && 
                        widget.ticket.resolution!.isNotEmpty &&
                        widget.ticket.resolution != ' ';

  if (!hasResolution) {
    return const SizedBox(); 
  }

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text(
        'Admin Response',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status dan tanggal resolved
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.ticket.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.ticket.status.label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.ticket.status.color,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.ticket.resolvedAt != null)
                  Text(
                    'Resolved: ${_formatDate(widget.ticket.resolvedAt!)}',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // ✅ RESOLUTION CONTENT (balasan dari admin)
            Text(
              widget.ticket.resolution!, // Ini yang ditampilkan
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  // Widget untuk section Note/Pemberitahuan
  Widget _buildNoteSection() {
    if (widget.ticket.status != TicketStatus.unread) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemOrange.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: CupertinoColors.systemOrange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemberitahuan',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jika ingin mengedit ticket. hapus ticket dan buat kembali ticketnya',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: CupertinoColors.systemOrange.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = widget.ticket.documents;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background,
        middle: const Text(
          'TIcket Details',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: CupertinoColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.ticket.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.ticket.status.label,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.ticket.status.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      widget.ticket.title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailItem(
                            'Category',
                            _selectedCategory?.name ?? 'No category',
                            CupertinoIcons.tag,
                          ),
                          const Divider(height: 16),
                          _buildDetailItem(
                            'Created Date',
                            _formatDate(widget.ticket.createdAt),
                            CupertinoIcons.calendar,
                          ),
                          const Divider(height: 16),
                          _buildDetailItem(
                            'Last Updated',
                            _formatDate(widget.ticket.updatedAt),
                            CupertinoIcons.clock,
                          ),
                          if (widget.ticket.resolvedAt != null) ...[
                            const Divider(height: 16),
                            _buildDetailItem(
                              'Resolved Date',
                              _formatDate(widget.ticket.resolvedAt!),
                              CupertinoIcons.checkmark_alt_circle,
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.ticket.description,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),

                    _buildNoteSection(),

                    _buildResolutionSection(),

                    if (documents.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Attached Files',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (var document in documents)
                              _buildDocumentItem(document),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}