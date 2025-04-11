abstract class IEditCardService {
  Future<Map<String, dynamic>?> fetchBasicInfo();
  Future<bool> saveBasicInfo(Map<String, dynamic> data);
}
