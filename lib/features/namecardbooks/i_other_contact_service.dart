abstract class IOtherContactService {
  Future<void> saveContact(String cardId, String type, String value);
  Future<Map<String, String>?> fetchContacts(String cardId);
}
