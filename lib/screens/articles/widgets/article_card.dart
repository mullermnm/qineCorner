import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool showActions;

  const ArticleCard({
    super.key,
    required this.article,
    this.onLike,
    this.onSave,
    this.onShare,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/articles/${article.id.toString()}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.media.isNotEmpty) ...[
              // Article Media
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: article.media.length,
                  itemBuilder: (context, index) {
                    final media = article.media[index];
                    if (media.type == 'image') {
                      return Image.network(
                        media.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Video thumbnail
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            media.thumbnailUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.video_file,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ] else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.article,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (article.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: article.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Preview
                  Text(
                    article.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Author and Stats
                  Row(
                    children: [
                      if (article.author != null) ...[
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(article.author!.profileImage ?? ''),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.author!.name,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                '${_formatDate(article.createdAt)} • ${article.readTime}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (showActions) ...[
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: onLike,
                        ),
                        Text(
                          article.likes.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: onSave,
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: onShare,
                        ),
                      ],
                    ],
                  ),
                  // Stats Row
                  if (showActions)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          _StatChip(
                            icon: Icons.remove_red_eye,
                            count: article.views,
                          ),
                          const SizedBox(width: 16),
                          _StatChip(
                            icon: Icons.comment,
                            count: article.comments,
                          ),
                          const SizedBox(width: 16),
                          _StatChip(
                            icon: Icons.share,
                            count: article.shares,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;

  const _StatChip({
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
