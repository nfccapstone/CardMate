import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    final screens = [
      const Center(child: Text('명함첩')),
      const Center(child: Text('Net')),
      _buildHomeBody(controller),
      const Center(child: Text('AI 기능')),
      const Center(child: Text('더보기')),
    ];

    return Obx(() => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('CardMate'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {},
              )
            ],
          ),
          body: screens[controller.currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeIndex,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.folder), label: '명함첩'),
              BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Net'),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'AI'),
              BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '더보기'),
            ],
          ),
        ));
  }

  Widget _buildHomeBody(HomeController controller) {
    return Obx(() {
      if (!controller.isCardRegistered.value) {
        return Center(
          child: GestureDetector(
            onTap: controller.handleNamecardNavigation,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 40, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      '재직 중인 회사의 명함을 등록해주세요',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // 명함 등록 시: 편집/미리보기 버튼만 표시
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/editCard');
                },
                icon: const Icon(Icons.edit),
                label: const Text("명함 편집"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // 추후 미리보기 화면으로 이동
                },
                icon: const Icon(Icons.language),
                label: const Text("미리보기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
