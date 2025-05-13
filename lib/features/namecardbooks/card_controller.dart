import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NameCard {
  final String id;
  final String? name;
  final String? profileUrl;

  NameCard({required this.id, this.name, this.profileUrl});

  factory NameCard.fromMap(String id, Map<String, dynamic> data) {
    return NameCard(
      id: id,
      name: data['name'],
      profileUrl: data['profileUrl'],
    );
  }
}

class CardController extends GetxController {
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final cards = <NameCard>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNameCards();
  }

  void addCardById(String cardId) async {
    await _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('card_book')
        .doc(cardId)
        .set({});

    fetchNameCards();
  }

  Future<void> fetchNameCards() async {
    try {
      final userId = _auth.currentUser?.uid;
      final cardBookSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .get();

      final cardIds = cardBookSnapshot.docs.map((doc) => doc.id).toList();

      final fetchedCards = <NameCard>[];

      for (final cardId in cardIds) {
        final cardDoc = await FirebaseFirestore.instance
            .collection('cards')
            .doc(cardId)
            .get();

        if (cardDoc.exists) {
          fetchedCards.add(NameCard.fromMap(cardDoc.id, cardDoc.data()!));
        }
      }

      cards.assignAll(fetchedCards);
    } catch (e, stack) {
      print('명함 불러오기 실패: $e');
      print(stack);
    }
  }

  Future<void> searchCard(String input) async {
    final uid = _auth.currentUser?.uid;
    final cardIdSnapshots =
        await _db.collection('users').doc(uid).collection('card_book').get();

    final searchedCards = <NameCard>[];

    await Future.wait(
      cardIdSnapshots.docs.map((doc) async {
        final cardId = doc.id;
        final cardDoc = await _db.collection('cards').doc(cardId).get();
        final data = cardDoc.data();

        if (data != null) {
          if (data['name'] == input || data['company'] == input) {
            searchedCards.add(NameCard.fromMap(cardId, data));
            print(searchedCards);
          }
        }
      }),
    );

    cards.assignAll(searchedCards);
  }
}
