import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../models/category.dart';
import '../../services/ticket_service.dart';
import '../../services/category_service.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _loadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await CategoryService.getCategories(activeOnly: true);
      setState(() {
        _categories = data;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
      _showDialog('Gagal Memuat Kategori', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null) {
      _showDialog('Peringatan', 'Mohon lengkapi semua field yang diperlukan');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await TicketService.createTicket(
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory!.id.toString(),
      );

      setState(() => _isSubmitting = false);
      _showDialog(
        'Berhasil',
        'Pengajuan Anda berhasil dikirim!',
        onOk: () {
          Navigator.pop(context); // tutup dialog
          Navigator.pop(context, true); // kembali ke halaman sebelumnya
        },
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showDialog('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  void _showDialog(String title, String message, {VoidCallback? onOk}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: onOk ?? () => Navigator.pop(context),
          ),
        ],
      ),
    );
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
                scrollController: FixedExtentScrollController(
                  initialItem: _selectedCategory != null
                      ? _categories.indexOf(_selectedCategory!)
                      : 0,
                ),
                onSelectedItemChanged: (index) {
                  setState(() => _selectedCategory = _categories[index]);
                },
                children: _categories
                    .map(
                      (c) => Center(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          maxLines: maxLines,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background,
        middle: const Text(
          'Buat Pengajuan',
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
      child: _loadingCategories
          ? const Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFormField(
                    label: 'Judul Pengajuan *',
                    controller: _titleController,
                    placeholder: 'Masukkan judul pengajuan',
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kategori *',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _showCategoryPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory?.name ?? 'Pilih kategori',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            color: AppTheme.background,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Deskripsi *',
                    controller: _descriptionController,
                    placeholder: 'Jelaskan detail pengajuan Anda',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                          : const Text(
                              'Kirim Pengajuan',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
