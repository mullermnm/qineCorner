import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/article.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/utils/text_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:qine_corner/core/config/app_config.dart';

class ArticleCard extends ConsumerStatefulWidget {
  final Article article;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool showActions;
  final Function(String?)? onTextSelected;

  const ArticleCard({
    super.key,
    required this.article,
    this.onLike,
    this.onSave,
    this.onShare,
    this.showActions = true,
    this.onTextSelected,
  });

  @override
  ConsumerState<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<ArticleCard> {
  late Article article;
  bool _isExpanded = false;
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    article = widget.article;
    _initializeQuillController();
  }

  @override
  void didUpdateWidget(ArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.article != oldWidget.article) {
      article = widget.article;
      _initializeQuillController();
    }
  }

  void _initializeQuillController() {
    try {
      var contentJson = article.content;
      List<dynamic> deltaList;
      
      if (contentJson is String) {
        if (contentJson.contains('**')) {
          // Handle markdown-style bold text
          final text = contentJson.replaceAll('**', '');
          deltaList = [
            {"insert": text, "attributes": {"bold": true}},
            {"insert": "\n"}
          ];
        }
        else if (contentJson.startsWith('[{')) {
          try {
            // For the specific format we're seeing in the logs
            final content = contentJson;
            
            // Manual conversion without RegExp
            final fixed = content
              .replaceAll('insert:', '"insert":')
              .replaceAll('attributes:', '"attributes":')
              .replaceAll('bold:', '"bold":')
              .replaceAll('italic:', '"italic":')
              .replaceAll('link:', '"link":')
              .replaceAll('underline:', '"underline":')
              .replaceAll(': {', ': {')
              .replaceAll('true', 'true');
              
              print('Fixed JSON: $fixed');
            
            // Try parsing
            try {
              deltaList = jsonDecode(fixed);
              
              // Add missing newline if needed
              if (deltaList.isNotEmpty) {
                final lastItem = deltaList.last;
                if (lastItem is Map && lastItem.containsKey('insert') && 
                    lastItem['insert'] is String && !lastItem['insert'].toString().endsWith('\n')) {
                  deltaList.add({"insert": "\n"});
                }
              }
            } catch (e) {
              print('JSON parse error: $e');
              // Fallback to direct conversion
              deltaList = _manuallyParseDelta(content);
            }
          }
          catch (e) {
            print('Content processing error: $e');
            deltaList = [{"insert": contentJson.toString()}, {"insert": "\n"}];
          }
        } else {
          deltaList = [{"insert": contentJson}, {"insert": "\n"}];
        }
      } else {
        deltaList = [{"insert": contentJson.toString()}, {"insert": "\n"}];
      }

      final doc = Document.fromJson(deltaList);
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _quillController.addListener(() {
        if (widget.onTextSelected != null) {
          final selection = _quillController.selection;
          final selectedText = _quillController.document.toPlainText().substring(selection.baseOffset, selection.extentOffset);
          widget.onTextSelected!(selectedText);
        }
      });
    } catch (e) {
      print('Error parsing content: $e');
      final doc = Document()..insert(0, 'Error displaying content')..insert(1, '\n');
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }
  
  List<dynamic> _manuallyParseDelta(String content) {
    final result = <Map<String, dynamic>>[];
    
    // Handle potential newlines in the content
    content = content.trim();
    
    // Remove outer brackets
    if (content.startsWith('[') && content.endsWith(']')) {
      content = content.substring(1, content.length - 1).trim();
    }
    
    // Split by operation
    final operations = <String>[];
    int braceCount = 0;
    int startIndex = 0;
    
    for (int i = 0; i < content.length; i++) {
      if (content[i] == '{') braceCount++;
      else if (content[i] == '}') {
        braceCount--;
        if (braceCount == 0) {
          operations.add(content.substring(startIndex, i + 1).trim());
          if (i + 2 < content.length) {
            startIndex = i + 2; // Skip the '}, ' part
          }
        }
      }
    }
    
    for (final op in operations) {
      final map = <String, dynamic>{};
      
      // Extract insert content with proper handling of string values
      final insertPattern = RegExp(r'insert:\s*([^,}]+)');
      final insertMatch = insertPattern.firstMatch(op);
      if (insertMatch != null) {
        final value = insertMatch.group(1)?.trim() ?? '';
        // Store all values as strings in the insert field
        map['insert'] = value;
      }
      
      // Extract attributes
      if (op.contains('attributes:')) {
        map['attributes'] = <String, dynamic>{};
        
        if (op.contains('bold: true')) {
          map['attributes']['bold'] = true;
        } else if (op.contains('bold: false')) {
          map['attributes']['bold'] = false;
        }
        
        if (op.contains('italic: true')) {
          map['attributes']['italic'] = true;
        } else if (op.contains('italic: false')) {
          map['attributes']['italic'] = false;
        }
      }
      
      if (map.isNotEmpty) {
        result.add(map);
      }
    }
    
    // Ensure newline at the end
    if (result.isNotEmpty && 
        result.last.containsKey('insert') &&
        !result.last['insert'].toString().endsWith('\n')) {
      result.add({"insert": "\n"});
    }
    
    return result;
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
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
                    onPressed: () => _buildOptionsMenu(context),
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
                  _buildContentSection(),
                ],
              ),
            ),

            // Media Section
            if (article.media.isNotEmpty)
              _buildMediaSection(),

            // Interaction Buttons
            _buildInteractionButtons(context),

            // Interaction Stats
            _buildInteractionStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Limited height container when collapsed
        Container(
          constraints: BoxConstraints(
            maxHeight: _isExpanded ? double.infinity : 80, // Show only ~2-3 lines when collapsed
          ),
          child: ClipRect(
            child: QuillEditor(
              controller: _quillController,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              
              config: QuillEditorConfig(
                requestKeyboardFocusOnCheckListChanged: false,
                checkBoxReadOnly: true,
                autoFocus: false,
                onTapOutsideEnabled: false,
              
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    TextStyle(fontSize: 16, height: 1.5, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  // Add other required styles
                ),
                scrollable: false,
                showCursor: false,
                enableInteractiveSelection: true, // Enable text selection
                disableClipboard: false, // Allow clipboard operations
              ),
            ),
          ),
        ),
        
        // Show more/less button
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _isExpanded ? 'Show less' : 'Show more',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    if (article.media.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the first media item
    final mediaItem = article.media.first;
    
    // Convert relative URL to absolute URL using AppConfig
    final imageUrl = AppConfig.getAssetUrl(mediaItem.url);
    
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
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

  Widget _buildInteractionStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: article.isLiked ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${article.likes}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              const Icon(
                Icons.comment_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${article.comments} ${article.comments == 1 ? 'comment' : 'comments'}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
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
          firstChild: html.Html(
            data: widget.text,
            style: {
              "body": html.Style(
                fontSize: html.FontSize(14),
                maxLines: widget.maxLines,
                textOverflow: TextOverflow.ellipsis,
              ),
            },
          ),
          secondChild: html.Html(
            data: widget.text,
            style: {
              "body": html.Style(
                fontSize: html.FontSize(14),
              ),
            },
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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

