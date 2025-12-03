import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../config/theme/theme.dart';
import '../../models/ticket.dart';
import '../../models/category.dart';
import '../../models/document.dart';
import '../../models/enums.dart';
import '../../services/category_service.dart';
import '../../services/ticket_service.dart';

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
  bool _isDeleting = false;

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

  Future<void> _deleteTicket() async {
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Hapus Ticket'),
        message: const Text('Apakah Anda yakin ingin menghapus ticket ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, true);
            },
            isDestructiveAction: true,
            child: const Text('Hapus'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await TicketService.deleteTicket(widget.ticket.id.toString());
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _isDeleting = false;
        });
        
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Gagal Menghapus'),
              content: Text('Terjadi kesalahan: ${e.toString()}'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _openDocument(Document document) async {
    try {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CupertinoAlertDialog(
          title: Text('Downloading File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 16),
              Text('Please wait...'),
            ],
          ),
        ),
      );

      final file = await _downloadFile(document);
      
      if (mounted) Navigator.pop(context);
      
      if (file != null) {
        final openResult = await OpenFile.open(file.path);
        
        if (openResult.type != ResultType.done) {
          _showOpenManualDialog(file.path, document.fileName);
        }
      } else {
        _showErrorDialog(
          'Download Gagal', 
          'Gagal mendownload file ${document.fileName}'
        );
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      _showErrorDialog(
        'Error', 
        'Gagal mendownload file:\n${e.toString()}'
      );
    }
  }

  Future<File?> _downloadFile(Document document) async {
  try {
    // Selalu gunakan temporary directory - tidak butuh permission
    final Directory dir = await getTemporaryDirectory();
    final safeFileName = _getSafeFileName(document.fileName);
    final filePath = '${dir.path}/$safeFileName';
    
    final dio = Dio();
    await dio.download(document.downloadUrl, filePath);
    
    return File(filePath);
  } catch (e) {
    rethrow;
  }
}

  String _getSafeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  void _showOpenManualDialog(String filePath, String fileName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Buka File Manual'),
        content: Text(
          'File "$fileName" berhasil didownload tapi tidak bisa dibuka otomatis. '
          'Silakan buka manual dari folder download.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    return GestureDetector(
      onTap: () => _openDocument(document),
      child: Container(
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
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
    final isPdf = extension == 'pdf';
    final isWord = ['doc', 'docx'].contains(extension);
    final isExcel = ['xls', 'xlsx'].contains(extension);
    
    if (isImage) {
      return const Icon(
        CupertinoIcons.photo,
        color: CupertinoColors.systemBlue,
        size: 24,
      );
    } else if (isPdf) {
      return const Icon(
        CupertinoIcons.doc_text,
        color: CupertinoColors.systemRed,
        size: 24,
      );
    } else if (isWord) {
      return const Icon(
        CupertinoIcons.doc,
        color: CupertinoColors.systemBlue,
        size: 24,
      );
    } else if (isExcel) {
      return const Icon(
        CupertinoIcons.chart_bar_alt_fill,
        color: CupertinoColors.systemGreen,
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
                color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                widget.ticket.resolution!,
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
            color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemOrange.withValues(alpha: 0.3),
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
                        color: CupertinoColors.systemOrange.withValues(alpha: 0.8),
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

  Widget _buildDeleteButton() {
    if (widget.ticket.status != TicketStatus.unread) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        onPressed: _isDeleting ? null : _deleteTicket,
        color: CupertinoColors.systemRed,
        borderRadius: BorderRadius.circular(12),
        child: _isDeleting
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Hapus Ticket',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = widget.ticket.documents;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background,
        middle: const Text(
          'Ticket Details',
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
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
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
                                    color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
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
                  
                  _buildDeleteButton(),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}