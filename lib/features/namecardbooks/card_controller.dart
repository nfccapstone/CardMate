import 'package:cardmate/firebase/firebase_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'models/card_memo.dart';

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

enum CardSortType { addedAt, name, company }

class CardController extends GetxController {
  final FirebaseAuth _auth = FirebaseInit.instance.auth;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final cards = <NameCard>[].obs;
  final cardMemos = <String, CardMemo>{}.obs;
  final isAscending = true.obs; // 정렬 방향 상태 (true: 오래된순, false: 최신순)
  final sortType = CardSortType.addedAt.obs; // 정렬 기준 상태

  @override
  void onInit() {
    super.onInit();
    fetchNameCards();
    fetchCardMemos();
  }

  void changeSortType(CardSortType type) {
    sortType.value = type;
    _sortCards();
  }

  void toggleSortOrder() {
    isAscending.value = !isAscending.value;
    _sortCards();
  }

  void _sortCards() {
    cards.sort((a, b) {
      int cmp;
      switch (sortType.value) {
        case CardSortType.name:
          cmp = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case CardSortType.company:
          cmp = (a.company ?? '').compareTo(b.company ?? '');
          break;
        case CardSortType.addedAt:
        default:
          final aTime = a.rawData?['addedAt'] as Timestamp? ?? a.rawData?['createdAt'] as Timestamp?;
          final bTime = b.rawData?['addedAt'] as Timestamp? ?? b.rawData?['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return isAscending.value ? 1 : -1;
          if (bTime == null) return isAscending.value ? -1 : 1;
          cmp = aTime.compareTo(bTime);
      }
      return isAscending.value ? cmp : -cmp;
    });
  }

  Future<void> addCardById(String cardId) async {
    final userId = _auth.currentUser?.uid;
    final now = DateTime.now();

    // card_book 컬렉션에 추가
    await _db
        .collection('users')
        .doc(userId)
        .collection('card_book')
        .doc(cardId)
        .set({
          'addedAt': Timestamp.fromDate(now),
        });

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
      for (final doc in cardBookSnapshot.docs) {
        final cardId = doc.id;
        final cardDoc = await _db.collection('cards').doc(cardId).get();
        if (cardDoc.exists) {
          final data = cardDoc.data()!;
          data['addedAt'] = doc.data()['addedAt']; // 추가 시간 정보 포함
          fetchedCards.add(NameCard.fromMap(cardId, data));
        }
      }

      // 수동 명함(make_book)
      for (final doc in makeBookSnapshot.docs) {
        fetchedCards.add(NameCard.fromManualMap(doc.id, doc.data()));
      }

      cards.assignAll(fetchedCards);
      _sortCards();
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
    final makeBookSnapshot =
        await _db.collection('users').doc(uid).collection('make_book').get();

    final searchedCards = <NameCard>[];
    final searchInput = input.toLowerCase(); // 검색어를 소문자로 변환

    // 공유 명함(card_book) 검색
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

          if (name.contains(searchInput) ||
              company.contains(searchInput) ||
              department.contains(searchInput) ||
              position.contains(searchInput)) {
            searchedCards.add(NameCard.fromMap(cardId, data));
          }
        }
      }),
    );

    // 수동 명함(make_book) 검색
    for (final doc in makeBookSnapshot.docs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final company = (data['company'] ?? '').toString().toLowerCase();
      final department = (data['department'] ?? '').toString().toLowerCase();
      final position = (data['position'] ?? '').toString().toLowerCase();

      if (name.contains(searchInput) ||
          company.contains(searchInput) ||
          department.contains(searchInput) ||
          position.contains(searchInput)) {
        searchedCards.add(NameCard.fromManualMap(doc.id, data));
      }
    }

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

  Future<void> fetchCardMemos() async {
    try {
      final userId = _auth.currentUser?.uid;
      final memosSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('card_memos')
          .get();

      final memos = <String, CardMemo>{};
      for (var doc in memosSnapshot.docs) {
        final memo = CardMemo.fromMap(doc.data());
        memos[memo.cardId] = memo;
      }
      cardMemos.assignAll(memos);
    } catch (e) {
      print('메모 불러오기 실패: $e');
    }
  }

  Future<void> saveCardMemo(String cardId, String memo) async {
    try {
      final userId = _auth.currentUser?.uid;
      final now = DateTime.now();
      
      final cardMemo = CardMemo(
        cardId: cardId,
        memo: memo,
        createdAt: now,
        updatedAt: now,
      );

      await _db
          .collection('users')
          .doc(userId)
          .collection('card_memos')
          .doc(cardId)
          .set(cardMemo.toMap());

      cardMemos[cardId] = cardMemo;
    } catch (e) {
      print('메모 저장 실패: $e');
      rethrow;
    }
  }

  Future<void> deleteCardMemo(String cardId) async {
    try {
      final userId = _auth.currentUser?.uid;
      await _db
          .collection('users')
          .doc(userId)
          .collection('card_memos')
          .doc(cardId)
          .delete();

      cardMemos.remove(cardId);
    } catch (e) {
      print('메모 삭제 실패: $e');
      rethrow;
    }
  }
}
