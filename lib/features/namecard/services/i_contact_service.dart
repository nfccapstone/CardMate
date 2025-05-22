abstract class IContactService {
  Future<void> saveContact(String type, String value);
  Future<Map<String, String>?> fetchContacts([String? cardId]);
  Future<void> deleteContact(String type);

  Future<void> saveManualCardContact(String type, String value, String? cardId);

  Future<Map<String, String>?> fetchManualCardContacts(String? cardId);

  Future<void> deleteManualCardContact(String type, String? cardId);
}
