abstract class IContactService {
  Future<void> saveContact(String type, String value);
  Future<Map<String, String>?> fetchContacts();
}
