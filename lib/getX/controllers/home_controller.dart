import 'package:cardmate/getX/controllers/namecard_info_controller.dart';
import 'package:get/get.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';
import 'package:cardmate/services/home_service.dart';

class HomeController extends GetxController {
  /// 하단 네비게이션 현재 인덱스 (기본값: Home = 2)
  var currentIndex = 2.obs;

  /// 명함 등록 여부 상태
  var isCardRegistered = false.obs;

  /// Firebase에서 불러온 명함 데이터 저장용
  var cardData = <String, dynamic>{}.obs;

  final HomeService _homeService = HomeService();

  @override
  void onInit() {
    super.onInit();
    fetchCardInfo(); // ✅ 앱 실행 시 명함 정보 로드
    
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void registerCard() {
    isCardRegistered.value = true;
  }

  void updateCardData(Map<String, dynamic> newData) {
    cardData.assignAll(newData);
  }

  /// 🔄 명함 정보 및 연락처 정보를 함께 불러옴
  Future<void> fetchCardInfo() async {
    final basicInfo = await _homeService.fetchCardData(); // 기존 문서 (users/{uid})
    final contactInfo = await _homeService
        .fetchContactInfo(); // 🔹 연락처 문서 (my_namecard/contact)

    if (basicInfo != null) {
      final combined = {...basicInfo};

      if (contactInfo != null) {
        combined['contact'] = contactInfo;
      }

      updateCardData(combined);
      registerCard();
    }
  }

  /// 기존 명함 등록 여부만 확인하고 해당 화면으로 이동
  Future<void> handleNamecardNavigation() async {
    final exists = await _homeService.checkCardExists();

    if (exists) {
      Get.toNamed('/editCard');
    } else {
      Get.toNamed('/namecardInfo');
    }
    registerCard(); // 조건과 무관하게 상태 변경
  }
}
