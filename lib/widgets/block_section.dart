// block_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/edit_card_controller.dart';
import 'package:cardmate/widgets/block_preview_card.dart'; // 경로는 프로젝트 구조에 맞게 수정

class BlockSection extends StatelessWidget {
  final EditCardController controller;
  const BlockSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.blocks.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: controller.blocks
            .map((block) => BlockPreviewCard(block: block))
            .toList(),
      );
    });
  }
}
