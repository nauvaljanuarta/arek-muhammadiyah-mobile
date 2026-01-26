import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Butuh untuk Colors
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme/theme.dart';
import '../../models/category.dart';
import '../../services/ticket_service.dart';
import '../../services/category_service.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

// Helper Class untuk Validasi File
class FileValidation {
  final bool isValid;
  final String error;

  FileValidation({required this.isValid, required this.error});
}

class _AddTicketPageState extends State<AddTicketPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<Category> _categories = [];
  Category? _selectedCategory;
  final List<File> _selectedFiles = [];
  
  bool _loadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await CategoryService.getCategories(activeOnly: true);
      if (mounted) {
        setState(() {
          _categories = data;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
          _loadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCategories = false);
        _showDialog('Error', 'Gagal memuat kategori: $e');
      }
    }
  }

  // --- FILE HANDLING ---

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        if (_selectedFiles.length + result.files.length > 10) {
          _showDialog(
            'Batas Terlampaui',
            'Maksimal 10 file. Anda dapat menambah ${10 - _selectedFiles.length} lagi.',
          );
          return;
        }

        List<File> validFiles = [];
        List<String> invalidFiles = [];

        for (var platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            final validation = _validateFile(file); // Helper validasi per file

            if (validation.isValid) {
              validFiles.add(file);
            } else {
              invalidFiles.add('${platformFile.name}: ${validation.error}');
            }
          }
        }

        if (invalidFiles.isNotEmpty) {
          _showDialog('File Tidak Valid', 'Beberapa file ditolak:\n\n${invalidFiles.join('\n')}');
        }

        if (validFiles.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(validFiles);
          });
        }
      }
    } catch (e) {
      _showDialog('Error', 'Gagal memilih file: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (file != null) {
        if (_selectedFiles.length >= 10) {
          _showDialog('Batas Terlampaui', 'Maksimal 10 file sudah tercapai');
          return;
        }

        final fileObj = File(file.path);
        final validation = _validateFile(fileObj);

        if (validation.isValid) {
          setState(() {
            _selectedFiles.add(fileObj);
          });
        } else {
          _showDialog('Foto Tidak Valid', validation.error);
        }
      }
    } catch (e) {
      _showDialog('Error', 'Gagal mengambil foto: $e');
    }
  }

  FileValidation _validateFile(File file) {
    try {
      if (!file.existsSync()) {
        return FileValidation(isValid: false, error: 'File tidak ditemukan');
      }

      final fileSize = file.lengthSync();
      // Batas per file: 10 MB (sesuaikan dengan backend)
      if (fileSize > 10 * 1024 * 1024) {
        return FileValidation(isValid: false, error: 'Ukuran file terlalu besar (>10MB)');
      }
      if (fileSize == 0) {
        return FileValidation(isValid: false, error: 'File kosong');
      }

      return FileValidation(isValid: true, error: '');
    } catch (e) {
      return FileValidation(isValid: false, error: e.toString());
    }
  }

  // Validasi total ukuran semua file (Optional, misal total max 25MB)
  FileValidation _validateTotalFileSize() {
    int totalSize = 0;
    for (var file in _selectedFiles) {
      try {
        totalSize += file.lengthSync();
      } catch (_) {}
    }
    
    // Contoh batas total upload: 50MB
    if (totalSize > 50 * 1024 * 1024) {
      return FileValidation(
        isValid: false, 
        error: 'Total ukuran melebihi 50MB. Saat ini: ${(totalSize / 1024 / 1024).toStringAsFixed(1)}MB'
      );
    }
    return FileValidation(isValid: true, error: '');
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _showFilePickerOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Lampirkan File'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickFiles();
            },
            child: const Text('Pilih dari Galeri / File'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickImageFromCamera();
            },
            child: const Text('Ambil Foto'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
      ),
    );
  }

  // --- SUBMIT LOGIC (DENGAN ANIMASI LOADING) ---

  Future<void> _submitForm() async {
    // 1. Tutup Keyboard Dulu (Biar smooth & indikator loading terlihat jelas)
    FocusScope.of(context).unfocus();

    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _selectedCategory == null) {
      _showDialog('Informasi Tidak Lengkap', 'Silakan lengkapi Judul, Deskripsi, dan Kategori.');
      return;
    }

    final sizeValidation = _validateTotalFileSize();
    if (!sizeValidation.isValid) {
      _showDialog('File Terlalu Besar', sizeValidation.error);
      return;
    }

    // 2. Nyalakan Loading Spinner
    setState(() => _isSubmitting = true);

    try {
      // Kirim data ke backend
      await TicketService.createTicket(
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory!.id.toString(),
        files: _selectedFiles,
      );

      if (!mounted) return;

      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Tiket Anda berhasil dikirim.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(ctx); 
                Navigator.pop(context, true); 
              },
            ),
          ],
        ),
      );

    } catch (e) {
     if (!mounted) return;
      
      String userFriendlyMessage;
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains('too large')) {
        userFriendlyMessage = 'Ukuran file melebihi batas (Maks 10MB).';
      } else if (errorStr.contains('connection') || errorStr.contains('timeout')) {
        userFriendlyMessage = 'Koneksi Waktu Habis.';
      } else {
        userFriendlyMessage = 'Gagal mengirim tiket. Silakan coba lagi nanti.';
      }

      _showDialog('Error', userFriendlyMessage);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
  if (_categories.isEmpty) return;

  FocusScope.of(context).unfocus();

  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text("Pilih Kategori"),
        content: SizedBox(
          width: double.infinity,
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory?.id == category.id;

              return CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 6),
                onPressed: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.label,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        CupertinoIcons.check_mark,
                        size: 18,
                        color: CupertinoColors.activeBlue,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}


  // --- WIDGETS ---

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          maxLines: maxLines,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
          ),
        ),
      ],
    );
  }

  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lampiran', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          'Maks 10 file (${_selectedFiles.length}/10). Gambar, PDF, Dokumen.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Tombol Tambah File
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: _selectedFiles.length >= 10 ? null : _showFilePickerOptions,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.paperclip, 
                  color: _selectedFiles.length >= 10 ? AppTheme.textSecondary : AppTheme.primaryDark
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedFiles.isEmpty ? 'Lampirkan File / Foto' : 'Tambah Lagi',
                  style: TextStyle(
                    color: _selectedFiles.length >= 10 ? AppTheme.textSecondary : AppTheme.primaryDark,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),
        ),

        // List File yang dipilih
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              final fileName = file.path.split('/').last;
              final fileSizeMB = (file.lengthSync() / 1024 / 1024).toStringAsFixed(1);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      fileName.toLowerCase().endsWith('pdf') ? CupertinoIcons.doc_text_fill : CupertinoIcons.photo, 
                      color: AppTheme.textSecondary, 
                      size: 24
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('$fileSizeMB MB', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 30,
                      child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemRed, size: 20),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Buat Tiket'),
        backgroundColor: AppTheme.background,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: AppTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: _loadingCategories
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(
                      label: 'Judul Tiket *',
                      controller: _titleController,
                      placeholder: 'Contoh: Permintaan Sertifikat',
                    ),
                    const SizedBox(height: 20),
                    
                    // Category Selector
                    const Text('Kategori *', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory?.name ?? 'Pilih Kategori',
                              style: TextStyle(
                                color: _selectedCategory != null ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.5),
                                fontSize: 16
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_down, color: AppTheme.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    _buildFormField(
                      label: 'Deskripsi *',
                      controller: _descriptionController,
                      placeholder: 'Jelaskan masalah atau permintaan Anda dengan jelas...',
                      maxLines: 5,
                    ),

                    const SizedBox(height: 24),
                    _buildFileSection(),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const CupertinoActivityIndicator(color: AppTheme.primaryDark) 
                            : const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}