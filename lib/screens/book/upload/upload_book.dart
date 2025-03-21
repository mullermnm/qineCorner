import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/authors_provider.dart';
import 'dart:io';
import 'package:qine_corner/core/providers/categories_provider.dart';
import 'package:qine_corner/core/providers/books_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/common/widgets/primary_button.dart';

class UploadBook extends ConsumerStatefulWidget {
  const UploadBook({super.key});

  @override
  ConsumerState<UploadBook> createState() => _UploadBookState();
}

class _UploadBookState extends ConsumerState<UploadBook> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String? _selectedAuthor;
  List<String> _selectedCategories = [];
  String? _coverImagePath;
  String? _bookFilePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload New Book'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurfaceBackground : AppColors.lightSurfaceBackground,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
                ? [AppColors.darkBackground, AppColors.darkBackground.withOpacity(0.8)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover Image Upload
                _buildCoverImageSection(isDark),
                const SizedBox(height: 24),

                // Book Details
                _buildSectionHeader('Book Details', isDark),
                const SizedBox(height: 16),
                _buildBookDetailsSection(isDark),
                const SizedBox(height: 32),

                // File Upload
                _buildSectionHeader('Book File', isDark),
                const SizedBox(height: 16),
                _buildFileUploadSection(isDark),
                const SizedBox(height: 40),

                // Submit Button
                _buildSubmitButton(isDark),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImageSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Cover Image', isDark),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _pickCoverImage,
            child: Container(
              height: 220,
              width: 160,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: _coverImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_coverImagePath!), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upload Cover',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildBookDetailsSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInputField(
            controller: _titleController,
            label: 'Book Title',
            icon: Icons.book,
            validator: (value) => value!.isEmpty ? 'Please enter title' : null,
            hintText: 'Enter book title',
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildAuthorDropdown(isDark),
          const SizedBox(height: 20),
          
          _buildCategoryMultiSelect(isDark),
          const SizedBox(height: 20),
          
          _buildInputField(
            controller: _yearController,
            label: 'Publishing Year',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            hintText: 'Enter publishing year',
            isDark: isDark,
            validator: (value) {
              if (value!.isEmpty) return 'Please enter year';
              if (int.tryParse(value) == null) return 'Invalid year';
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          _buildDescriptionField(isDark),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).primaryColor.withOpacity(0.7),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
                        
  Widget _buildAuthorDropdown(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final authors = ref.watch(authorsProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: authors.when(
                    data: (authorsList) => DropdownButtonFormField<String>(
                      value: _selectedAuthor,
                      decoration: InputDecoration(
                        labelText: 'Select Author',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: authorsList.map((author) => DropdownMenuItem(
                        value: author.id.toString(),
                        child: Text(author.name),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedAuthor = value),
                      validator: (value) => value == null ? 'Please select author' : null,
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      isExpanded: true,
                      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    ),
                    loading: () => Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text('Error: $error'),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  context.push('/upload-author');
                },
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text("Can't find your author? Add new"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryMultiSelect(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final categories = ref.watch(categoriesProvider);
        return categories.when(
          data: (categoriesList) => GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Select Categories'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_selectedCategories.length} selected',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: SizedBox(
                          width: double.maxFinite,
                          height: 400,
                          child: ListView.builder(
                            itemCount: categoriesList.length,
                            itemBuilder: (context, index) {
                              final category = categoriesList[index];
                              final isSelected = _selectedCategories.contains(category.id);
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                elevation: isSelected ? 2 : 0,
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  title: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  secondary: Icon(
                                    _getCategoryIcon(category.name),
                                    color: _getCategoryColor(category.name),
                                  ),
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedCategories.add(category.id);
                                      } else {
                                        _selectedCategories.remove(category.id);
                                      }
                                    });
                                    setModalState(() {});
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('Done'),
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedCategories.isNotEmpty
                      ? Theme.of(context).primaryColor
                      : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedCategories.isEmpty
                          ? 'Select Categories'
                          : '${_selectedCategories.length} categories selected',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _selectedCategories.isNotEmpty
                          ? Theme.of(context).primaryColor
                          : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: _selectedCategories.isNotEmpty
                          ? Colors.white
                          : isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      validator: (value) => value!.isEmpty ? 'Please enter description' : null,
      decoration: InputDecoration(
        labelText: 'Description',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 64),
          child: Icon(
            Icons.description,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildFileUploadSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickBookFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _bookFilePath != null
                      ? Theme.of(context).primaryColor
                      : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _bookFilePath != null ? Icons.check_circle : Icons.cloud_upload,
                    size: 48,
                    color: _bookFilePath != null
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _bookFilePath != null ? 'File Selected' : 'Tap to select PDF or EPUB',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _bookFilePath != null
                          ? Colors.green
                          : isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  if (_bookFilePath != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _bookFilePath!.split('/').last,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isLoading 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.upload_file),
                  SizedBox(width: 8),
                  Text(
                    'Upload Book',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fiction': return Icons.auto_stories;
      case 'fantasy': return Icons.castle;
      case 'mystery': return Icons.search;
      case 'romance': return Icons.favorite;
      case 'thriller': return Icons.psychology;
      case 'sci-fi': return Icons.rocket;
      case 'history': return Icons.history_edu;
      case 'biography': return Icons.person;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fiction': return Colors.blue;
      case 'fantasy': return Colors.purple;
      case 'mystery': return Colors.amber;
      case 'romance': return Colors.pink;
      case 'thriller': return Colors.red;
      case 'sci-fi': return Colors.indigo;
      case 'history': return Colors.brown;
      case 'biography': return Colors.teal;
      default: return Colors.grey;
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _coverImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickBookFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
      );

      if (result != null) {
        setState(() {
          _bookFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_isLoading) return;
    
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_coverImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cover image')),
      );
      return;
    }
    if (_bookFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a book file')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      await ref.read(booksProvider.notifier).uploadBook(
        title: _titleController.text.trim(),
        author: _selectedAuthor!,
        category: _selectedCategories.join(','),
        publishedYear: "${_yearController.text}-01-01",
        description: _descriptionController.text.trim(),
        coverImagePath: _coverImagePath!,
        bookFilePath: _bookFilePath!,
      );

      if (!mounted) return;
      
      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _yearController.clear();
      setState(() {
        _selectedAuthor = null;
        _selectedCategories = [];
        _coverImagePath = null;
        _bookFilePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Book uploaded successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Navigate to home
      if (!mounted) return;
      context.go('/');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error uploading book: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}