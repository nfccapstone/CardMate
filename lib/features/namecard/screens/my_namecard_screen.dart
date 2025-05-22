import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/my_namecard_controller.dart';
import 'package:cardmate/features/namecard/widgets/profile_section.dart';
import 'package:cardmate/features/namecard/widgets/block_section.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cardmate/features/namecard/utils/platform_icon_utils.dart';

class MyNameCardScreen extends StatelessWidget {
  const MyNameCardScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('오류', '링크를 열 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardId = Get.parameters['cardId'] ?? '';
    final controller = Get.put<MyNameCardController>(
      MyNameCardController(
        editCardService: Get.find(),
        cardId: cardId,
      ),
      permanent: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '내 공유명함',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 프로필 카드
              Container(
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
                child: ProfileSection(
                  basicInfo: controller.basicInfo,
                  readOnly: true,
                ),
              ),
              // 연락처 카드
              if ((controller.basicInfo['contacts'] ?? []).isNotEmpty)
                Container(
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
                  child: _ContactSectionReadOnly(controller: controller),
                ),
              // 링크 카드
              if ((controller.basicInfo['links'] ?? []).isNotEmpty)
                Container(
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
                  child: _LinkSectionReadOnly(controller: controller),
                ),
              // 블록 카드
              if (controller.blocks.isNotEmpty)
                Container(
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
                  child:
                      BlockSection(blocks: controller.blocks, readOnly: true),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}

// 연락처 읽기 전용 위젯
class _ContactSectionReadOnly extends StatelessWidget {
  final MyNameCardController controller;
  const _ContactSectionReadOnly({required this.controller});

  @override
  Widget build(BuildContext context) {
    final contacts = controller.basicInfo['contacts'] ?? [];
    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('연락처',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...contacts.map<Widget>((contact) {
          final type = contact['type'];
          final value = contact['value'];
          IconData icon;
          VoidCallback? onTap;
          if (type == 'mobile' || type == 'phone') {
            icon = Icons.phone;
            onTap = () => launchUrl(Uri.parse('tel:$value'));
          } else if (type == 'email') {
            icon = Icons.email;
            onTap = () => launchUrl(Uri.parse('mailto:$value'));
          } else if (type == 'url') {
            icon = Icons.link;
            onTap = () => launchUrl(Uri.parse(value));
          } else {
            icon = Icons.contact_page;
            onTap = null;
          }
          return ListTile(
            leading: Icon(icon, color: Colors.black87),
            title: Text(value, style: const TextStyle(color: Colors.black)),
            onTap: onTap,
          );
        }).toList(),
      ],
    );
  }
}

// 링크 읽기 전용 위젯
class _LinkSectionReadOnly extends StatelessWidget {
  final MyNameCardController controller;
  const _LinkSectionReadOnly({required this.controller});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('오류', '링크를 열 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = controller.basicInfo['links'] ?? [];
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '링크',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...links
            .map<Widget>((link) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      final url = link['url'] ?? '';
                      if (url.isNotEmpty) {
                        _launchUrl(url);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          PlatformIconUtils.getPlatformIcon(
                              link['platform'] ?? 'direct'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              link['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
