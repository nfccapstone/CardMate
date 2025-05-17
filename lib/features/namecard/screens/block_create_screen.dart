import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cardmate/features/namecard/controllers/edit_card_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

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
  final List<String> _imageNames = [];
  final _editController = Get.find<EditCardController>();
  final _pageController = PageController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _showToolbar = false;

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
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result != null) {
        setState(() {
          _imageFiles.clear();
          _imageBytes.clear();
          _imageNames.clear();
          for (var file in result.files) {
            if (file.bytes != null) {
              _imageBytes.add(file.bytes!);
              _imageNames.add(file.name);
            }
          }
        });
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _imageFiles.clear();
          _imageBytes.clear();
          _imageNames.clear();
          for (var image in images) {
            final file = File(image.path);
            _imageFiles.add(file);
            _imageBytes.add(file.readAsBytesSync());
            _imageNames.add(image.name);
          }
        });
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (int i = 0; i < _imageBytes.length; i++) {
      final fileName = _imageNames.isNotEmpty
          ? _imageNames[i]
          : '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final imageUrl = await _editController.uploadImage(
        _imageBytes[i],
        fileName,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(blockType == 'text' 
            ? '텍스트 블록' 
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
                
                await _editController.addBlock(blockData);
                Get.offAllNamed('/home');
                Get.toNamed('/editCard', arguments: {'cardId': _editController.basicInfo['cardId']});
              } else {
                final blockData = {
                  'type': blockType,
                  'title': _titleController.text,
                  'content': jsonEncode(_quillController.document.toDelta().toJson()),
                };
                await _editController.addBlock(blockData);
                Get.offAllNamed('/home');
                Get.toNamed('/editCard', arguments: {'cardId': _editController.basicInfo['cardId']});
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              if (blockType != 'photo') ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: quill.QuillEditor(
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    configurations: quill.QuillEditorConfigurations(
                      controller: _quillController,
                      sharedConfigurations: const quill.QuillSharedConfigurations(),
                      enableInteractiveSelection: true,
                      customStyles: quill.DefaultStyles(
                        paragraph: quill.DefaultTextBlockStyle(
                          const TextStyle(color: Colors.black, fontSize: 14),
                          const quill.VerticalSpacing(0, 0),
                          const quill.VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                    ),
                  ),
                ),
                // 토글 버튼과 툴바를 아래에 배치
                Row(
                  children: [
                    const Text('서식 도구'),
                    const Spacer(),
                    IconButton(
                      icon: Icon(_showToolbar ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                      onPressed: () {
                        setState(() {
                          _showToolbar = !_showToolbar;
                        });
                      },
                    ),
                  ],
                ),
                if (_showToolbar)
                  quill.QuillToolbar.simple(
                    configurations: quill.QuillSimpleToolbarConfigurations(
                      controller: _quillController,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              if (blockType == 'photo') ...[
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('사진 선택'),
                ),
                const SizedBox(height: 16),
                if (_imageBytes.isNotEmpty) ...[
                  Expanded(
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _imageBytes.length,
                          itemBuilder: (context, index) {
                            if (kIsWeb) {
                              return Image.memory(
                                _imageBytes[index],
                                fit: BoxFit.contain,
                              );
                            } else {
                              return Image.file(
                                _imageFiles[index],
                                fit: BoxFit.contain,
                              );
                            }
                          },
                        ),
                        if (_imageBytes.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _imageBytes.length,
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
                    '${_imageBytes.length}장의 사진이 선택되었습니다.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
