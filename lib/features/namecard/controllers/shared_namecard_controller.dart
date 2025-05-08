import 'package:get/get.dart';
import 'package:cardmate/features/namecard/services/i_namecard_service.dart';

class SharedNameCardController extends GetxController {
  final String nameCardId;
  final INameCardService _service;

  final isLoading = true.obs;
  final error = ''.obs;
  
  // 기본 정보
  final name = ''.obs;
  final position = ''.obs;
  final department = ''.obs;
  final company = ''.obs;
  final profileImageUrl = ''.obs;
  
  // 연락처 정보
  final contacts = <String, String>{}.obs;

  SharedNameCardController({
    required this.nameCardId,
    required INameCardService nameCardService,
  }) : _service = nameCardService;

  @override
  void onInit() {
    super.onInit();
    loadSharedNameCard();
  }

  Future<void> loadSharedNameCard() async {
    try {
      isLoading.value = true;
      error.value = '';

      final data = await _service.fetchSharedNameCard(nameCardId);
      if (data == null) {
        error.value = '명함을 찾을 수 없습니다.';
        return;
      }

      // 기본 정보 설정
      name.value = data['name'] ?? '';
      position.value = data['position'] ?? '';
      department.value = data['department'] ?? '';
      company.value = data['company'] ?? '';
      profileImageUrl.value = data['photoUrl'] ?? '';

      // 연락처 정보 설정
      final contactsData = data['contacts'] as Map<String, dynamic>?;
      if (contactsData != null) {
        contacts.assignAll(
          Map<String, String>.from(contactsData),
        );
      }
    } catch (e) {
      error.value = '명함 정보를 불러오는데 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }
} 