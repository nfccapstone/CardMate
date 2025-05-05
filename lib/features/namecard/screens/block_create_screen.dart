import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';

class BlockCreateScreen extends StatefulWidget {
  const BlockCreateScreen({Key? key}) : super(key: key);

  @override
  State<BlockCreateScreen> createState() => _BlockCreateScreenState();
}

class _BlockCreateScreenState extends State<BlockCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late String blockType;
  final List<File> _imageFiles = [];
  final List<Uint8List> _imageBytes = [];
  final _editController = Get.find<EditCardController>();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    blockType = Get.arguments['type'] ?? 'text';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          final file = File(image.path);
          _imageFiles.add(file);
          _imageBytes.add(file.readAsBytesSync());
        }
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (int i = 0; i < _imageBytes.length; i++) {
      final imageUrl = await _editController.uploadImage(
        _imageBytes[i],
        '${DateTime.now().millisecondsSinceEpoch}_$i.jpg'
      );
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    return imageUrls;
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
            onPressed: () async {
              if (blockType == 'photo' && _imageFiles.isEmpty) {
                Get.snackbar('오류', '사진을 선택해주세요.');
                return;
              }

              if (blockType == 'photo') {
                // 로딩 다이얼로그 표시
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  barrierDismissible: false,
                );

                final imageUrls = await _uploadImages();
                
                // 로딩 다이얼로그 닫기
                Get.back();

                if (imageUrls.isEmpty) {
                  Get.snackbar('오류', '이미지 업로드에 실패했습니다.');
                  return;
                }

                final blockData = {
                  'type': blockType,
                  'title': _titleController.text,
                  'content': imageUrls,
                };
                
                Get.back(result: blockData);
              } else {
                final blockData = {
                  'type': blockType,
                  'title': _titleController.text,
                  'content': _contentController.text
                };
                Get.back(result: blockData);
              }
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
            if (blockType != 'photo')
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: blockType == 'link' ? '링크 URL' : '블록 내용',
                  hintText: blockType == 'link'
                      ? 'https://example.com'
                      : '내용을 입력하세요.',
                ),
              ),
            if (blockType == 'photo') ...[
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('사진 선택'),
              ),
              const SizedBox(height: 16),
              if (_imageFiles.isNotEmpty) ...[
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _imageFiles.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            _imageFiles[index],
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                      if (_imageFiles.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _imageFiles.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _pageController.hasClients &&
                                          _pageController.page?.round() == index
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_imageFiles.length}장의 사진이 선택되었습니다.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
