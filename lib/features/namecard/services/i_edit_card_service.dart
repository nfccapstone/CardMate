import 'dart:typed_data';

abstract class IEditCardService {
  Future<Map<String, dynamic>?> fetchBasicInfo();
  Future<bool> saveBasicInfo(Map<String, dynamic> data);
  Future<void> addBlock(Map<String, dynamic> blockData);
  Future<List<Map<String, dynamic>>> fetchBlocks();
  Future<String?> uploadImage(Uint8List imageBytes, String fileName);
  Future<void> deleteBlock(String blockId);
  Future<Map<String, String>?> fetchContactsFromSubcollection();
  Future<Map<String, String>?> fetchContactsByCardId(String cardId);
  Future<List<Map<String, dynamic>>> fetchBlocksByCardId(String cardId);
  Future<Map<String, dynamic>?> fetchBasicInfoByCardId(String cardId);
  Future<void> updateBlockOrder(List<Map<String, dynamic>> blocks);

  // 링크 관련 메서드 추가
  Future<void> addLink(Map<String, String> linkData);
  Future<List<Map<String, String>>> fetchLinks();
  Future<List<Map<String, String>>> fetchLinksByCardId(String cardId);
  Future<void> deleteLink(String linkId);

  // 블록 수정 메서드 추가
  Future<void> updateBlock(String blockId, Map<String, dynamic> blockData);

  fetchManualCard(String cardId) {}
}
