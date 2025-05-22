import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NameCard {
  final String id;
  final String? name;
  final String? profileUrl;
  final String? webLink;
  final String? department;
  final String? position;
  final String? company;

  NameCard({
    required this.id,
    this.name,
    this.profileUrl,
    this.webLink,
    this.department,
    this.position,
    this.company,
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
    );
  }
}

class CardController extends GetxController {
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final cards = <NameCard>[].obs;

  final isSaving = false.obs;
  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final companyController = TextEditingController();

  int manualCardId = 0;

  @override
  void onInit() {
    super.onInit();
    fetchNameCards();
  }

  void cleaer() {
    nameController.clear();
    positionController.clear();
    departmentController.clear();
    companyController.clear();
  }

  Future<void> addCardManual() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('오류', '이름을 입력해주세요.');
      return;
    }

    isSaving.value = true;
    try {
      final userId = _auth.currentUser?.uid;
      final cardBookSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .get();

      int maxId = 0;
      for (var doc in cardBookSnapshot.docs) {
        try {
          final id = int.parse(doc.id);
          if (id > maxId) maxId = id;
        } catch (e) {
          continue;
        }
      }
      manualCardId = maxId + 1;

      await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .doc(manualCardId.toString())
          .set({
        'name': nameController.text,
        'position': positionController.text,
        'department': departmentController.text,
        'company': companyController.text,
      });

      await fetchNameCards();

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('오류', '저장에 실패했습니다.');
    } finally {
      isSaving.value = false;
      cleaer();
    }
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
      final cardBookSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .get();

      final fetchedCards = <NameCard>[];

      for (final doc in cardBookSnapshot.docs) {
        final cardId = doc.id;
        final data = doc.data();

        if (data.isNotEmpty) {
          // 수동으로 추가된 명함인 경우
          fetchedCards.add(NameCard.fromMap(cardId, data));
        } else {
          // QR/NFC로 추가된 명함인 경우
          final cardDoc = await FirebaseFirestore.instance
              .collection('cards')
              .doc(cardId)
              .get();

          if (cardDoc.exists) {
            fetchedCards.add(NameCard.fromMap(cardId, cardDoc.data()!));
          }
        }
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
          final department =
              (data['department'] ?? '').toString().toLowerCase();
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

  Future<void> deleteCard(String cardId) async {
    try {
      final userId = _auth.currentUser?.uid;
      await _db
          .collection('users')
          .doc(userId)
          .collection('card_book')
          .doc(cardId)
          .delete();

      if (int.tryParse(cardId) != null) {
        final cardContactRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('card_book')
            .doc(cardId)
            .collection('card_contact');

        final snapshot = await cardContactRef.get();

        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      await fetchNameCards();
    } catch (e) {
      print('명함 삭제 실패: $e');
      rethrow;
    }
  }
}
