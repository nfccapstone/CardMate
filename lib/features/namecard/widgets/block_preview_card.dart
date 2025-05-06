// block_preview_card.dart
import 'package:flutter/material.dart';

class BlockPreviewCard extends StatefulWidget {
  final Map<String, dynamic> block;
  const BlockPreviewCard({Key? key, required this.block}) : super(key: key);

  @override
  State<BlockPreviewCard> createState() => _BlockPreviewCardState();
}

class _BlockPreviewCardState extends State<BlockPreviewCard> {
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '[${type.toUpperCase()}] $title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (type == 'photo')
            if (content is List) ...[
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
            ]
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: type == 'link' ? Colors.blue : Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
