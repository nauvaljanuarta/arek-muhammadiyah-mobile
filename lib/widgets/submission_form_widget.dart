import 'package:flutter/cupertino.dart';
import '../config/theme/theme.dart';

class SubmissionFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const SubmissionFormWidget({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SubmissionFormWidget> createState() => _SubmissionFormWidgetState();
}

class _SubmissionFormWidgetState extends State<SubmissionFormWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Umum';
  String? _selectedImagePath;

  final List<String> _categories = [
    'Umum',
    'Pendidikan',
    'Kesehatan',
    'Sosial',
    'Ekonomi',
    'Dakwah'
  ];

  void _selectImage() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Pilih Foto'),
        content: const Text('Fitur upload foto akan segera tersedia'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Mohon lengkapi judul dan deskripsi pengajuan'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final submissionData = {
      'title': _titleController.text,
      'category': _selectedCategory,
      'description': _descriptionController.text,
      'imagePath': _selectedImagePath,
      'date': DateTime.now().toString(),
      'status': 'Pending',
    };

    widget.onSubmit(submissionData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Judul Pengajuan *',
            controller: _titleController,
            placeholder: 'Masukkan judul pengajuan',
          ),
          const SizedBox(height: 16),
          const Text(
            'Kategori *',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showCategoryPicker(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    color: AppTheme.textSecondary,
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
          const SizedBox(height: 16),
          const Text(
            'Upload Foto (Opsional)',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _selectImage,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryLight.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera_fill,
                    size: 32,
                    color: AppTheme.primaryLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedImagePath != null ? 'Foto dipilih' : 'Tap untuk upload foto',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(12),
              onPressed: _submitForm,
              child: const Text(
                'Kirim Pengajuan',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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

  void _showCategoryPicker() {
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
                children: _categories.map((category) => Center(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                    ),
                  ),
                )).toList(),
              ),
            ),
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
