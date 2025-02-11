import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.validator,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool _isPreview = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Edit'),
                  icon: Icon(Icons.edit),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Preview'),
                  icon: Icon(Icons.visibility),
                ),
              ],
              selected: {_isPreview},
              onSelectionChanged: (value) {
                setState(() {
                  _isPreview = value.first;
                });
              },
            ),
            const Spacer(),
            if (!_isPreview) ...[
              IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: () => _insertMarkdown('**', '**'),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: () => _insertMarkdown('_', '_'),
              ),
              IconButton(
                icon: const Icon(Icons.link),
                onPressed: () => _insertMarkdown('[', '](url)'),
              ),
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () => _insertMarkdown('![alt text](', ')'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_isPreview)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minHeight: 200),
            child: MarkdownBody(
              data: widget.controller.text,
              selectable: true,
            ),
          )
        else
          TextFormField(
            controller: widget.controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Write your article in markdown...',
            ),
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            validator: widget.validator,
          ),
      ],
    );
  }

  void _insertMarkdown(String prefix, String suffix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final middle = selection.textInside(text);

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$middle$suffix',
    );

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.baseOffset + prefix.length,
        extentOffset: selection.extentOffset + prefix.length,
      ),
    );
  }
}
