import 'package:flutter/material.dart';
import 'package:qine_corner/core/models/comment.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment.content),
            if (onReply != null || onEdit != null || onDelete != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReply != null)
                    TextButton(onPressed: onReply, child: const Text('Reply')),
                  if (onEdit != null)
                    TextButton(onPressed: onEdit, child: const Text('Edit')),
                  if (onDelete != null)
                    TextButton(
                      onPressed: onDelete,
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 