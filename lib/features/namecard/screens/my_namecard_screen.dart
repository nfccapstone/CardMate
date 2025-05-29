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
          'CardMate',
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

    // 연락처를 Map으로 변환 (타입 안전하게)
    Map<String, String> contactsMap;
    if (contacts is List<Map<String, String>>) {
      contactsMap = Map<String, String>.fromEntries(
        contacts
          .where((contact) => contact['type'] != null && contact['value'] != null)
          .map((contact) => MapEntry(
            contact['type']!.toString(),
            contact['value']!.toString(),
          )),
      );
    } else if (contacts is List<MapEntry<String, String>>) {
      contactsMap = Map<String, String>.fromEntries(contacts);
    } else if (contacts is List) {
      // 혹시 Map<String, dynamic> 형태로 들어오는 경우
      contactsMap = Map<String, String>.fromEntries(
        contacts
          .where((contact) => contact is Map && contact['type'] != null && contact['value'] != null)
          .map((contact) => MapEntry(
            contact['type'].toString(),
            contact['value'].toString(),
          )),
      );
    } else {
      contactsMap = {};
    }

    // 연락처 타입별 정렬 순서 정의
    final orderedTypes = [
      'mobile',    // 휴대전화
      'phone',     // 유선전화
      'email',     // 이메일
      'website',   // 홈페이지
      'address',   // 주소
      'fax',       // 팩스
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('연락처',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...orderedTypes
            .where((type) => contactsMap.containsKey(type))
            .map<Widget>((type) {
              final value = contactsMap[type] ?? '';
              IconData icon;
              VoidCallback? onTap;
              if (type == 'mobile' || type == 'phone') {
                icon = Icons.phone;
                onTap = () => launchUrl(Uri.parse('tel:$value'));
              } else if (type == 'email') {
                icon = Icons.email;
                onTap = () => launchUrl(Uri.parse('mailto:$value'));
              } else if (type == 'website') {
                icon = Icons.language;
                onTap = () => launchUrl(Uri.parse(value));
              } else {
                icon = Icons.contact_phone;
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
