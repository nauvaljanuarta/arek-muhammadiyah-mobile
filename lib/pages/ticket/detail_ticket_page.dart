import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../config/theme/theme.dart';
import '../../models/ticket.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/ticket_service.dart';

class TicketDetailPage extends StatefulWidget {
  Ticket ticket;

  TicketDetailPage({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TicketService _ticketService = TicketService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ticket.title);
    _descriptionController =
        TextEditingController(text: widget.ticket.description);
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      setState(() {
        _categories = categories;
        _selectedCategory = _categories.firstWhere(
          (c) => c.id == widget.ticket.categoryId,
          orElse: () => _categories.first,
        );
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _titleController.text = widget.ticket.title;
        _descriptionController.text = widget.ticket.description;
        _selectedCategory = _categories.firstWhere(
          (c) => c.id == widget.ticket.categoryId,
          orElse: () => _categories.first,
        );
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          title: Text('Peringatan'),
          content: Text('Mohon lengkapi judul dan deskripsi'),
          actions: [
            CupertinoDialogAction(child: Text('OK')),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTicket = await _ticketService.updateTicket(
        id: widget.ticket.id,
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory!.id.toString(),
      );

      setState(() {
        widget.ticket = updatedTicket; 
        _isEditMode = false;
      });

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Perubahan pengajuan telah disimpan'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error updating ticket: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCategoryPicker() {
    if (_categories.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Batal'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('Selesai'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCategory = _categories[index];
                  });
                },
                children: _categories
                    .map((category) => Center(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF34C759);
      case 'rejected':
        return const Color(0xFFFF3B30);
      case 'review':
        return const Color(0xFFFF9500);
      case 'pending':
        return const Color(0xFF5AC8FA);
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'pending':
        return 'Menunggu';
      case 'rejected':
        return 'Ditolak';
      case 'review':
        return 'Review';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppTheme.primaryMedium),
            const SizedBox(width: 12),
          ],
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.primaryDark,
        middle: Text(
          _isEditMode ? 'Edit Pengajuan' : 'Detail Pengajuan',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
        ),
        trailing: _isEditMode
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _toggleEditMode,
                child: const Icon(
                  CupertinoIcons.pencil,
                  color: CupertinoColors.white,
                ),
              ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.ticket.status.toString())
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(widget.ticket.status.toString ()),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(widget.ticket.status.toString()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      if (_isEditMode)
                        CupertinoTextField(
                          controller: _titleController,
                          placeholder: 'Masukkan judul',
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                        )
                      else
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

                      // Detail Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              label: 'Kategori',
                              value: _selectedCategory?.name ?? '-',
                              icon: CupertinoIcons.tag,
                            ),
                            const Divider(height: 16),
                            _buildDetailRow(
                              label: 'Tanggal Dibuat',
                              value: _formatDate(widget.ticket.createdAt),
                              icon: CupertinoIcons.calendar,
                            ),
                            const Divider(height: 16),
                            _buildDetailRow(
                              label: 'Status',
                              value: _getStatusText(widget.ticket.status.toString()),
                              icon: CupertinoIcons.checkmark_circle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isEditMode)
                        CupertinoTextField(
                          controller: _descriptionController,
                          placeholder: 'Masukkan deskripsi',
                          maxLines: 6,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
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

                      const SizedBox(height: 24),

                      // Buttons
                      if (_isEditMode)
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                onPressed: _toggleEditMode,
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton(
                                color: AppTheme.primaryDark,
                                borderRadius: BorderRadius.circular(12),
                                onPressed: _saveChanges,
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
