// block_section.dart
import 'package:flutter/material.dart';
import 'package:cardmate/features/namecard/widgets/block_preview_card.dart';
import 'package:cardmate/features/namecard/widgets/block_readonly_card.dart';

class BlockSection extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final bool readOnly;
  const BlockSection({Key? key, required this.blocks, this.readOnly = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks
          .map((block) => readOnly
              ? BlockReadOnlyCard(block: block)
              : BlockPreviewCard(block: block))
          .toList(),
    );
  }
}
