import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class MarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final int? minLines;
  final int? maxLines;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.minLines,
    this.maxLines,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    
    // Listen to changes and update the text controller
    _controller.addListener(() {
      final delta = _controller.document.toDelta();
      widget.controller.text = delta.toJson().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
      children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              showClearFormat: true,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: false,
              showUnderLineButton: true,
              showStrikeThrough: true,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showHeaderStyle: true,
              showLink: true,
              showQuote: true,
              showIndent: true,
              showListNumbers: true,
              showListBullets: true,
              showCodeBlock: false,
              showSearchButton: false,
              showDirection: false,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: QuillEditor(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: _scrollController,
                config: QuillEditorConfig(
                  placeholder: 'Write your article...',
                  autoFocus: false,
                  expands: false,
                  padding: const EdgeInsets.all(8),
                  embedBuilders: [...FlutterQuillEmbeds.editorBuilders()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
