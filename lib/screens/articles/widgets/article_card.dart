import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/utils/text_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleCard extends ConsumerStatefulWidget {
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
  ConsumerState<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<ArticleCard> {
  late Article article;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    article = widget.article;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/articles/${article.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      article.author!.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.author!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          timeago.format(article.createdAt),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      // Show options menu
                    },
                  ),
                ],
              ),
            ),

            // Article Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  _buildExpandableContent(context),
                ],
              ),
            ),

            // Article Image (only if exists)
            if (article.media.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                child: PageView.builder(
                  itemCount: article.media.length,
                  itemBuilder: (context, index) {
                    final media = article.media[index];
                    if (media.type == 'image') {
                      return Image.network(
                        media.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        );
                      } else if (media.type == 'video' && media.thumbnailUrl != null) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                              media.thumbnailUrl!,
                            fit: BoxFit.cover,
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
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            // Interaction Buttons
            _buildInteractionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableContent(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: article.content,
        style: const TextStyle(fontSize: 14),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);

    final bool hasTextOverflow = textPainter.didExceedMaxLines;

    return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
        Html(
          data: TextFormatter.parseMarkdown(article.content),
          style: {
            "body": Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(14),
              maxLines: _expanded ? null : 3,
              textOverflow: TextOverflow.ellipsis,
            ),
          },
        ),
        if (hasTextOverflow)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Show more',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
                          ),
                        ),
                      ],
    );
  }

  Widget _buildInteractionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildInteractionButton(
            context,
            icon: article.isLiked ? Icons.favorite : Icons.favorite_border,
            iconColor: article.isLiked ? Colors.red : null,
            label: '${article.likes}',
            onTap: () async {
              try {
                // Update UI immediately
                setState(() {
                  article = article.copyWith(
                    isLiked: !article.isLiked,
                    likes: article.isLiked ? article.likes - 1 : article.likes + 1,
                  );
                });

                // Make API call
                if (article.isLiked) {
                  await ref.read(articleProvider.notifier).likeArticle(article.id.toString());
                } else {
                  await ref.read(articleProvider.notifier).unlikeArticle(article.id.toString());
                }

                // Refresh the articles list in the background
                ref.refresh(articlesProvider);
              } catch (e) {
                // Revert on error
                setState(() {
                  article = article.copyWith(
                    isLiked: !article.isLiked,
                    likes: article.isLiked ? article.likes - 1 : article.likes + 1,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
          const SizedBox(width: 16),
          _buildInteractionButton(
            context,
            icon: Icons.comment_outlined,
            label: '${article.comments ?? 0}',
            onTap: () => context.push('/articles/${article.id}/comments'),
          ),
          const SizedBox(width: 16),
          _buildInteractionButton(
            context,
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: widget.onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (value) async {
        switch (value) {
          case 'save':
            // Implement save functionality
            break;
          case 'report':
            // Implement report functionality
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              Icon(Icons.bookmark_border),
              SizedBox(width: 8),
              Text('Save article'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'report',
                      child: Row(
                        children: [
              Icon(Icons.flag_outlined),
              SizedBox(width: 8),
              Text('Report'),
                        ],
                      ),
                    ),
                ],
    );
  }

  Widget _buildInteractionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom ExpandableText widget
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final String expandText;
  final String collapseText;
  final Color? linkColor;
  final bool animation;
  final Duration animationDuration;

  const ExpandableText(
    this.text, {
    super.key,
    this.maxLines = 2,
    this.style,
    this.expandText = 'Show more',
    this.collapseText = 'Show less',
    this.linkColor,
    this.animation = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Html(
            data: widget.text,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
                maxLines: widget.maxLines,
                textOverflow: TextOverflow.ellipsis,
              ),
            },
          ),
          secondChild: Html(
            data: widget.text,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
              ),
            },
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: widget.animation ? widget.animationDuration : Duration.zero,
        ),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? widget.collapseText : widget.expandText,
            style: TextStyle(
              color: widget.linkColor ?? Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
              ),
        ),
      ],
    );
  }
}
