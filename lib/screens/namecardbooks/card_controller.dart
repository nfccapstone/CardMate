import 'package:cardmate/screens/namecardbooks/card_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  var cards = <CardModel>[].obs;

  @override
  void onInit() {
    fetchCards();
    super.onInit();
  }

  void addCard(CardModel card) async {
    final docRef = await _db
        .collection('users')
        .doc(userId)
        .collection('cards')
        .add(card.toMap());

    cards.add(CardModel(
        id: docRef.id,
        name: card.name,
        company: card.company,
        position: card.position,
        department: card.department));
  }

  void fetchCards() async {
    final snapshot =
        await _db.collection('users').doc(userId).collection('cards').get();
    cards.value = snapshot.docs
        .map((doc) => CardModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  void updateCard(CardModel card) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cards')
        .doc(card.id)
        .update(card.toMap());
    fetchCards();
  }
}
