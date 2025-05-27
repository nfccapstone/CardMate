import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/card_update_alert_controller.dart';

class CardUpdateAlertList extends StatefulWidget {
  final String myUid;
  const CardUpdateAlertList({required this.myUid, super.key});

  @override
  State<CardUpdateAlertList> createState() => _CardUpdateAlertListState();
}

class _CardUpdateAlertListState extends State<CardUpdateAlertList> {
  late final CardUpdateAlertController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CardUpdateAlertController());
    controller.loadAlerts(widget.myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.error.value!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadAlerts(widget.myUid),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      }

      if (controller.alerts.isEmpty) {
        return const Center(
          child: Text(
            '새로운 알림이 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.alerts.length,
        itemBuilder: (context, index) {
          final alert = controller.alerts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(alert.cardOwnerProfileUrl),
            ),
            title: Text('${alert.cardOwnerName}님이 명함을 수정했습니다.'),
            subtitle: Text(_timeAgo(alert.updatedAt)),
            onTap: () {
              controller.markAlertAsRead(widget.myUid, alert.cardId);
              Get.toNamed('/card/myNameCard/${alert.cardId}');
            },
          );
        },
      );
    });
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}