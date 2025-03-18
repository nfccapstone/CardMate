import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs; // 🔹 현재 선택된 탭 상태

  void changeIndex(int index) {
    currentIndex.value = index; // 🔹 인덱스 변경
  }
}
