import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/my_namecard_controller.dart';
import 'package:cardmate/features/namecard/widgets/profile_section.dart';
import 'package:cardmate/features/namecard/widgets/block_section.dart';
import 'package:url_launcher/url_launcher.dart';

class MyNameCardScreen extends StatelessWidget {
  const MyNameCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyNameCardController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '내 공유명함',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSection(basicInfo: controller.basicInfo),
              const SizedBox(height: 20),
              _ContactSectionReadOnly(controller: controller),
              const SizedBox(height: 20),
              BlockSection(blocks: controller.blocks),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}

// 연락처 읽기 전용 위젯
class _ContactSectionReadOnly extends StatelessWidget {
  final MyNameCardController controller;
  const _ContactSectionReadOnly({required this.controller});

  @override
  Widget build(BuildContext context) {
    final contacts = controller.basicInfo['contacts'] ?? [];
    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('연락처',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...contacts.map<Widget>((contact) {
          final type = contact['type'];
          final value = contact['value'];
          IconData icon;
          VoidCallback? onTap;
          if (type == 'phone') {
            icon = Icons.phone;
            onTap = () => launchUrl(Uri.parse('tel:$value'));
          } else if (type == 'email') {
            icon = Icons.email;
            onTap = () => launchUrl(Uri.parse('mailto:$value'));
          } else if (type == 'url') {
            icon = Icons.link;
            onTap = () => launchUrl(Uri.parse(value));
          } else {
            icon = Icons.contact_page;
            onTap = null;
          }
          return ListTile(
            leading: Icon(icon, color: Colors.deepPurple),
            title: Text(value),
            onTap: onTap,
          );
        }).toList(),
      ],
    );
  }
}
