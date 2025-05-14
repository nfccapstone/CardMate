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
}
