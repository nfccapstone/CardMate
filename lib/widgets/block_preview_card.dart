// block_preview_card.dart
import 'package:flutter/material.dart';

class BlockPreviewCard extends StatelessWidget {
  final Map<String, dynamic> block;
  const BlockPreviewCard({Key? key, required this.block}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = block['type'] ?? 'text';
    final title = block['title'] ?? '';
    final content = block['content'] ?? '';

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
          Text(
            '[${type.toUpperCase()}] $title',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (type == 'photo')
            content.isEmpty
                ? const Icon(Icons.photo, size: 50, color: Colors.grey)
                : Image.network(content)
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
