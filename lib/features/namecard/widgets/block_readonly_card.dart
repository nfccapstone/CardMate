import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class BlockReadOnlyCard extends StatefulWidget {
  final Map<String, dynamic> block;
  const BlockReadOnlyCard({Key? key, required this.block}) : super(key: key);

  @override
  State<BlockReadOnlyCard> createState() => _BlockReadOnlyCardState();
}

class _BlockReadOnlyCardState extends State<BlockReadOnlyCard> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.block['type'] ?? 'text';
    final title = widget.block['title'] ?? '';
    final content = widget.block['content'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          if (type == 'photo' && content is List) ...[
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: content.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        content[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 50,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (content.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          content.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _pageController.hasClients &&
                                      _pageController.page?.round() == index
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${content.length}장의 사진',
              style: const TextStyle(color: Colors.grey),
            ),
          ] else if (type == 'text') ...[
            if (content != null && content is String)
              Builder(
                builder: (context) {
                  try {
                    final quillDoc = quill.Document.fromJson(jsonDecode(content));
                    final quillController = quill.QuillController(
                      document: quillDoc,
                      selection: const TextSelection.collapsed(offset: 0),
                    );
                    return quill.QuillEditor(
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                      configurations: quill.QuillEditorConfigurations(
                        controller: quillController,
                        sharedConfigurations: const quill.QuillSharedConfigurations(),
                        enableInteractiveSelection: false,
                        customStyles: quill.DefaultStyles(
                          paragraph: quill.DefaultTextBlockStyle(
                            TextStyle(color: Colors.black, fontSize: 14),
                            const quill.VerticalSpacing(0, 0),
                            const quill.VerticalSpacing(0, 0),
                            null,
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    return Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
          ],
        ],
      ),
    );
  }
} 