import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';
import 'package:qine_corner/widgets/markdown_editor.dart';

class ArticleEditorScreen extends ConsumerStatefulWidget {
  final String? articleId;

  const ArticleEditorScreen({
    super.key,
    this.articleId,
  });

  @override
  ConsumerState<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends ConsumerState<ArticleEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.articleId != null) {
      _loadArticle();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadArticle() async {
    final article = await ref.read(articleServiceProvider).getArticleDetails(widget.articleId!);
    if (article != null) {
      setState(() {
        _titleController.text = article.title;
        _contentController.text = article.content;
        _tags.addAll(article.tags);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveArticle(bool isDraft) async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      if (widget.articleId == null) {
        // Create new article
        await ref.read(articleProvider.notifier).createArticle(
              title: _titleController.text,
              content: _contentController.text,
              tags: _tags,
              imageFile: _selectedImage,
              isDraft: isDraft,
            );
      } else {
        // Update existing article
        await ref.read(articleProvider.notifier).updateArticle(
              widget.articleId!,
              title: _titleController.text,
              content: _contentController.text,
              tags: _tags,
              imageFile: _selectedImage,
              status: isDraft ? ArticleStatus.draft : ArticleStatus.published,
            );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = widget.articleId != null
        ? ref.watch(articleDetailsProvider(widget.articleId!))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.articleId == null ? 'New Article' : 'Edit Article'),
        actions: [
          TextButton(
            onPressed: () => _saveArticle(true),
            child: const Text('Save as Draft'),
          ),
          TextButton(
            onPressed: () => _saveArticle(false),
            child: const Text('Publish'),
          ),
        ],
      ),
      body: articleAsync.when(
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedImage != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Add Image'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              MarkdownEditor(
                controller: _contentController,
                minLines: 10,
                maxLines: null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Add Tag',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        loading: () => const LoadingAnimation(),
        error: (error, stackTrace) => AnimatedErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(articleDetailsProvider(widget.articleId!)),
        ),
      ),
    );
  }
}
