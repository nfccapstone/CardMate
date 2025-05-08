// block_section.dart
import 'package:flutter/material.dart';
import 'package:cardmate/features/namecard/widgets/block_preview_card.dart';

class BlockSection extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  const BlockSection({Key? key, required this.blocks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks
          .map((block) => BlockPreviewCard(block: block))
          .toList(),
    );
  }
}
