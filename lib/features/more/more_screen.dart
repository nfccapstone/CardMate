import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'more_controller.dart';
import 'package:cardmate/features/home/home_controller.dart';
import 'package:nfc_manager/nfc_manager.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MoreController controller = Get.find<MoreController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '더보기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildMenuCard(
            icon: Icons.logout,
            title: '로그아웃',
            onTap: () {
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '로그아웃',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '정말 로그아웃 하시겠습니까?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('취소'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await controller.logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('로그아웃'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.nfc,
            title: 'NFC에 내 명함 링크 저장',
            onTap: () async {
              final homeController = Get.find<HomeController>();
              final cardId = homeController.cardData['cardId'] ?? '';
              final cardWebLink = 'https://cardmate-37be3.web.app/card/myNameCard/$cardId';
              RxBool isWriting = false.obs;
              RxString nfcResult = ''.obs;

              Get.dialog(
                Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.nfc,
                            size: 48,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'NFC에 내 명함 링크 저장',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "NFC 태그에 스마트폰을 가까이 대세요.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (isWriting.value) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'NFC 태그에 기록 중...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (nfcResult.value.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: nfcResult.value.contains('성공') 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      nfcResult.value.contains('성공')
                                          ? Icons.check_circle
                                          : Icons.error,
                                      size: 32,
                                      color: nfcResult.value.contains('성공')
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      nfcResult.value,
                                      style: TextStyle(
                                        color: nfcResult.value.contains('성공')
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('NFC에 저장'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  isWriting.value = true;
                                  nfcResult.value = '';
                                  try {
                                    bool isAvailable = await NfcManager.instance.isAvailable();
                                    if (!isAvailable) {
                                      nfcResult.value = 'NFC 사용 불가';
                                      isWriting.value = false;
                                      return;
                                    }
                                    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
                                      try {
                                        final ndef = Ndef.from(tag);
                                        if (ndef == null || !ndef.isWritable) {
                                          nfcResult.value = 'NDEF 지원 불가 또는 쓰기 불가 태그';
                                          await NfcManager.instance.stopSession(errorMessage: nfcResult.value);
                                          isWriting.value = false;
                                          return;
                                        }
                                        final ndefMessage = NdefMessage([
                                          NdefRecord.createUri(Uri.parse(cardWebLink)),
                                        ]);
                                        await ndef.write(ndefMessage);
                                        nfcResult.value = 'NFC 태그에 링크 저장 성공!';
                                        await NfcManager.instance.stopSession();
                                      } catch (e) {
                                        nfcResult.value = '저장 실패: \n' + e.toString();
                                        await NfcManager.instance.stopSession(errorMessage: nfcResult.value);
                                      } finally {
                                        isWriting.value = false;
                                      }
                                    });
                                  } catch (e) {
                                    nfcResult.value = 'NFC 저장 중 오류 발생';
                                    isWriting.value = false;
                                  }
                                },
                              ),
                            ],
                          ],
                        )),
                        const SizedBox(height: 24),
                        if (!isWriting.value)
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              '닫기',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 