import 'package:cardmate/features/namecardbooks/card_model.dart';
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

  // void addCardById(String id) async {
  //   try {
  //     final doc = await _db
  //         .collection('shared_namecards')
  //         .doc(id)
  //         .collection('namecard')
  //         .doc('basic_info')
  //         .get();

  //     if (doc.exists) {
  //       final data = doc.data()!;
  //       CardModel newCard = CardModel(
  //         id: id,
  //         name: data['name'],
  //         company: data['company'],
  //         position: data['position'],
  //         department: data['department'],
  //       );
  //       addCard(newCard);
  //     } else {
  //       print("해당 ID의 명함이 존재하지 않습니다.");
  //     }
  //   } catch (e) {
  //     print("데이터에 접근할 수 없음: $e");
  //   }
  // }

  void addCardById(String id) async {
    try {
      // basic_info 문서 불러오기
      final basicInfoDoc = await _db
          .collection('shared_namecards')
          .doc(id)
          .collection('namecard')
          .doc('basic_info')
          .get();

      // contacts 문서 불러오기
      final contactsDoc = await _db
          .collection('shared_namecards')
          .doc(id)
          .collection('namecard')
          .doc('contacts')
          .get();

      if (basicInfoDoc.exists) {
        final basic = basicInfoDoc.data()!;
        final contacts = contactsDoc.exists ? contactsDoc.data()! : {};

        // CardModel에 모든 정보 저장
        CardModel newCard = CardModel(
          id: id,
          name: basic['name'],
          company: basic['company'],
          position: basic['position'],
          department: basic['department'],
          contacts: Map<String, String>.from(
              contacts), // Map<String, dynamic> 형태로 저장한다고 가정
        );

        addCard(newCard);
      } else {
        print("해당 ID의 명함 기본 정보가 존재하지 않음.");
      }
    } catch (e) {
      print("데이터에 접근할 수 없음: $e");
    }
  }

  Future<Map<String, dynamic>?> getUserNamecardData(
      DocumentSnapshot userId) async {
    final snapshot = await userId.reference
        .collection('my_namecard')
        .doc('basic_info')
        .get();
    return snapshot.data();
  }

  // void addCard(CardModel card) async {
  //   final docRef = await _db
  //       .collection('users')
  //       .doc(userId)
  //       .collection('cards')
  //       .add(card.toMap());

  //   cards.add(CardModel(
  //     id: docRef.id,
  //     name: card.name,
  //     company: card.company,
  //     position: card.position,
  //     department: card.department,
  //   ));
  // }

  void addCard(CardModel card) async {
    final docRef = await _db
        .collection('users')
        .doc(userId)
        .collection('cards')
        .doc(); // 직접 ID 생성

    // 1. basic_info 저장
    await docRef.collection('basic_info').doc('data').set({
      'name': card.name,
      'company': card.company,
      'position': card.position,
      'department': card.department,
    });

    // 2. contacts 저장 (있다면)
    if (card.contacts != null) {
      await docRef.collection('contacts').doc('data').set(card.contacts!);
    }

    // 3. cards 리스트에 추가
    cards.add(CardModel(
      id: docRef.id,
      name: card.name,
      company: card.company,
      position: card.position,
      department: card.department,
      contacts: card.contacts,
    ));
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
