import 'package:get/get.dart';
import 'services/i_home_service.dart';

class HomeController extends GetxController {
  /// 하단 네비게이션 현재 인덱스 (기본값: Home = 2)
  var currentIndex = 2.obs;

  /// 명함 등록 여부 상태
  var isCardRegistered = false.obs;

  /// Firestore에서 불러온 명함 데이터 저장용
  var cardData = <String, dynamic>{}.obs;

  var isLoading = true.obs;

  final IHomeService _homeService;

  // DI를 통해 IHomeService 구현체를 주입받습니다.
  HomeController({required IHomeService homeService})
      : _homeService = homeService;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await fetchCardInfo();
    } finally {
      isLoading.value = false;
    }
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

  /// 명함 정보 및 연락처 정보를 함께 불러옴
  Future<void> fetchCardInfo() async {
    try {
      final basicInfo = await _homeService.fetchCardData();
      final contactInfo = await _homeService.fetchContactInfo();

      if (basicInfo != null) {
        final combined = {...basicInfo};

        if (contactInfo != null) {
          combined['contact'] = contactInfo;
        }

        updateCardData(combined);
        registerCard();
      }
    } catch (e) {
      print('명함 정보 로딩 오류: $e');
    }
  }

  /// 명함 등록 여부 확인 후 화면 전환
  Future<void> handleNamecardNavigation() async {
    try {
      final exists = await _homeService.checkCardExists();

      if (exists) {
        Get.toNamed('/editCard');
      } else {
        Get.toNamed('/namecardInfo');
      }
      registerCard();
    } catch (e) {
      print('명함 네비게이션 오류: $e');
    }
  }
}
