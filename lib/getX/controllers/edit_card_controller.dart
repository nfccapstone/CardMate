import 'package:get/get.dart';
import 'package:cardmate/services/edit_card_service.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';

class EditCardController extends GetxController {
  final isLoading = true.obs;
  final basicInfo = <String, dynamic>{}.obs;

  final contacts = <String, String>{}.obs;

  final EditCardService _service = EditCardService();

  // 🔧 여기 추가
  final _auth = FirebaseInit.instance.auth;
  final _firestore = FirebaseInit.instance.firestore;

  @override
  void onInit() {
    super.onInit();
    loadNameCardData();
    loadContacts(); // 연락처도 같이 불러오기
  }

  Future<void> loadNameCardData() async {
    isLoading.value = true;
    final data = await _service.fetchBasicInfo();
    if (data != null) {
      basicInfo.assignAll(data);
    } else {
      Get.snackbar('오류', '명함 정보를 불러오지 못했습니다.');
    }
    isLoading.value = false;
  }

Future<void> loadContacts() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  try {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('my_namecard')
        .doc('contacts')
        .get();

    if (doc.exists) {
      contacts.assignAll(Map<String, String>.from(doc.data()!));
    }
  } catch (e) {
    print('연락처 불러오기 오류: $e');
  }
}


  /*Future<void> addContact(String type, String value) async {
  try {
    await _service.saveContact(type, value);
    await loadContacts(); // 연락처 목록 다시 로드
  } catch (_) {
    Get.snackbar('오류', '연락처 저장에 실패했어요.');
  }
}*/

}
