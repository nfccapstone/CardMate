import 'package:cardmate/screens/namecardbooks/namecard_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/home_controller.dart';
import 'package:cardmate/screens/namecardbooks/namecardbooks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    final screens = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          NamecardbooksScreen(),
          Expanded(
            child: Center(
              child: NameCardListScreen(),
            ),
          ),
        ],
      ),
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt), label: 'Net'),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.auto_graph), label: 'AI'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: '더보기'),
            ],
          ),
        ));
  }

  Widget _buildHomeBody(HomeController controller) {
    return Obx(() {
      if (!controller.isCardRegistered.value || controller.cardData.isEmpty) {
        // 명함 등록 전
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

      final data = controller.cardData;
      final contact = data['contact'] ?? {};
      final cardMateId = data['cardMateId'] ?? 'yourID';
      final profileLink = 'https://cardmate.link/@$cardMateId';

      return GestureDetector(
        onTap: () => Get.toNamed('/editCard'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름, 직책
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data['department'] ?? ''} / ${data['position'] ?? ''}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  data['company'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 16),

                // 링크 + 공유 + QR
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profileLink,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.copy,
                          size: 16, color: Colors.white54),
                      onPressed: () {
                        // 복사 기능 추가 예정
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 공유 기능 추가 예정
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text("공유"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      color: Colors.white24,
                      alignment: Alignment.center,
                      child: const Text('QR',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 연락처 (휴대전화 + 이메일만 표시)
                if (contact['mobile'] != null) ...[
                  Text('연락처: ${contact['mobile']}',
                      style: const TextStyle(color: Colors.white)),
                ],
                if (contact['email'] != null) ...[
                  const SizedBox(height: 6),
                  Text('Email: ${contact['email']}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
