// block_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/widgets/block_preview_card.dart';
import 'package:cardmate/features/namecard/widgets/block_readonly_card.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';

class BlockSection extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final bool readOnly;
  const BlockSection({Key? key, required this.blocks, this.readOnly = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox();
    
    if (readOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: blocks
            .map((block) => BlockReadOnlyCard(block: block))
            .toList(),
      );
    }

    final editController = Get.find<EditCardController>();
    
    return Obx(() => ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        editController.reorderBlocks(oldIndex, newIndex);
      },
      children: editController.blocks.map((block) {
        return BlockPreviewCard(
          key: ValueKey(block['id']),
          block: block,
        );
      }).toList(),
    ));
  }
}
