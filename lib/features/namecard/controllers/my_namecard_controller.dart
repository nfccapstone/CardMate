import 'package:get/get.dart';
import 'package:cardmate/features/namecard/services/i_edit_card_service.dart';

class MyNameCardController extends GetxController {
  final isLoading = true.obs;
  final basicInfo = <String, dynamic>{}.obs;
  final blocks = <Map<String, dynamic>>[].obs;
  final IEditCardService _service;
  final String? cardId;

  MyNameCardController({required IEditCardService editCardService, this.cardId})
      : _service = editCardService;

  @override
  void onInit() {
    super.onInit();
    if (cardId != null && cardId!.isNotEmpty) {
      loadNameCardDataByCardId(cardId!);
    } else {
      loadNameCardData();
    }
  }

  Future<void> loadNameCardData() async {
    isLoading.value = true;
    final data = await _service.fetchBasicInfo();
    if (data != null) {
      // 연락처 서브컬렉션에서 불러오기
      final contactsMap = await _service.fetchContactsFromSubcollection();
      if (contactsMap != null && contactsMap.isNotEmpty) {
        data['contacts'] = contactsMap.entries
            .map((e) => {
                  'type': e.key,
                  'value': e.value,
                })
            .toList();
      } else {
        data['contacts'] = [];
      }

      // 링크 데이터 불러오기
      final linksData = await _service.fetchLinks();
      data['links'] = linksData;

      basicInfo.assignAll(data);
    }
    final blocksData = await _service.fetchBlocks();
    blocks.assignAll(blocksData);
    isLoading.value = false;
  }

  Future<void> loadNameCardDataByCardId(String cardId) async {
    isLoading.value = true;
    final data = await _service.fetchBasicInfoByCardId(cardId);
    if (data != null) {
      final contactsMap = await _service.fetchContactsByCardId(cardId);
      if (contactsMap != null && contactsMap.isNotEmpty) {
        data['contacts'] = contactsMap.entries
            .map((e) => {
                  'type': e.key,
                  'value': e.value,
                })
            .toList();
      } else {
        data['contacts'] = [];
      }

      // 링크 데이터 불러오기
      final linksData = await _service.fetchLinksByCardId(cardId);
      data['links'] = linksData;

      basicInfo.assignAll(data);
    }
    final blocksData = await _service.fetchBlocksByCardId(cardId);
    blocks.assignAll(blocksData);
    isLoading.value = false;
  }
}
