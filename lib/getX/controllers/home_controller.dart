import 'package:get/get.dart';
import 'package:cardmate/services/firebase/firebase_init.dart';
import 'package:cardmate/services/home_service.dart';

class HomeController extends GetxController {
  /// 하단 네비게이션 현재 인덱스 (기본값: Home = 2)
  var currentIndex = 2.obs;

  /// 명함 등록 여부 상태
  var isCardRegistered = false.obs;

  /// Firebase에서 불러온 명함 데이터 저장용 (필요 시 활용)
  var cardData = <String, dynamic>{}.obs;

  /// 하단 네비게이션 인덱스 변경
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  /// 명함 등록 상태를 true로 변경
  void registerCard() {
    isCardRegistered.value = true;
  }

  /// 명함 데이터 업데이트 (obs map에 반영)
  void updateCardData(Map<String, dynamic> newData) {
    cardData.assignAll(newData);
  }

  /// 명함 등록 여부 확인 후 해당 화면으로 이동
  /// - 등록되어 있으면 editCard로 이동
  /// - 등록 안 되어 있으면 namecardInfo로 이동
  final HomeService _homeService = HomeService();

  Future<void> handleNamecardNavigation() async {
    final exists = await _homeService.checkCardExists();

    if (exists) {
      Get.toNamed('/editCard');
    } else {
      Get.toNamed('/namecardInfo');
    }
    registerCard();
  }
}
