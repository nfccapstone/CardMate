import 'package:cardmate/features/namecardbooks/namecard_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'home_controller.dart';
import 'package:cardmate/features/namecardbooks/namecardbooks_screen.dart';
import 'package:cardmate/features/more/more_screen.dart';
import 'package:cardmate/features/more/more_service.dart';
import 'package:cardmate/features/more/more_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
      const MoreScreen(),
    ];

    return Obx(() => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Card",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: "Mate",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.black87),
                onPressed: () {},
              )
            ],
          ),
          body: screens[controller.currentIndex.value],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
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
          ),
        ));
  }

  Widget _buildHomeBody(HomeController controller) {
    return Obx(() {
      if (!controller.isCardRegistered.value || controller.cardData.isEmpty) {
        return Center(
          child: GestureDetector(
            onTap: controller.handleNamecardNavigation,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 40, color: Colors.black87),
                    SizedBox(height: 12),
                    Text(
                      '재직 중인 회사의 명함을 등록해주세요',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
          'https://cardmate-37be3.web.app/card/myNameCard/$cardId';

      return GestureDetector(
        onTap: () async {
          final result = await Get.toNamed('/editCard');
          if (result == true) {
            controller.fetchCardInfo();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: data['profileImageUrl'] != null &&
                              data['profileImageUrl'].toString().isNotEmpty
                          ? NetworkImage(data['profileImageUrl'])
                          : null,
                      child: (data['profileImageUrl'] == null ||
                              data['profileImageUrl'].toString().isEmpty)
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.25),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            QrImageView(
                                              data: profileLink,
                                              version: QrVersions.auto,
                                              size: 200.0,
                                              backgroundColor: Colors.white,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              '내 명함 QR 코드',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              '이 QR 코드를 스캔하여\n내 명함을 확인하세요',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                minimumSize: const Size(
                                                    double.infinity, 48),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: const Text('닫기'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'QR',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${data['department'] ?? ''} / ${data['position'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data['company'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          profileLink,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            size: 18, color: Colors.black38),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: profileLink));
                          Get.snackbar(
                            '복사 완료',
                            '링크가 클립보드에 복사되었습니다.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                      const SizedBox(width: 2),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 공유 기능 추가 예정
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text("공유"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "연락처",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: contact.entries
                        .map<Widget>((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFE0E0E0)),
                                ),
                                child: Row(
                                  children: [
                                    _getContactIcon(entry.key),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${_getContactLabel(entry.key)}: ',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final cardId = data['cardId'] ?? '';
                    Get.toNamed('/card/myNameCard/$cardId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '내 공유 명함 보기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Icon _getContactIcon(String type) {
    switch (type) {
      case 'mobile':
        return const Icon(Icons.phone_android, color: Colors.black54, size: 20);
      case 'email':
        return const Icon(Icons.email, color: Colors.black54, size: 20);
      case 'tel':
        return const Icon(Icons.phone, color: Colors.black54, size: 20);
      case 'fax':
        return const Icon(Icons.print, color: Colors.black54, size: 20);
      default:
        return const Icon(Icons.info_outline, color: Colors.black54, size: 20);
    }
  }

  String _getContactLabel(String type) {
    switch (type) {
      case 'mobile':
        return '휴대전화';
      case 'email':
        return '이메일';
      case 'tel':
        return '전화번호';
      case 'fax':
        return '팩스';
      default:
        return type;
    }
  }
}
