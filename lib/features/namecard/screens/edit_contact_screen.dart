import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditContactScreen extends StatelessWidget {
  EditContactScreen({super.key});

  final String type = Get.arguments;
  final TextEditingController _controller = TextEditingController();

  final Map<String, String> _titleMap = {
    'mobile': '휴대전화',
    'phone': '유선전화',
    'email': '이메일',
    'website': '홈페이지',
    'address': '주소',
    'fax': '팩스',
  };

  final Map<String, String> _hintMap = {
    'mobile': '010-0000-0000',
    'phone': '02-000-0000',
    'email': 'slice@example.com',
    'website': 'https://your.site',
    'address': '서울특별시 종로구...',
    'fax': '02-000-0000',
  };

  final Map<String, TextInputType> _keyboardMap = {
    'mobile': TextInputType.phone,
    'phone': TextInputType.phone,
    'email': TextInputType.emailAddress,
    'website': TextInputType.url,
    'address': TextInputType.text,
    'fax': TextInputType.phone,
  };

  @override
  Widget build(BuildContext context) {
    final title = _titleMap[type] ?? '연락처';
    final hint = _hintMap[type] ?? '';
    final keyboard = _keyboardMap[type] ?? TextInputType.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () {
              final value = _controller.text.trim();
              if (value.isNotEmpty) {
                Get.back(result: {'type': type, 'value': value});
              }
            },
            child: const Text('저장', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: keyboard,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                helperText: _buildHelperText(type),
                hintStyle: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildHelperText(String type) {
    if (type == 'mobile' || type == 'phone' || type == 'fax') {
      return '국가번호 설정을 위해 +, -, 숫자만 입력 가능해요.';
    } else if (type == 'email') {
      return '유효한 이메일 형식을 입력해주세요.';
    } else if (type == 'website') {
      return 'https:// 포함한 웹사이트 주소를 입력하세요.';
    }
    return null;
  }
}
