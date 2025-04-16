// 파일 위치: lib/features/namecard/widgets/sns_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SNSBottomSheetUI extends StatelessWidget {
  const SNSBottomSheetUI({Key? key}) : super(key: key);

  // 예시용 SNS 목록 (실제 프로젝트에서는 별도 컨트롤러/서비스로 관리)
  static final RxList<Map<String, String>> snsList = <Map<String, String>>[].obs;

  @override
  Widget build(BuildContext context) {
    // 초기 더미 데이터 추가 (최초 1회)
    if (snsList.isEmpty) {
      snsList.addAll([
        {'type': 'Instagram', 'url': 'https://instagram.com/your_instagram'},
        {'type': 'YouTube', 'url': 'https://youtube.com/your_channel'},
      ]);
    }
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '내 SNS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: snsList.length,
                itemBuilder: (context, index) {
                  final item = snsList[index];
                  return ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(item['type'] ?? ''),
                    onTap: () async {
                      final url = item['url'] ?? '';
                      final uri = Uri.parse(url);
                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                        Get.snackbar('오류', '해당 URL을 열 수 없습니다.');
                      }
                    },
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAddSNSDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('SNS 추가'),
          ),
        ],
      ),
    );
  }

  void _showAddSNSDialog(BuildContext context) {
  // URL 입력 컨트롤러만 필요하며, SNS 유형은 드롭다운 위젯으로 선택합니다.
  final TextEditingController urlController = TextEditingController();
  // 기본 선택 값과 선택 옵션 리스트
  String selectedSns = 'Instagram';
  final List<String> snsOptions = [
    'KakaoTalk',
    'Instagram',
    'Facebook',
    'X',
    'TikTok'
  ];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('SNS 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드롭다운으로 SNS 유형 선택
              DropdownButton<String>(
                value: selectedSns,
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedSns = newValue;
                    });
                  }
                },
                items: snsOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // URL 입력 필드
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'SNS URL',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final newType = selectedSns; // 드롭다운으로 선택된 SNS 유형
                var newInput = urlController.text.trim();
                if (newInput.isNotEmpty) {
                  // Instagram인 경우, 입력값이 URL 형식이 아니라면 전체 링크로 자동 구성
                  if (newType == 'Instagram' && !newInput.startsWith("http")) {
                    newInput = "https://instagram.com/$newInput/";
                    }
                    SNSBottomSheetUI.snsList.add({'type': newType, 'url': newInput});
                    }
                    Navigator.pop(ctx);
                  },
              child: const Text('추가'),
            ),
          ],
        );
      },
    ),
  );
}
}