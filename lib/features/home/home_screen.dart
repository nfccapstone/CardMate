import 'package:cardmate/features/namecardbooks/namecard_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_controller.dart';
import 'package:cardmate/features/namecardbooks/namecardbooks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeController는 GetX 바인딩을 통해 등록된 인스턴스를 가져옵니다.
    final HomeController controller = Get.find<HomeController>();

    final screens = [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '더보기',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
              onTap: () {
                // 로그아웃 처리
                // 예시: Get.offAllNamed('/login');
                Get.defaultDialog(
                  title: "로그아웃",
                  middleText: "정말 로그아웃 하시겠습니까?",
                  textConfirm: "예",
                  textCancel: "아니오",
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    // 로그아웃 로직 (예: 인증 해제 및 로그인 화면 이동)

                    // SharedPreferences에서 자동 로그인 정보 삭제
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('email');
                    await prefs.remove('password');

                    // 로그인 화면으로 이동
                    Get.offAllNamed('/login');
                  },
                );
              }),
        ],
      )
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
      final nameCardId = data['nameCardId'] ?? '';
      final cardId = data['cardId'] ?? '';
      final profileLink =
          cardId.isEmpty ? 'cardmate.link' : 'cardmate.link/@$cardId';

      return GestureDetector(
        onTap: () async {
          final result = await Get.toNamed('/editCard');
          if (result == true) {
            controller.fetchCardInfo();
          }
        },
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
                // 상단 Row: 프로필 사진, 기본 정보, QR 버튼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // namecard_info_screen과 유사하게 이미지 로딩 조건 처리
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: data['profileImageUrl'] != null &&
                              data['profileImageUrl'].toString().isNotEmpty
                          ? NetworkImage(data['profileImageUrl'])
                          : null,
                      child: (data['profileImageUrl'] == null ||
                              data['profileImageUrl'].toString().isEmpty)
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['company'] ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text('QR',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 링크, 복사, 공유 버튼 Row
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
                  ],
                ),
                const SizedBox(height: 20),
                // 연락처 정보 전체 출력
                if (contact.isNotEmpty) ...[
                  const Text(
                    "연락처:",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...contact.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                ],
                // 공유 명함 확인 버튼 추가
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/myNameCard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('내 공유 명함 보기'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
