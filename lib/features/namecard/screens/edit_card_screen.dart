import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:cardmate/features/namecard/controllers/contact_controller.dart';
import 'package:cardmate/features/namecard/widgets/profile_section.dart';
import 'package:cardmate/features/namecard/widgets/contact_section.dart';
import 'package:cardmate/features/namecard/widgets/block_section.dart';
import 'package:cardmate/features/namecard/services/i_contact_service.dart';
import 'package:cardmate/features/namecard/widgets/block_preview_card.dart';
import 'package:cardmate/features/namecard/widgets/link_section.dart';
import 'package:cardmate/features/namecard/utils/platform_icon_utils.dart';

enum LinkPlatform { direct, instagram, github }

class EditCardScreen extends StatelessWidget {
  final String cardId;
  const EditCardScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final editController = Get.find<EditCardController>();
    final contactController = Get.put(
      ContactController(
        contactService: Get.find<IContactService>(),
        cardId: cardId,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '디지털 명함 편집',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (editController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final blocks = editController.blocks;
        final List<Widget> children = [];
        // 프로필 카드
        children.add(_NonReorderable(
          key: const ValueKey('profile'),
          child: Container(
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
            child: ProfileSection(basicInfo: editController.basicInfo),
          ),
        ));
        children.add(const _NonReorderable(
            key: ValueKey('profile_space'), child: SizedBox(height: 12)));
        // 연락처 카드
        children.add(_NonReorderable(
          key: const ValueKey('contact'),
          child: Container(
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
            child: ContactSection(controller: contactController),
          ),
        ));
        children.add(const _NonReorderable(
            key: ValueKey('contact_space'), child: SizedBox(height: 12)));
        // 링크 카드
        children.add(_NonReorderable(
          key: const ValueKey('links'),
          child: Container(
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
            child: const LinkSection(),
          ),
        ));
        children.add(const _NonReorderable(
            key: ValueKey('links_space'), child: SizedBox(height: 12)));
        final int blockStartIndex = children.length;
        // 블록 카드
        children.addAll(blocks.map((block) => BlockPreviewCard(
              key: ValueKey(block['id']),
              block: block,
            )));
        children.add(const _NonReorderable(
            key: ValueKey('block_space'), child: SizedBox(height: 20)));
        // 추가 버튼들
        children.add(_NonReorderable(
          key: const ValueKey('contact_add_btn'),
          child: _buildContactAddButton(context, contactController),
        ));
        children.add(const _NonReorderable(
            key: ValueKey('contact_add_space'), child: SizedBox(height: 12)));
        children.add(_NonReorderable(
          key: const ValueKey('block_add_btn'),
          child: _buildBlockAddButton(context, editController),
        ));
        children.add(const _NonReorderable(
            key: ValueKey('block_add_space'), child: SizedBox(height: 12)));
        children.add(_NonReorderable(
          key: const ValueKey('link_add_btn'),
          child: _buildLinkAddButton(context),
        ));
        children.add(const _NonReorderable(
            key: ValueKey('bottom_space'), child: SizedBox(height: 40)));

        return ReorderableListView(
          onReorder: (oldIndex, newIndex) {
            final blockStart = blockStartIndex;
            final blockEnd = blockStart + blocks.length - 1;
            if (oldIndex < blockStart ||
                oldIndex > blockEnd ||
                newIndex < blockStart ||
                newIndex > blockEnd + 1) {
              return;
            }
            int blockOldIndex = oldIndex - blockStart;
            int blockNewIndex = newIndex - blockStart;
            if (blockNewIndex > blockOldIndex) blockNewIndex -= 1;
            if (blockNewIndex < 0) blockNewIndex = 0;
            if (blockNewIndex > blocks.length) blockNewIndex = blocks.length;
            editController.reorderBlocks(blockOldIndex, blockNewIndex);
          },
          children: children,
        );
      }),
    );
  }

  Widget _buildContactAddButton(
      BuildContext context, ContactController controller) {
    return GestureDetector(
      onTap: () => controller.showContactTypeSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ 연락처 추가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBlockAddButton(
      BuildContext context, EditCardController controller) {
    return GestureDetector(
      onTap: () => _showBlockTypeBottomSheet(controller),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ 블록 추가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showBlockTypeBottomSheet(EditCardController controller) {
    Get.toNamed('/blockCreate');
  }

  void _navigateToBlockCreateScreen(
      String blockType, EditCardController controller) async {
    // 이 함수는 더 이상 사용하지 않음
    // Get.back(); // BottomSheet 닫기
    // await Get.toNamed(
    //   '/blockCreate',
    //   arguments: {'type': blockType},
    // );
  }

  Widget _buildLinkAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showAddLinkBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ 링크 추가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void showAddLinkBottomSheet(BuildContext context) {
    final editController = Get.find<EditCardController>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController urlController = TextEditingController();
    LinkPlatform selectedPlatform = LinkPlatform.direct;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String getHintText() {
              switch (selectedPlatform) {
                case LinkPlatform.instagram:
                  return '인스타그램 닉네임 입력';
                case LinkPlatform.github:
                  return 'Repository 이름 입력';
                case LinkPlatform.direct:
                default:
                  return 'https://your.site';
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 32,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '링크 추가',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text('제목',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: '예: 회사 홈페이지',
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.language,
                            color: selectedPlatform == LinkPlatform.direct
                                ? Colors.black87
                                : Colors.grey),
                        onPressed: () => setState(
                            () => selectedPlatform = LinkPlatform.direct),
                        tooltip: '직접 입력',
                      ),
                      IconButton(
                        icon: PlatformIconUtils.getPlatformIcon('instagram',
                            size: 28),
                        onPressed: () => setState(
                            () => selectedPlatform = LinkPlatform.instagram),
                        tooltip: 'Instagram',
                      ),
                      IconButton(
                        icon: PlatformIconUtils.getPlatformIcon('github',
                            size: 28),
                        onPressed: () => setState(
                            () => selectedPlatform = LinkPlatform.github),
                        tooltip: 'GitHub',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('링크',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: getHintText(),
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'https:// 포함한 웹사이트 주소를 입력하세요.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        String input = urlController.text.trim();
                        String url;
                        String platform;
                        switch (selectedPlatform) {
                          case LinkPlatform.instagram:
                            url = 'https://instagram.com/$input';
                            platform = 'instagram';
                            break;
                          case LinkPlatform.github:
                            url = 'https://github.com/$input';
                            platform = 'github';
                            break;
                          case LinkPlatform.direct:
                          default:
                            url = input;
                            platform = 'direct';
                        }
                        final title = titleController.text.trim();
                        final link = {
                          'title': title,
                          'url': url,
                          'platform': platform
                        };
                        editController.addLink(link);
                        Navigator.pop(context);
                      },
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NonReorderable extends StatelessWidget {
  final Widget child;
  const _NonReorderable({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}
