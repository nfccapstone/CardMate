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
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _showToolbar = false;
  bool _isEdit = false;
  String? _blockId;
  List<String> _imageUrls = [];
  String _selectedType = 'text';
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    
    final args = Get.arguments ?? {};
    blockType = args['type'] ?? 'text';
    _isEdit = args['isEdit'] ?? false;
    
    if (_isEdit) {
      final blockData = args['blockData'];
      _blockId = blockData['id'];
      _titleController.text = blockData['title'] ?? '';
      
      if (blockType == 'text' && blockData['content'] != null) {
        try {
          final quillDoc = quill.Document.fromJson(jsonDecode(blockData['content']));
          _quillController = quill.QuillController(
            document: quillDoc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        } catch (e) {
          print('텍스트 블록 데이터 파싱 오류: $e');
        }
      } else if (blockType == 'photo' && blockData['content'] is List) {
        // 사진 블록의 경우 기존 이미지 URL들을 표시
        setState(() {
          _imageUrls = List<String>.from(blockData['content']);
        });
      }
    }
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
          _selectedImages.clear();
          for (var file in result.files) {
            if (file.bytes != null) {
              _imageBytes.add(file.bytes!);
              _imageNames.add(file.name);
              // 웹에서는 File 객체를 만들 수 없으므로 생략
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
          _selectedImages.clear();
          for (var image in images) {
            final file = File(image.path);
            _imageFiles.add(file);
            _imageBytes.add(file.readAsBytesSync());
            _imageNames.add(image.name);
            _selectedImages.add(file);
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

  Future<void> _saveBlock() async {
    if (_selectedType == 'photo' && _imageBytes.isEmpty && _imageUrls.isEmpty) {
      Get.snackbar('오류', '사진을 선택해주세요.');
      return;
    }

    if (_selectedType == 'photo') {
      // 로딩 다이얼로그 표시
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      List<String> finalImageUrls = [];
      
      // 새로 추가된 이미지 업로드
      if (_imageBytes.isNotEmpty) {
        final newImageUrls = await _uploadImages();
        finalImageUrls.addAll(newImageUrls);
      }
      
      // 기존 이미지 URL 유지
      finalImageUrls.addAll(_imageUrls);

      // 로딩 다이얼로그 닫기
      Get.back();

      if (finalImageUrls.isEmpty) {
        Get.snackbar('오류', '이미지 업로드에 실패했습니다.');
        return;
      }

      final blockData = {
        'type': _selectedType,
        'title': _titleController.text,
        'content': finalImageUrls,
      };

      if (_isEdit && _blockId != null) {
        await _editController.updateBlock(_blockId!, blockData);
      } else {
        await _editController.addBlock(blockData);
      }
    } else {
      final blockData = {
        'type': _selectedType,
        'title': _titleController.text,
        'content': jsonEncode(_quillController.document.toDelta().toJson()),
      };

      if (_isEdit && _blockId != null) {
        await _editController.updateBlock(_blockId!, blockData);
      } else {
        await _editController.addBlock(blockData);
      }
    }

    Get.offAllNamed('/home');
    Get.toNamed('/editCard', arguments: {'cardId': _editController.basicInfo['cardId']});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '블록 추가',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 블록 유형 선택 카드
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '블록 유형',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBlockTypeButton(
                          'text',
                          '텍스트',
                          Icons.text_fields,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBlockTypeButton(
                          'photo',
                          '사진',
                          Icons.photo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_selectedType == 'text')
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _buildTextBlockForm(),
              )
            else if (_selectedType == 'photo')
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _buildPhotoBlockForm(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBlockForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '텍스트 내용',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: '제목 입력',
              hintText: '내용 입력',
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
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
                    TextStyle(color: Colors.black, fontSize: 14),
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveBlock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBlockForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사진 추가',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: '제목 입력',
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '선택된 사진',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate, size: 20),
                        label: const Text('추가'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedImages.removeAt(index);
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '사진을 추가해주세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('사진 선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedImages.isEmpty ? null : _saveBlock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
              ),
              child: const Text(
                '저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
