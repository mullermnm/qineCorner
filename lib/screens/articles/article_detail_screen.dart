import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/models/comment.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';
import 'package:qine_corner/screens/articles/widgets/comment_item.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailsProvider(widget.articleId));
    final commentsAsync = ref.watch(articleCommentsProvider(widget.articleId));
    final currentUser = ref.watch(authNotifierProvider).value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          if (currentUser != null) _buildOptionsMenu(),
        ],
      ),
      body: articleAsync.when(
          data: (article) {
          if (article == null) return const Center(child: Text('Article not found'));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Article content
                    _buildArticleContent(article),
                    
                    // Interaction buttons
                    _buildInteractionButtons(article),
                    
                    const Divider(),
                    
                    // Comments section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: commentsAsync.when(
                        data: (comments) => Column(
                          children: comments.map((comment) => 
                            CommentItem(
                              comment: comment,
                              onReply: () => _showReplyDialog(comment),
                              onEdit: currentUser?.id == comment.userId 
                                ? () => _showEditCommentDialog(comment)
                                : null,
                              onDelete: currentUser?.id == comment.userId
                                ? () => _deleteComment(comment.id)
                                : null,
                            ),
                          ).toList(),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error loading comments: $e'),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Comment input
              if (currentUser != null)
                _buildCommentInput(),
            ],
          );
        },
        loading: () => const LoadingAnimation(),
        error: (e, _) => AnimatedErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(articleDetailsProvider(widget.articleId)),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            context.push('/articles/${widget.articleId}/edit');
            break;
          case 'delete':
            await ref.read(articleProvider.notifier).deleteArticle(widget.articleId);
            if (mounted) context.pop();
            break;
                  }
                },
                itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_commentController.text.trim().isNotEmpty) {
                // Add comment functionality here
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(Article article) {
    return Container(
      color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Author header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                  children: [
                    CircleAvatar(
                  radius: 20,
                      backgroundImage: article.author.profileImage != null
                          ? NetworkImage(article.author.profileImage!)
                          : null,
                      child: article.author.profileImage == null
                      ? Text(article.author.name[0].toUpperCase())
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.author.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeago.format(article.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Article content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Html(data: article.content),
              ],
            ),
          ),

          // Media content
          if (article.media.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              width: double.infinity,
              child: PageView.builder(
                itemCount: article.media.length,
                itemBuilder: (context, index) {
                  final media = article.media[index];
                  return Image.network(
                    media.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractionButtons(Article article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInteractionButton(
            icon: article.isLiked ? Icons.favorite : Icons.favorite_border,
            label: '${article.likes ?? 0}',
            iconColor: article.isLiked ? Colors.red : null,
            onTap: () => _handleLike(article),
          ),
          _buildInteractionButton(
            icon: Icons.comment_outlined,
            label: '${article.comments ?? 0} Comments',
            onTap: () => _focusCommentInput(),
          ),
          _buildInteractionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => _shareArticle(article),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLike(Article article) async {
    try {
      if (article.isLiked) {
        await ref.read(articleProvider.notifier).unlikeArticle(article.id.toString());
      } else {
        await ref.read(articleProvider.notifier).likeArticle(article.id.toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _focusCommentInput() {
    // Add focus to comment input
  }

  void _shareArticle(Article article) {
    // Implement share functionality
  }

  Future<void> _showReplyDialog(Comment comment) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement reply functionality
              Navigator.pop(context);
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCommentDialog(Comment comment) async {
    final controller = TextEditingController(text: comment.content);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement edit functionality
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    // Implement delete functionality
    // Show confirmation dialog first
  }
}
