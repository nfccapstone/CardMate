import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';
import '../services/i_namecard_service.dart';
import '../services/namecard_service.dart';
import '../widgets/profile_section.dart';
import '../utils/platform_icon_utils.dart';
import '../widgets/block_readonly_card.dart';

class CardWebScreen extends StatelessWidget {
  final String cardId;

  const CardWebScreen({
    super.key,
    required this.cardId,
  });

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
    final nameCardService = Get.put<INameCardService>(NameCardService());
    final RxBool isLoading = true.obs;
    final RxString error = ''.obs;
    final RxMap<String, dynamic> cardData = RxMap<String, dynamic>();

    // 명함 데이터 로드
    Future<void> loadCardData() async {
      try {
        isLoading.value = true;
        final data = await nameCardService.getCardForWeb(cardId);
        if (data != null) {
          // 연락처 순서 정렬
          if (data['contacts'] != null) {
            final contacts = data['contacts'] as Map<String, dynamic>;
            final orderedTypes = [
              'mobile',
              'phone',
              'email',
              'address',
              'fax',
            ];
            
            final sortedEntries = orderedTypes
                .where((type) => contacts.containsKey(type))
                .map((type) => MapEntry(type, contacts[type]));

            data['contacts'] = LinkedHashMap.fromEntries(sortedEntries);
          }
          cardData.value = data;
        } else {
          error.value = '명함을 찾을 수 없습니다.';
        }
      } catch (e) {
        error.value = '명함을 불러오는 중 오류가 발생했습니다.';
      } finally {
        isLoading.value = false;
      }
    }

    // 초기 데이터 로드
    loadCardData();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  error.value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // 프로필 카드
              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 16),
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
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: cardData['profileImageUrl'] != null
                            ? DecorationImage(
                                image:
                                    NetworkImage(cardData['profileImageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: cardData['profileImageUrl'] == null
                          ? const Icon(Icons.person,
                              size: 80, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ProfileSection(
                      basicInfo: {
                        'name': cardData['name'],
                        'department': cardData['department'],
                        'position': cardData['position'],
                        'company': cardData['company'],
                      },
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              // 연락처 카드
              if (cardData['contacts'] != null) ...[
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '연락처',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 연락처를 고정된 순서의 리스트로 변환
                      ...(() {
                        final orderedTypes = [
                          'mobile',
                          'phone',
                          'email',
                          'address',
                          'fax',
                        ];
                        final contacts = cardData['contacts'] as Map<String, dynamic>? ?? {};
                        final contactList = orderedTypes
                            .where((type) => contacts.containsKey(type))
                            .map((type) => MapEntry(type, contacts[type]))
                            .toList();
                        return contactList.map((entry) {
                          final type = entry.key;
                          final value = entry.value;
                          IconData icon;
                          List<Widget> actions = [];

                          if (type == 'mobile' || type == 'phone') {
                            icon = Icons.phone;
                            actions = [
                              IconButton(
                                icon: const Icon(Icons.call,
                                    color: Colors.black87),
                                onPressed: () => _launchUrl('tel:$value'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.message,
                                    color: Colors.black87),
                                onPressed: () => _launchUrl('sms:$value'),
                              ),
                            ];
                          } else if (type == 'email') {
                            icon = Icons.email;
                            actions = [
                              IconButton(
                                icon: const Icon(Icons.email,
                                    color: Colors.black87),
                                onPressed: () => _launchUrl('mailto:$value'),
                              ),
                            ];
                          } else {
                            icon = Icons.contact_phone;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(icon, color: Colors.black87, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getContactTypeLabel(type),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...actions,
                              ],
                            ),
                          );
                        }).toList();
                      })(),
                    ],
                  ),
                ),
              ],
              // 링크 카드
              if (cardData['links'] != null &&
                  (cardData['links'] as List).isNotEmpty) ...[
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '링크',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...(cardData['links'] as List).map((link) {
                        final title = link['title'] ?? '';
                        final url = link['url'] ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: InkWell(
                            onTap: () => _launchUrl(url),
                            child: Row(
                              children: [
                                _getPlatformIcon(link['platform'] ?? 'direct'),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.open_in_new,
                                    color: Colors.black87),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              // 블록 카드 (BlockReadOnlyCard 재사용)
              if (cardData['blocks'] != null &&
                  (cardData['blocks'] as List).isNotEmpty) ...[
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: (cardData['blocks'] as List)
                        .map((block) => BlockReadOnlyCard(block: block))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  String _getContactTypeLabel(String type) {
    switch (type) {
      case 'mobile':
        return '휴대전화';
      case 'phone':
        return '유선전화';
      case 'email':
        return '이메일';
      case 'address':
        return '주소';
      case 'fax':
        return '팩스';
      default:
        return type;
    }
  }

  Widget _getPlatformIcon(String platform) {
    return PlatformIconUtils.getPlatformIcon(platform, size: 32);
  }
}
