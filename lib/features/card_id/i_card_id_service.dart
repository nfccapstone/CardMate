abstract class ICardIdService {
  Future<bool> validateCardId(String cardId);
  Future<bool> linkCardIdToUser(String userId, String cardId);
  Future<String> generateUniqueCardId();
  bool isValidCardIdFormat(String cardId);
}
