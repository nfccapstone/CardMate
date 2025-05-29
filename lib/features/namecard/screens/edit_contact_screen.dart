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
    'address': '주소',
    'fax': '팩스',
  };

  final Map<String, String> _hintMap = {
    'mobile': '010-0000-0000',
    'phone': '02-000-0000',
    'email': 'nameCard@example.com',
    'address': '서울특별시 종로구...',
    'fax': '02-000-0000',
  };

  final Map<String, TextInputType> _keyboardMap = {
    'mobile': TextInputType.phone,
    'phone': TextInputType.phone,
    'email': TextInputType.emailAddress,
    'address': TextInputType.text,
    'fax': TextInputType.phone,
  };

  @override
  Widget build(BuildContext context) {
    final title = _titleMap[type] ?? '연락처';
    final hint = _hintMap[type] ?? '';
    final keyboard = _keyboardMap[type] ?? TextInputType.text;

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    hintStyle: const TextStyle(color: Colors.grey),
                    helperText: _buildHelperText(type),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final value = _controller.text.trim();
                      if (value.isNotEmpty) {
                        Get.back(result: {'type': type, 'value': value});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _buildHelperText(String type) {
    if (type == 'mobile' || type == 'phone' || type == 'fax') {
      return '국가번호 설정을 위해 +, -, 숫자만 입력 가능해요.';
    } else if (type == 'email') {
      return '유효한 이메일 형식을 입력해주세요.';
    }
    return null;
  }
}
