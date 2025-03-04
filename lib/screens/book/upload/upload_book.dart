import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/authors_provider.dart';
import 'dart:io';
import 'package:qine_corner/core/providers/categories_provider.dart';
import 'package:qine_corner/core/providers/books_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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
     return Scaffold(
      appBar: AppBar(
        title: const Text('Upload New Book',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white.withOpacity(0.9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover Image Upload
                _buildCoverImageSection(),
                const SizedBox(height: 32),

                // Book Details
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: _buildBookDetailsSection(),
                ),
                const SizedBox(height: 32),

                // File Upload
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: _buildFileUploadSection(),
                ),
                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImageSection() {
    return GestureDetector(
      onTap: _pickCoverImage,
                    child: Container(
        height: 200,
                      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
                        border: Border.all(
            color: _coverImagePath != null 
                ? Colors.transparent
                : Theme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: _coverImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.file(File(_coverImagePath!), fit: BoxFit.cover),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, size: 20),
                      ),
                    ),
                  ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                  Icon(Icons.add_photo_alternate,
                      size: 40,
                      color: Theme.of(context).primaryColor),
                                const SizedBox(height: 12),
                  Text('Upload Cover Image',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                              ],
                            ),
                    ),
    );
  }

  Widget _buildBookDetailsSection() {
    return Column(
      children: [
        _buildInputField(
          controller: _titleController,
          label: 'Book Title',
          icon: Icons.title,
          validator: (value) => value!.isEmpty ? 'Please enter title' : null,
          hintText: 'Enter book title',
        ),
        const SizedBox(height: 20),
        
        _buildAuthorDropdown(),
        const SizedBox(height: 20),
        _buildCategoryMultiSelect(),
        
        const SizedBox(height: 20),
        
        _buildInputField(
          controller: _yearController,
          label: 'Publishing Year',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
          hintText: 'Enter publishing year',
          validator: (value) {
            if (value!.isEmpty) return 'Please enter year';
            if (int.tryParse(value) == null) return 'Invalid year';
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black), // Added text color
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        hintStyle: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5)),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Container(
          width: 50,
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                            ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
        filled: true,
        fillColor: Colors.white,
                        ),
    );
  }
                        
  Widget _buildAuthorDropdown() {
    return Consumer(
                          builder: (context, ref, child) {
        final authors = ref.watch(authorsProvider);
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: authors.when(
                    data: (authorsList) => DropdownButtonFormField<String>(
                                  value: _selectedAuthor,
                      decoration: _dropdownDecoration('Select Author', Icons.person, 'Choose an author'),
                      items: authorsList.map((author) => DropdownMenuItem(
                        value: author.id.toString(),
                        child: Text(author.name, 
                          style: TextStyle(color: Theme.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis
                        ),
                                  )).toList(),
                                  onChanged: (value) => setState(() => _selectedAuthor = value),
                      validator: (value) => value == null ? 'Please select author' : null,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      dropdownColor: Colors.white,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.push('/upload-author');
                },
                child: const Text("Can't find your author? Add new"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryMultiSelect() {
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
                            Text(
                              '${_selectedCategories.length} selected',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        content: Container(
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: ListView.builder(
                            itemCount: categoriesList.length,
                            itemBuilder: (context, index) {
                              final category = categoriesList[index];
                              final isSelected = _selectedCategories.contains(category.id);
                              
                              return Card(
                                elevation: 0,
                                color: isSelected 
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : null,
                                child: ListTile(
                                  leading: Icon(
                                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                  ),
                                  title: Text(
                                    category.name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedCategories.remove(category.id);
                                      } else {
                                        _selectedCategories.add(category.id);
                                      }
                                    });
                                    setModalState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    }
                  );
                },
              );
            },
            child: InputDecorator(
              decoration: _dropdownDecoration('Selected Categories', Icons.category, 'Choose categories'),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedCategories.isEmpty
                          ? 'Select Categories'
                          : '${_selectedCategories.length} categories selected',
                      style: TextStyle(
                        color: _selectedCategories.isEmpty
                            ? Theme.of(context).primaryColor.withOpacity(0.5)
                            : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      hintStyle: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5)),
      floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      prefixIcon: Container(
        width: 50,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      style: const TextStyle(color: Colors.black), // Added text color
      validator: (value) => value!.isEmpty ? 'Please enter description' : null,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Enter book description',
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        hintStyle: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.5)),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: Container(
          width: 50,
          padding: const EdgeInsets.all(12),
          child: Icon(Icons.description, color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
        Text('Book File', style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickBookFile,
          icon: Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
                          label: Text(
            _bookFilePath != null ? 'Change File' : 'Select Book File',
            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
        if (_bookFilePath != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                            child: Text(
                    _bookFilePath!.split('/').last,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _submitForm,
      icon: _isLoading 
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const Icon(Icons.cloud_upload, size: 24),
      label: Text(_isLoading ? 'Uploading...' : 'Publish Book',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
    );
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
        publishedYear: "${_yearController.text}-01-01", // Convert to proper date format
        description: _descriptionController.text.trim(),
          coverImagePath: _coverImagePath!,
          bookFilePath: _bookFilePath!,
        );

      if (!mounted) return;
      
      // Clear all input fields
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
          const SnackBar(content: Text('Book uploaded successfully!')),
        );
      
      // Navigate to home
      if (!mounted) return;
      context.go('/');

      } catch (e) {
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading book: $e')),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}