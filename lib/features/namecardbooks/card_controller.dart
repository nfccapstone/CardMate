import 'package:cardmate/features/namecardbooks/card_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  var cards = <CardModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchCards();
    super.onInit();
  }

  void addCardById(String id) async {
    try {
      // basic_info 문서 불러오기
      final basicInfoDoc = await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .doc(id)
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
    final snapshot = await userId.reference.get();
    final data = snapshot.data();
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
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

  Future<void> fetchCards() async {
    isLoading.value = true;
    try {
      // 1. card_book 컬렉션에서 저장된 cardId 목록 가져오기
      final cardBookSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .get();

      // 2. 각 cardId에 대해 cards 컬렉션에서 정보 가져오기
      for (var doc in cardBookSnapshot.docs) {
        final cardId = doc.id;

        // basic_info 가져오기
        final basicInfoDoc = await _db
            .collection('cards')
            .doc(cardId)
            .collection('basic_info')
            .doc('data')
            .get();

        // contacts 가져오기
        final contactsDoc = await _db
            .collection('cards')
            .doc(cardId)
            .collection('contacts')
            .doc('data')
            .get();

        if (basicInfoDoc.exists) {
          final basicInfo = basicInfoDoc.data()!;
          final contacts = contactsDoc.exists ? contactsDoc.data()! : {};

          // CardModel 생성 및 추가
          final card = CardModel(
            id: cardId,
            name: basicInfo['name'] ?? '',
            company: basicInfo['company'] ?? '',
            position: basicInfo['position'] ?? '',
            department: basicInfo['department'] ?? '',
            contacts: Map<String, String>.from(contacts),
          );

          // 중복 체크 후 추가
          if (!cards.any((c) => c.id == cardId)) {
            cards.add(card);
          }
        }
      }
    } catch (e) {
      print("명함첩 불러오기 실패: $e");
      Get.snackbar('오류', '명함첩을 불러오는데 실패했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCardToBook(String cardId) async {
    try {
      // 1. cards 컬렉션에서 해당 명함의 존재 여부 확인
      final basicInfoDoc = await _db
          .collection('cards')
          .doc(cardId)
          .collection('basic_info')
          .doc('data')
          .get();

      if (!basicInfoDoc.exists) {
        Get.snackbar('오류', '존재하지 않는 명함입니다.');
        return;
      }

      // 2. card_book에 추가
      await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .doc(cardId)
          .set({
        'addedAt': FieldValue.serverTimestamp(),
      });

      // 3. cards 리스트 새로고침
      await fetchCards();
      Get.snackbar('성공', '명함이 명함첩에 추가되었습니다.');
    } catch (e) {
      print("명함 추가 실패: $e");
      Get.snackbar('오류', '명함을 추가하는데 실패했습니다.');
    }
  }

  Future<void> removeCardFromBook(String cardId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .doc(cardId)
          .delete();

      cards.removeWhere((card) => card.id == cardId);
      Get.snackbar('성공', '명함이 명함첩에서 삭제되었습니다.');
    } catch (e) {
      print("명함 삭제 실패: $e");
      Get.snackbar('오류', '명함을 삭제하는데 실패했습니다.');
    }
  }

  Future<CardModel?> getCardDetails(String cardId) async {
    try {
      final basicInfoDoc = await _db
          .collection('cards')
          .doc(cardId)
          .collection('basic_info')
          .doc('data')
          .get();

      final contactsDoc = await _db
          .collection('cards')
          .doc(cardId)
          .collection('contacts')
          .doc('data')
          .get();

      if (basicInfoDoc.exists) {
        final basicInfo = basicInfoDoc.data()!;
        final contacts = contactsDoc.exists ? contactsDoc.data()! : {};

        return CardModel(
          id: cardId,
          name: basicInfo['name'] ?? '',
          company: basicInfo['company'] ?? '',
          position: basicInfo['position'] ?? '',
          department: basicInfo['department'] ?? '',
          contacts: Map<String, String>.from(contacts),
        );
      }
    } catch (e) {
      print("명함 상세 정보 불러오기 실패: $e");
    }
    return null;
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
