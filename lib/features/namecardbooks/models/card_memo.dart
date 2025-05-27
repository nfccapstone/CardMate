import 'package:cloud_firestore/cloud_firestore.dart';

class CardMemo {
  final String cardId;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardMemo({
    required this.cardId,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'memo': memo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CardMemo.fromMap(Map<String, dynamic> map) {
    return CardMemo(
      cardId: map['cardId'] as String,
      memo: map['memo'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}