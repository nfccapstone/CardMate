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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '더보기',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        const Divider(color: Colors.white24),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
          onTap: () {
            Get.defaultDialog(
              title: "로그아웃",
              middleText: "정말 로그아웃 하시겠습니까?",
              textConfirm: "예",
              textCancel: "아니오",
              confirmTextColor: Colors.white,
              onConfirm: () async {
                await controller.logout();
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.nfc, color: Colors.white),
          title: const Text('NFC에 내 명함 링크 저장', style: TextStyle(color: Colors.white)),
          onTap: () async {
            final homeController = Get.find<HomeController>();
            final cardId = homeController.cardData['cardId'] ?? '';
            final cardWebLink = 'https://cardmate-37be3.web.app/card/myNameCard/$cardId';
            RxBool isWriting = false.obs;
            RxString nfcResult = ''.obs;
            Get.defaultDialog(
              title: "NFC에 내 명함 링크 저장",
              content: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("NFC 태그에 스마트폰을 가까이 대세요.", textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (isWriting.value) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text('NFC 태그에 기록 중...'),
                  ] else if (nfcResult.value.isNotEmpty) ...[
                    Text(nfcResult.value, style: const TextStyle(color: Colors.greenAccent)),
                  ] else ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('NFC에 저장'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
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
              textCancel: "닫기",
              onCancel: () {},
            );
          },
        ),
      ],
    );
  }
} 