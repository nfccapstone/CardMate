class CardUpdateAlert {
  final String cardId;
  final String cardOwnerName;
  final String cardOwnerProfileUrl;
  final DateTime updatedAt;

  CardUpdateAlert({
    required this.cardId,
    required this.cardOwnerName,
    required this.cardOwnerProfileUrl,
    required this.updatedAt,
  });
} 