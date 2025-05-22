import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NameCard {
  final String id;
  final String? name;
  final String? profileUrl;
  final String? webLink;
  final String? department;
  final String? position;
  final String? company;
  final bool isManual;
  final List<Map<String, dynamic>>? contacts;
  final Map<String, dynamic>? rawData;

  NameCard({
    required this.id,
    this.name,
    this.profileUrl,
    this.webLink,
    this.department,
    this.position,
    this.company,
    this.isManual = false,
    this.contacts,
    this.rawData,
  });

  factory NameCard.fromMap(String id, Map<String, dynamic> data) {
    return NameCard(
      id: id,
      name: data['name'],
      profileUrl: data['profileImageUrl'],
      webLink: 'https://cardmate-37be3.web.app/card/myNameCard/$id',
      department: data['department'],
      position: data['position'],
      company: data['company'],
      isManual: false,
      contacts: null,
      rawData: data,
    );
  }

  factory NameCard.fromManualMap(String id, Map<String, dynamic> data) {
    return NameCard(
      id: id,
      name: data['name'],
      profileUrl: null,
      webLink: null,
      department: data['department'],
      position: data['position'],
      company: data['company'],
      isManual: true,
      contacts: data['contacts'] != null
          ? List<Map<String, dynamic>>.from(data['contacts'])
          : [],
      rawData: Map<String, dynamic>.from(data),
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

  Future<void> addCardById(String cardId) async {
    await _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('card_book')
        .doc(cardId)
        .set({});

    await fetchNameCards();
  }

  Future<void> fetchNameCards() async {
    try {
      final userId = _auth.currentUser?.uid;
      final cardBookSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .get();
      final makeBookSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('make_book')
          .get();

      final cardIds = cardBookSnapshot.docs.map((doc) => doc.id).toList();
      final fetchedCards = <NameCard>[];

      // 공유 명함(card_book)
      for (final cardId in cardIds) {
        final cardDoc = await _db.collection('cards').doc(cardId).get();
        if (cardDoc.exists) {
          fetchedCards.add(NameCard.fromMap(cardDoc.id, cardDoc.data()!));
        }
      }

      // 수동 명함(make_book)
      for (final doc in makeBookSnapshot.docs) {
        fetchedCards.add(NameCard.fromManualMap(doc.id, doc.data()));
      }

      cards.assignAll(fetchedCards);
    } catch (e, stack) {
      print('명함 불러오기 실패: $e');
      print(stack);
    }
  }

  Future<void> searchCard(String input) async {
    if (input.isEmpty) {
      fetchNameCards();
      return;
    }

    final uid = _auth.currentUser?.uid;
    final cardIdSnapshots =
        await _db.collection('users').doc(uid).collection('card_book').get();

    final searchedCards = <NameCard>[];
    final searchInput = input.toLowerCase(); // 검색어를 소문자로 변환

    await Future.wait(
      cardIdSnapshots.docs.map((doc) async {
        final cardId = doc.id;
        final cardDoc = await _db.collection('cards').doc(cardId).get();
        final data = cardDoc.data();

        if (data != null) {
          final name = (data['name'] ?? '').toString().toLowerCase();
          final company = (data['company'] ?? '').toString().toLowerCase();
          final department = (data['department'] ?? '').toString().toLowerCase();
          final position = (data['position'] ?? '').toString().toLowerCase();

          // 이름, 회사, 부서, 직책 중 하나라도 검색어를 포함하면 결과에 추가
          if (name.contains(searchInput) ||
              company.contains(searchInput) ||
              department.contains(searchInput) ||
              position.contains(searchInput)) {
            searchedCards.add(NameCard.fromMap(cardId, data));
          }
        }
      }),
    );

    cards.assignAll(searchedCards);
  }

  Future<void> deleteCard(String cardId, {bool? isManual}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (isManual == true) {
        await _db
            .collection('users')
            .doc(userId)
            .collection('make_book')
            .doc(cardId)
            .delete();
      } else if (isManual == false) {
        await _db
            .collection('users')
            .doc(userId)
            .collection('card_book')
            .doc(cardId)
            .delete();
      } else {
        // 둘 다 시도 (호환성)
        await _db
            .collection('users')
            .doc(userId)
            .collection('card_book')
            .doc(cardId)
            .delete();
        await _db
            .collection('users')
            .doc(userId)
            .collection('make_book')
            .doc(cardId)
            .delete();
      }
      await fetchNameCards();
    } catch (e) {
      print('명함 삭제 실패: $e');
      rethrow;
    }
  }
}
