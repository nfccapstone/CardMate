import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';
import '../services/i_namecard_service.dart';
import '../services/namecard_service.dart';
import '../widgets/profile_section.dart';
import '../utils/platform_icon_utils.dart';

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
            final sortedEntries = contacts.entries.toList()
              ..sort((a, b) {
                final typeOrder = {
                  'mobile': 0,
                  'phone': 1,
                  'email': 2,
                  'website': 3,
                };
                final aOrder = typeOrder[a.key] ?? 999;
                final bOrder = typeOrder[b.key] ?? 999;
                return aOrder.compareTo(bOrder);
              });
            
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
              // 프로필 이미지
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: cardData['profileImageUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(cardData['profileImageUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: cardData['profileImageUrl'] == null
                    ? const Icon(Icons.person, size: 120, color: Colors.grey)
                    : null,
              ),

              // 기본 정보
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

              // 연락처 정보
              if (cardData['contacts'] != null) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(32),
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
                      ...(cardData['contacts'] as Map<String, dynamic>)
                          .entries
                          .toList()
                          .map((entry) {
                            final type = entry.key;
                            final value = entry.value;
                            IconData icon;
                            List<Widget> actions = [];

                            if (type == 'mobile' || type == 'phone') {
                              icon = Icons.phone;
                              actions = [
                                IconButton(
                                  icon: const Icon(Icons.call, color: Colors.black87),
                                  onPressed: () => _launchUrl('tel:$value'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message, color: Colors.black87),
                                  onPressed: () => _launchUrl('sms:$value'),
                                ),
                              ];
                            } else if (type == 'email') {
                              icon = Icons.email;
                              actions = [
                                IconButton(
                                  icon: const Icon(Icons.email, color: Colors.black87),
                                  onPressed: () => _launchUrl('mailto:$value'),
                                ),
                              ];
                            } else if (type == 'website') {
                              icon = Icons.language;
                              actions = [
                                IconButton(
                                  icon: const Icon(Icons.open_in_browser, color: Colors.black87),
                                  onPressed: () => _launchUrl(value),
                                ),
                              ];
                            } else {
                              icon = Icons.contact_phone;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, color: Colors.deepPurple, size: 32),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          })
                          .toList()
                          .reversed
                          .toList(),
                    ],
                  ),
                ),
              ],

              // 링크 정보
              if (cardData['links'] != null && (cardData['links'] as List).isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(32),
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
                          child: InkWell(
                            onTap: () => _launchUrl(url),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
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
                                  const Icon(Icons.open_in_new, color: Colors.deepPurple),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
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
      case 'website':
        return '홈페이지';
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