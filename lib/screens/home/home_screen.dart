import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'nfc_read_screen.dart'; // NFC 읽기 화면
import 'nfc_write_screen.dart'; // NFC 쓰기 화면
import '../../getX/controllers/home_controller.dart'; // HomeController import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController()); // 🔹 컨트롤러 주입

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => IndexedStack(
            index: homeController.currentIndex.value,
            children: const [
              Center(
                child: Text("홈 화면",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              NfcWriteScreen(), // NFC 쓰기 화면
              NfcReadScreen(), // NFC 읽기 화면
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: homeController.currentIndex.value,
            onTap: homeController.changeIndex, // 🔹 클릭 시 컨트롤러의 함수 실행
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.nfc),
                label: 'NFC Write',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.nfc),
                label: 'NFC Read',
              ),
            ],
          )),
    );
  }
}
