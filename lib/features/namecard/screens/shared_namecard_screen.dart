import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cardmate/features/namecard/controllers/shared_namecard_controller.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';

class SharedNameCardScreen extends StatelessWidget {
  final String nameCardId;
  
  const SharedNameCardScreen({
    super.key,
    required this.nameCardId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SharedNameCardController(
      nameCardId: nameCardId,
      nameCardService: Get.find<INameCardService>(),
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.error.value,
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
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: controller.profileImageUrl.value.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(controller.profileImageUrl.value),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.profileImageUrl.value.isEmpty
                    ? const Icon(Icons.person, size: 80, color: Colors.grey)
                    : null,
              ),

              // 기본 정보
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.name.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (controller.position.value.isNotEmpty) ...[
                      Text(
                        controller.position.value,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (controller.department.value.isNotEmpty) ...[
                      Text(
                        controller.department.value,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (controller.company.value.isNotEmpty) ...[
                      Text(
                        controller.company.value,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 연락처 정보
              if (controller.contacts.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '연락처',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...controller.contacts.entries.map((entry) {
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
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, color: Colors.deepPurple),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getContactTypeLabel(type),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...actions,
                            ],
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

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      Get.snackbar(
        '오류',
        'URL을 열 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 