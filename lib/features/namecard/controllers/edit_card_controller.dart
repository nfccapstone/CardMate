import 'package:get/get.dart';
import 'package:cardmate/features/namecard/services/i_edit_card_service.dart';
import 'dart:typed_data';

class EditCardController extends GetxController {
  final isLoading = true.obs;
  final basicInfo = <String, dynamic>{}.obs;
  final blocks = <Map<String, dynamic>>[].obs;
  final otherBasicInfo = <String, dynamic>{}.obs;
  final otherBlocks = <Map<String, dynamic>>[].obs;
  final links = <Map<String, String>>[].obs;
  final IEditCardService _service;
  String? _loadedCardId;

  bool isLoadedFor(String cardId) => _loadedCardId == cardId;

  // DI: IEditCardService 구현체를 생성자 주입
  EditCardController({required IEditCardService editCardService})
      : _service = editCardService;

  @override
  void onInit() {
    super.onInit();
    loadNameCardData();
  }

  Future<void> loadNameCardData() async {
    isLoading.value = true;
    try {
      final data = await _service.fetchBasicInfo();
      if (data != null) {
        basicInfo.assignAll(data);
      }

      // 블록 데이터 불러오기
      final blocksData = await _service.fetchBlocks();
      blocks.assignAll(blocksData);

      // 링크 데이터 불러오기
      final linksData = await _service.fetchLinks();
      links.assignAll(linksData);
    } catch (e) {
      print('데이터 로딩 오류: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBasicInfo(Map<String, dynamic> newData) async {
    isLoading.value = true;
    final success = await _service.saveBasicInfo(newData);
    if (success) {
      basicInfo.assignAll(newData);
    }
    isLoading.value = false;
  }

  Future<void> addBlock(Map<String, dynamic> blockData) async {
    try {
      await _service.addBlock(blockData);
      // Firebase에서 최신 블록 목록을 다시 가져옴
      final blocksData = await _service.fetchBlocks();
      blocks.assignAll(blocksData);
    } catch (e) {
      Get.snackbar('오류', '블록 추가에 실패했습니다.');
    }
  }

  Future<void> deleteBlock(String blockId) async {
    try {
      // 로컬 상태에서 먼저 제거하여 즉시 UI 업데이트
      blocks.removeWhere((block) => block['id'] == blockId);
      
      // Firebase에서 블록 삭제
      await _service.deleteBlock(blockId);
    } catch (e) {
      // 실패 시 다시 블록 목록을 가져와서 상태 복구
      final blocksData = await _service.fetchBlocks();
      blocks.assignAll(blocksData);
      Get.snackbar('오류', '블록 삭제에 실패했습니다.');
    }
  }

  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    return await _service.uploadImage(imageBytes, fileName);
  }

  Future<void> loadNameCardDataByCardId(String cardId) async {
    // 이미 같은 카드 ID의 데이터가 로드되어 있다면 다시 로드하지 않음
    if (_loadedCardId == cardId) return;

    isLoading.value = true;
    _loadedCardId = cardId; // 먼저 _loadedCardId 설정

    try {
      final data = await _service.fetchBasicInfoByCardId(cardId);
      if (data != null) {
        otherBasicInfo.assignAll(data);
      } else {
        Get.snackbar('오류', '명함 정보를 불러오지 못했습니다.');
      }

      final blocksData = await _service.fetchBlocksByCardId(cardId);
      otherBlocks.assignAll(blocksData);
    } catch (e) {
      Get.snackbar('오류', '명함 정보를 불러오는 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reorderBlocks(int oldIndex, int newIndex) async {
    try {
      // 로컬 상태 먼저 업데이트
      final block = blocks.removeAt(oldIndex);
      blocks.insert(newIndex, block);
      
      // Firebase에 순서 업데이트
      await _service.updateBlockOrder(blocks);
    } catch (e) {
      // 실패 시 원래 순서로 복구
      final blocksData = await _service.fetchBlocks();
      blocks.assignAll(blocksData);
      Get.snackbar('오류', '블록 순서 변경에 실패했습니다.');
    }
  }

  Future<void> addLink(Map<String, String> linkData) async {
    try {
      await _service.addLink(linkData);
      // Firebase에서 최신 링크 목록을 다시 가져옴
      final linksData = await _service.fetchLinks();
      links.assignAll(linksData);
    } catch (e) {
      Get.snackbar('오류', '링크 추가에 실패했습니다.');
    }
  }

  Future<void> deleteLink(String linkId) async {
    try {
      // 로컬 상태에서 먼저 제거하여 즉시 UI 업데이트
      links.removeWhere((link) => link['id'] == linkId);
      
      // Firebase에서 링크 삭제
      await _service.deleteLink(linkId);
    } catch (e) {
      // 실패 시 다시 링크 목록을 가져와서 상태 복구
      final linksData = await _service.fetchLinks();
      links.assignAll(linksData);
      Get.snackbar('오류', '링크 삭제에 실패했습니다.');
    }
  }

  Future<void> updateBlock(String blockId, Map<String, dynamic> blockData) async {
    try {
      await _service.updateBlock(blockId, blockData);
      // Firebase에서 최신 블록 목록을 다시 가져옴
      final blocksData = await _service.fetchBlocks();
      blocks.assignAll(blocksData);
    } catch (e) {
      Get.snackbar('오류', '블록 수정에 실패했습니다.');
    }
  }
}
