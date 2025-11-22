import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme/theme.dart';
import '../../models/category.dart';
import '../../services/ticket_service.dart';
import '../../services/category_service.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({
    super.key,
  });

  @override
  State<AddTicketPage>
  createState() => _AddTicketPageState();
}

class FileValidation {
  final bool isValid;
  final String error;

  FileValidation({
    required this.isValid,
    required this.error,
  });
}

class _AddTicketPageState
    extends State<AddTicketPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<Category>
  _categories =[];
  Category? _selectedCategory;
  final List<File>
  _selectedFiles =[];
  bool _loadingCategories =true;
  bool _isSubmitting =false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<
    void
  >
  _fetchCategories() async {
    try {
      final data = await CategoryService.getCategories(
        activeOnly:
            true,
      );
      setState(
        () {
          _categories =
              data;
          if (_categories.isNotEmpty) {
            _selectedCategory =
                _categories.first;
          }
          _loadingCategories =
              false;
        },
      );
    } catch (
      e
    ) {
      setState(
        () =>
            _loadingCategories =
                false,
      );
      _showDialog(
        'Failed to Load Categories',
        'An error occurred: $e',
      );
    }
  }

  Future<void> _pickFiles() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: [
        'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx',
      ],
    );

    if (result != null && result.files.isNotEmpty) {
      if (_selectedFiles.length + result.files.length > 10) {
        _showDialog(
          'Maximum Files Exceeded',
          'Maximum 10 files allowed. You have ${_selectedFiles.length} files, can add ${10 - _selectedFiles.length} more.',
        );
        return;
      }

      List<File> validFiles = [];
      List<String> invalidFiles = [];

      for (var platformFile in result.files) {
        if (platformFile.path != null) {
          final platformFileSize = platformFile.size;
          final platformFileSizeMB = platformFileSize / 1024 / 1024;

          if (platformFileSize > 2 * 1024 * 1024) {
            invalidFiles.add(
              '${platformFile.name} - File too large (${platformFileSizeMB.toStringAsFixed(1)}MB). Maximum 2MB allowed',
            );
            continue;
          }

          if (platformFileSize == 0) {
            invalidFiles.add(
              '${platformFile.name} - File is empty',
            );
            continue;
          }

          final file = File(platformFile.path!);
          final validation = await _validateFile(file);

          if (validation.isValid) {
            validFiles.add(file);
          } else {
            invalidFiles.add(
              '${platformFile.name} - ${validation.error}',
            );
          }
        }
      }

      if (invalidFiles.isNotEmpty) {
        _showDialog(
          'Invalid Files',
          'The following files could not be added:\n\n${invalidFiles.join('\n')}',
        );
      }

      if (validFiles.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(validFiles);
        });
         _showDialog('Success', '${validFiles.length} files added successfully');
      } 
    }
  } catch (e) {
    _showDialog(
      'Error',
      'Failed to select files: $e',
    );
  }
}

  Future<
    void
  >
  _pickImageFromCamera() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source:
            ImageSource.camera,
        maxWidth:
            1920,
        maxHeight:
            1080,
        imageQuality:
            85,
      );

      if (file !=
          null) {
        if (_selectedFiles.length >=
            10) {
          _showDialog(
            'Maximum Files',
            'Maximum 10 files reached',
          );
          return;
        }

        final fileObj = File(
          file.path,
        );
        final validation = await _validateFile(
          fileObj,
        );

        if (validation.isValid) {
          setState(
            () {
              _selectedFiles.add(
                fileObj,
              );
            },
          );
          _showDialog(
            'Success',
            'Photo taken successfully',
          );
        } else {
          _showDialog(
            'Invalid File',
            'Cannot add photo: ${validation.error}',
          );
        }
      }
    } catch (
      e
    ) {
      _showDialog(
        'Error',
        'Failed to take photo: $e',
      );
    }
  }

  // Hitung total size semua file
int _calculateTotalFileSize() {
  int totalSize = 0;
  for (var file in _selectedFiles) {
    try {
      totalSize += file.lengthSync();
    } catch (e) {
      // Skip jika file tidak bisa diakses
    }
  }
  return totalSize;
}

// Validasi total file size sebelum submit
FileValidation _validateTotalFileSize() {
  final totalSize = _calculateTotalFileSize();
  final totalSizeMB = totalSize / 1024 / 1024;
  
  if (totalSize > 10 * 1024 * 1024) { // 10MB in bytes
    return FileValidation(
      isValid: false,
      error: 'Total file size is ${totalSizeMB.toStringAsFixed(1)}MB. Maximum 10MB allowed for all files combined.',
    );
  }
  
  return FileValidation(
    isValid: true,
    error: '',
  );
}

Future<FileValidation> _validateFile(File file) async {
  try {
    if (!await file.exists()) {
      return FileValidation(
        isValid: false,
        error: 'File not found',
      );
    }

    final fileSize = file.lengthSync();
    final fileSizeMB = fileSize / 1024 / 1024;

    if (fileSize > 10 * 1024 * 1024) { 
      return FileValidation(
        isValid: false,
        error: 'File too large (${fileSizeMB.toStringAsFixed(1)}MB). Maximum 10MB allowed',
      );
    }

    if (fileSize == 0) {
      return FileValidation(
        isValid: false,
        error: 'File is empty',
      );
    }

    return FileValidation(
      isValid: true,
      error: '',
    );
  } catch (e) {
    return FileValidation(
      isValid: false,
      error: 'Error validating file: ${e.toString()}',
    );
  }
}

  void _removeFile(
    int index,
  ) {
    setState(() {_selectedFiles.removeAt( index,
        );
      },
    );
  }

  void _showFilePickerOptions() {
    showCupertinoModalPopup(
      context:
          context,
      builder:
          (
            context,
          ) => CupertinoActionSheet(
            title: const Text(
              'Select Files',
              style: TextStyle(
                fontFamily:
                    'Montserrat',
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            message: const Text(
              'Choose the type of files to upload',
              style: TextStyle(
                fontFamily:
                    'Montserrat',
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                  _pickFiles();
                },
                child: const Text(
                  'Select Files from Storage',
                  style: TextStyle(
                    fontFamily:
                        'Montserrat',
                    fontSize:
                        16,
                  ),
                ),
              ),

              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                  _pickImageFromCamera();
                },
                child: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(
                    fontFamily:
                        'Montserrat',
                    fontSize:
                        16,
                  ),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction:
                  true,
              onPressed:
                  () => Navigator.pop(
                    context,
                  ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily:
                      'Montserrat',
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _submitForm() async {
  if (_titleController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _selectedCategory == null) {
    _showDialog(
      'Required Fields',
      'Please complete all required fields',
    );
    return;
  }

  final sizeValidation = _validateTotalFileSize();
  if (!sizeValidation.isValid) {
    _showDialog(
      'File Size Exceeded',
      sizeValidation.error,
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    await TicketService.createTicket(
      title: _titleController.text,
      description: _descriptionController.text,
      categoryId: _selectedCategory!.id.toString(),
      files: _selectedFiles,
    );

    setState(() => _isSubmitting = false);
    _showDialog(
      'Success',
      'Your Ticket has been sent successfully!',
      onOk: () {
        Navigator.pop(context);
        Navigator.pop(context, true);
      },
    );
  } catch (e) {
    setState(() => _isSubmitting = false);

    String errorMessage = 'An error occurred while submitting: ${e.toString()}';

    if (e.toString().contains('too large') || e.toString().contains('10MB')) {
      errorMessage = 'File size error: ${e.toString()}';
    } else if (e.toString().contains('Connection reset') || e.toString().contains('timeout')) {
      errorMessage = 'Network error. Please check your connection and try again.';
    }

    _showDialog(
      'Ticket Failed',
      errorMessage,
    );
  }
}

  void _showDialog(
    String title,
    String message, {
    VoidCallback? onOk,
  }) {
    showCupertinoDialog(
      context:
          context,
      builder:
          (
            context,
          ) => CupertinoAlertDialog(
            title: Text(
              title,
            ),
            content: Text(
              message,
            ),
            actions: [
              CupertinoDialogAction(
                onPressed:
                    onOk ??
                    () => Navigator.pop(
                      context,
                    ),
                child: const Text(
                  'OK',
                ),
              ),
            ],
          ),
    );
  }

  void _showCategoryPicker() {
    if (_categories.isEmpty) return;
    showCupertinoModalPopup(
      context:
          context,
      builder:
          (
            context,
          ) => Container(
            height:
                250,
            color:
                CupertinoColors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text(
                          'Cancel',
                        ),
                        onPressed:
                            () => Navigator.pop(
                              context,
                            ),
                      ),
                      const Text(
                        'Select Category',
                        style: TextStyle(
                          fontFamily:
                              'Montserrat',
                          fontSize:
                              16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      CupertinoButton(
                        child: const Text(
                          'Done',
                        ),
                        onPressed:
                            () => Navigator.pop(
                              context,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent:
                        40,
                    scrollController: FixedExtentScrollController(
                      initialItem:
                          _selectedCategory !=
                                  null
                              ? _categories.indexOf(
                                _selectedCategory!,
                              )
                              : 0,
                    ),
                    onSelectedItemChanged: (
                      index,
                    ) {
                      setState(
                        () =>
                            _selectedCategory =
                                _categories[index],
                      );
                    },
                    children:
                        _categories
                            .map(
                              (
                                c,
                              ) => Center(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontFamily:
                                        'Montserrat',
                                    fontSize:
                                        16,
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
    int maxLines =
        1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily:
                'Montserrat',
            fontSize:
                16,
            fontWeight:
                FontWeight.w600,
            color:
                AppTheme.textPrimary,
          ),
        ),
        const SizedBox(
          height:
              8,
        ),
        CupertinoTextField(
          controller:
              controller,
          placeholder:
              placeholder,
          maxLines:
              maxLines,
          padding: const EdgeInsets.all(
            16,
          ),
          decoration: BoxDecoration(
            color:
                AppTheme.surface,
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          style: const TextStyle(
            fontFamily:
                'Montserrat',
            fontSize:
                16,
          ),
        ),
      ],
    );
  }

  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'File Attachments',
          style: TextStyle(
            fontFamily:
                'Montserrat',
            fontSize:
                16,
            fontWeight:
                FontWeight.w600,
            color:
                AppTheme.textPrimary,
          ),
        ),
        const SizedBox(
          height:
              8,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Maximum 10 files (${_selectedFiles.length}/10)',
              style: const TextStyle(
                fontFamily:
                    'Montserrat',
                fontSize:
                    12,
                color:
                    AppTheme.textSecondary,
              ),
            ),
            const SizedBox(
              height:
                  4,
            ),
            const Text(
              'Supported formats: Images, PDF, DOC, XLS (Max 10MB per file)',
              style: TextStyle(
                fontFamily:
                    'Montserrat',
                fontSize:
                    11,
                color:
                    AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(
          height:
              8,
        ),

        Container(
          width:
              double.infinity,
          padding: const EdgeInsets.all(
            16,
          ),
          decoration: BoxDecoration(
            color:
                AppTheme.surface,
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: AppTheme.primaryLight.withOpacity(
                0.3,
              ),
            ),
          ),
          child: CupertinoButton(
            padding:
                EdgeInsets.zero,
            onPressed:
                _selectedFiles.length >=
                        10
                    ? null
                    : _showFilePickerOptions,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.paperclip,
                  color:
                      _selectedFiles.length >=
                              10
                          ? AppTheme.textSecondary
                          : AppTheme.primaryDark,
                  size:
                      20,
                ),
                const SizedBox(
                  width:
                      8,
                ),
                Text(
                  _selectedFiles.isEmpty
                      ? 'Add Files'
                      : 'Add More Files',
                  style: TextStyle(
                    fontFamily:
                        'Montserrat',
                    fontSize:
                        16,
                    color:
                        _selectedFiles.length >=
                                10
                            ? AppTheme.textSecondary
                            : AppTheme.primaryDark,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(
            height:
                12,
          ),
          ListView.separated(
            shrinkWrap:
                true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount:
                _selectedFiles.length,
            separatorBuilder:
                (
                  context,
                  index,
                ) => const SizedBox(
                  height:
                      8,
                ),
            itemBuilder: (
              context,
              index,
            ) {
              final file =
                  _selectedFiles[index];
              final fileSize =
                  file.lengthSync();
              final fileName =
                  file.path
                      .split(
                        '/',
                      )
                      .last;
              final fileSizeMB = (fileSize /
                      1024 /
                      1024)
                  .toStringAsFixed(
                    1,
                  );

              return Container(
                padding: const EdgeInsets.all(
                  12,
                ),
                decoration: BoxDecoration(
                  color:
                      CupertinoColors.white,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryLight.withOpacity(
                      0.2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _getSimpleFileIcon(
                      fileName,
                    ),
                    const SizedBox(
                      width:
                          12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontFamily:
                                  'Montserrat',
                              fontSize:
                                  14,
                              fontWeight:
                                  FontWeight.w500,
                              color:
                                  AppTheme.textPrimary,
                            ),
                            maxLines:
                                1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          Text(
                            '$fileSizeMB MB',
                            style: const TextStyle(
                              fontFamily:
                                  'Montserrat',
                              fontSize:
                                  12,
                              color:
                                  AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding:
                          EdgeInsets.zero,
                      onPressed:
                          () => _removeFile(
                            index,
                          ),
                      minimumSize: Size(
                        0,
                        0,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color:
                            CupertinoColors.systemRed,
                        size:
                            20,
                      ),
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

  Widget _getSimpleFileIcon(
    String fileName,
  ) {
    final extension =
        fileName
            .toLowerCase()
            .split(
              '.',
            )
            .last;
    final isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
    ].contains(
      extension,
    );

    if (isImage) {
      return const Icon(
        CupertinoIcons.photo,
        color:
            CupertinoColors.systemBlue,
        size:
            24,
      );
    } else {
      return const Icon(
        CupertinoIcons.doc,
        color:
            CupertinoColors.systemGrey,
        size:
            24,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return CupertinoPageScaffold(
      backgroundColor:
          AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor:
            AppTheme.background,
        middle: const Text(
          'Create Ticket',
          style: TextStyle(
            fontFamily:
                'Montserrat',
            color:
                CupertinoColors.black,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding:
              EdgeInsets.zero,
          onPressed:
              () => Navigator.pop(
                context,
              ),
          child: const Icon(
            CupertinoIcons.back,
            color:
                AppTheme.primaryDark,
          ),
        ),
      ),
      child: SafeArea(
        child:
            _loadingCategories
                ? const Center(
                  child:
                      CupertinoActivityIndicator(),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      _buildFormField(
                        label:
                            'Ticket Title *',
                        controller:
                            _titleController,
                        placeholder:
                            'Enter ticket title',
                      ),
                      const SizedBox(
                        height:
                            16,
                      ),

                      // Category Section
                      const Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          'Category *',
                          style: TextStyle(
                            fontFamily:
                                'Montserrat',
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height:
                            8,
                      ),
                      Container(
                        width:
                            double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical:
                              8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.surface,
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: CupertinoButton(
                          padding:
                              EdgeInsets.zero,
                          onPressed:
                              _showCategoryPicker,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategory?.name ??
                                    'Select category',
                                style: const TextStyle(
                                  fontFamily:
                                      'Montserrat',
                                  fontSize:
                                      16,
                                  color:
                                      AppTheme.textSecondary,
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_down,
                                color:
                                    AppTheme.background,
                                size:
                                    16,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            16,
                      ),
                      _buildFormField(
                        label:
                            'Description *',
                        controller:
                            _descriptionController,
                        placeholder:
                            'Describe your ticket in detail',
                        maxLines:
                            5,
                      ),

                      const SizedBox(
                        height:
                            16,
                      ),
                      _buildFileSection(),

                      const SizedBox(
                        height:
                            32,
                      ),
                      SizedBox(
                        width:
                            double.infinity,
                        child: CupertinoButton(
                          color:
                              AppTheme.primaryDark,
                          borderRadius: BorderRadius.circular(
                            36,
                          ),
                          onPressed:
                              _isSubmitting
                                  ? null
                                  : _submitForm,
                          child:
                              _isSubmitting
                                  ? const CupertinoActivityIndicator(
                                    color:
                                        CupertinoColors.white,
                                  )
                                  : const Text(
                                    'Submit Request',
                                    style: TextStyle(
                                      fontFamily:
                                          'Montserrat',
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          CupertinoColors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(
                        height:
                            32,
                      ),
                    ],
                  ),
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
