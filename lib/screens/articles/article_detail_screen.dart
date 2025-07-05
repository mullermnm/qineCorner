import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/models/comment.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';
import 'package:qine_corner/features/quotes/presentation/screens/quote_share_screen.dart';
import 'package:qine_corner/screens/notes/widgets/add_note_dialog.dart';
import 'package:qine_corner/core/providers/notes_provider.dart';
import 'package:qine_corner/core/models/note.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/screens/error/widgets/animated_error_widget.dart';
import 'package:qine_corner/screens/articles/widgets/comment_item.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart';
import 'package:qine_corner/core/providers/comment_provider.dart';
import 'package:qine_corner/screens/articles/widgets/article_card.dart';

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
  String? _replyToId;
  String? _replyToUsername;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Fix the refresh functionality
    try {
      // Refresh article details
      await ref.refresh(articleDetailsProvider(widget.articleId).future);
      // Refresh comments
      if (mounted) {
        await ref
            .read(commentProvider(widget.articleId).notifier)
            .loadComments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final commentNotifier =
          ref.read(commentProvider(widget.articleId).notifier);

      // Debug log
      print('Submitting comment with parentId: $_replyToId');

      await commentNotifier.addComment(
        _commentController.text,
        parentId: _replyToId,
      );

      if (mounted) {
        _commentController.clear();
        setState(() => _replyToId = null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print('Error in UI: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailsProvider(widget.articleId));
    final currentUser = ref.watch(authNotifierProvider).value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_quote),
            onPressed: () => context.push('/quotes/manual-entry'),
            tooltip: 'Enter Quote Manually',
          ),
          if (currentUser != null) _buildOptionsMenu(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: articleAsync.when(
          data: (article) {
            if (article == null) {
              return const Center(child: Text('Article not found'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ArticleCard(
                    article: article,
                    showActions: true,
                    onTextSelected: (selectedText) =>
                        _onTextSelected(selectedText, article),
                  ),
                  const Divider(),
                  _buildCommentSection(),
                ],
              ),
            );
          },
          loading: () => const LoadingAnimation(),
          error: (e, _) => AnimatedErrorWidget(
            message: e.toString(),
            onRetry: _refreshData,
          ),
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
            await ref
                .read(articleProvider.notifier)
                .deleteArticle(widget.articleId);
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

  Widget _buildCommentSection() {
    final commentsAsync = ref.watch(commentProvider(widget.articleId));
    final currentUser = ref.watch(authNotifierProvider).value?.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Comments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (currentUser != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyToId != null
                          ? 'Write a reply...'
                          : 'Write a comment...',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
          _buildReplyingTo(),
        ],
        const SizedBox(height: 16),
        commentsAsync.when(
          data: (comments) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return CommentItem(
                comment: comment,
                onLike: (id) => ref
                    .read(commentProvider(widget.articleId).notifier)
                    .likeComment(id),
                onUnlike: (id) => ref
                    .read(commentProvider(widget.articleId).notifier)
                    .unlikeComment(id),
                onReply: _setupReply,
                onDelete: (id) async {
                  // Add delete confirmation dialog
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Comment'),
                      content: const Text(
                          'Are you sure you want to delete this comment?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true && mounted) {
                    await ref.read(articleServiceProvider).deleteComment(id);
                    ref.refresh(commentProvider(widget.articleId));
                  }
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading comments: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(Article article) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ArticleCard(
        article: article,
        showActions: false,
        onShare: () => _shareArticle(article),
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
        await ref
            .read(articleProvider.notifier)
            .unlikeArticle(article.id.toString());
      } else {
        await ref
            .read(articleProvider.notifier)
            .likeArticle(article.id.toString());
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

  Widget _buildReplyingTo() {
    if (_replyToId == null || _replyToUsername == null)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Replying to @$_replyToUsername',
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => setState(() {
              _replyToId = null;
              _replyToUsername = null;
            }),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _setupReply(String commentId, String username) {
    setState(() {
      _replyToId = commentId;
      _replyToUsername = username;
      // Focus the text field
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _onTextSelected(String? text, Article article) {
    if (text != null && text.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.note_add),
                title: const Text('Add Note'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AddNoteDialog(
                      bookTitle: article.title,
                      currentPage:
                          0, // Articles don't have pages, use 0 or handle differently
                      highlightedText: text,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Quote'),
                onTap: () {
                  Navigator.pop(context);
                  final authState = ref.read(authNotifierProvider).valueOrNull;
                  final userName = authState?.user?.name ?? 'Anonymous';
                  final quote = Quote(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: text,
                    bookTitle: article.title,
                    authorName:
                        article.author?.name, // Assuming article has an author
                    userName: userName,
                    createdAt: DateTime.now(),
                  );
                  context.push('/quotes/share', extra: quote);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
