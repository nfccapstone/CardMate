import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlockCreateScreen extends StatefulWidget {
  const BlockCreateScreen({Key? key}) : super(key: key);

  @override
  State<BlockCreateScreen> createState() => _BlockCreateScreenState();
}

class _BlockCreateScreenState extends State<BlockCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  late String blockType; // 'text', 'link', 'photo' 등

  @override
  void initState() {
    super.initState();
    // 라우트 이동 시 arguments로 넘어온 블록 타입을 받음
    blockType = Get.arguments['type'] ?? 'text';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blockType == 'text' 
            ? '텍스트 블록' 
            : blockType == 'link'
                ? '링크 블록'
                : '사진 블록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // 완료 버튼 누르면 입력 값들을 result로 담아 돌아가기
              final blockData = {
                'type': blockType,
                'title': _titleController.text,
                'content': _contentController.text
              };
              // 저장 후 이전 화면으로 pop
              Get.back(result: blockData);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 블록 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목 입력',
                hintText: '내용 입력',
              ),
            ),
            const SizedBox(height: 16),
            // 블록 내용 / 링크 / 사진 URL 입력
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: blockType == 'link' ? '링크 URL' : '블록 내용',
                hintText: blockType == 'link'
                    ? 'https://example.com'
                    : '내용을 입력하세요.',
              ),
            ),
            // 사진 블록이라면, 추가로 이미지 업로드 버튼 / 갤러리 열기 버튼 등 배치 가능
          ],
        ),
      ),
    );
  }
}
