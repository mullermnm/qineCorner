import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/models/comment.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends ConsumerStatefulWidget {
  final Comment comment;
  final Function(String) onLike;
  final Function(String) onUnlike;
  final Function(String, String) onReply;
  final Function(String) onDelete;
  final bool isReply;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onUnlike,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
  });

  @override
  ConsumerState<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends ConsumerState<CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authNotifierProvider).value?.user;
    final isAuthor = currentUser?.id == widget.comment.userId;
    final hasReplies = widget.comment.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment card
        Card(
          margin: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: widget.isReply ? 40 : 0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        widget.comment.author.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.author.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            timeago.format(widget.comment.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isAuthor)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => widget.onDelete(widget.comment.id),
                        color: Colors.red,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.comment.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (widget.comment.isLiked) {
                          widget.onUnlike(widget.comment.id);
                        } else {
                          widget.onLike(widget.comment.id);
                        }
                      },
                      icon: Icon(
                        widget.comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: widget.comment.isLiked ? Colors.red : null,
                      ),
                      label: Text('${widget.comment.likes}'),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onReply(widget.comment.id, widget.comment.author.name),
                      icon: const Icon(Icons.reply, size: 20),
                      label: const Text('Reply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Show replies toggle button for main comments only
        if (hasReplies && !widget.isReply)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: TextButton.icon(
              onPressed: () => setState(() => _showReplies = !_showReplies),
              icon: Icon(
                _showReplies ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                _showReplies 
                    ? 'Hide replies'
                    : '${widget.comment.replies.length} ${widget.comment.replies.length == 1 ? 'reply' : 'replies'}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Show replies only when expanded
        if (_showReplies && hasReplies)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.comment.replies.map((reply) => CommentItem(
                comment: reply,
                onLike: widget.onLike,
                onUnlike: widget.onUnlike,
                onReply: widget.onReply,
                onDelete: widget.onDelete,
                isReply: true,
              )).toList(),
            ),
          ),
      ],
    );
  }
} 