import 'package:get/get.dart';
import 'package:cardmate/features/home/services/i_home_service.dart';
import 'package:cardmate/features/namecard/services/i_profile_image_service.dart';

class HomeController extends GetxController {
  /// 하단 네비게이션 현재 인덱스 (기본값: Home = 2)
  var currentIndex = 2.obs;

  /// 명함 등록 여부 상태
  var isCardRegistered = false.obs;

  /// Firestore에서 불러온 명함 데이터 저장용
  var cardData = <String, dynamic>{}.obs;

  var contactInfo = <String, String>{}.obs;
  var cardBlocks = <Map<String, dynamic>>[].obs;
  var cardStyle = <String, dynamic>{}.obs;
  var profileImageUrl = ''.obs;

  var isLoading = true.obs;
  var _isInitialized = false;
  var _isLoadingData = false;

  final IHomeService _homeService;
  final IProfileImageService _profileImageService;

  // DI를 통해 IHomeService 구현체를 주입받습니다.
  HomeController({
    required IHomeService homeService,
    required IProfileImageService profileImageService,
  })  : _homeService = homeService,
        _profileImageService = profileImageService;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;
    isLoading.value = true;

    try {
      // 모든 데이터를 병렬로 로드
      final results = await Future.wait([
        _homeService.fetchCardData(),
        _homeService.fetchContactInfo(),
        _homeService.fetchCardBlocks(),
        _homeService.fetchCardStyle(),
        _profileImageService.getProfileImageUrl(),
      ]);

      // 결과 할당 (타입 캐스팅 추가)
      if (results[0] != null) {
        cardData.assignAll(results[0] as Map<String, dynamic>);
        isCardRegistered.value = true;
      }
      if (results[1] != null) contactInfo.assignAll(results[1] as Map<String, String>);
      if (results[2] != null) cardBlocks.assignAll(results[2] as List<Map<String, dynamic>>);
      if (results[3] != null) cardStyle.assignAll(results[3] as Map<String, dynamic>);
      if (results[4] != null) profileImageUrl.value = results[4] as String;

      _isInitialized = true;
    } catch (e) {
      print('데이터 초기화 오류: $e');
      Get.snackbar('오류', '데이터를 불러오는 중 문제가 발생했습니다.');
    } finally {
      isLoading.value = false;
      _isLoadingData = false;
    }
  }

  Future<void> refreshData() async {
    _isInitialized = false;
    await _initializeData();
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
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final data = await _homeService.fetchCardData();
      if (data != null) {
        updateCardData(data);
        registerCard();
      }
    } catch (e) {
      print('명함 정보 로딩 오류: $e');
      Get.snackbar('오류', '명함 정보를 불러오는데 실패했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  /// 명함 등록 여부 확인 후 화면 전환
  Future<void> handleNamecardNavigation() async {
    try {
      final exists = await _homeService.checkCardExists();
      if (exists) {
        Get.toNamed('/namecard');
      } else {
        Get.toNamed('/create-namecard');
      }
    } catch (e) {
      print('명함 네비게이션 오류: $e');
      Get.snackbar('오류', '명함 페이지로 이동하는 중 문제가 발생했습니다.');
    }
  }

  @override
  void onClose() {
    _profileImageService.clearCache();
    super.onClose();
  }
}
