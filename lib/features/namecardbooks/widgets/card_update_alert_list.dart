import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/card_update_alert_controller.dart';

class CardUpdateAlertList extends StatelessWidget {
  final String myUid;
  const CardUpdateAlertList({required this.myUid, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CardUpdateAlertController());
    controller.loadAlerts(myUid);

    return Obx(() {
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
            onTap: () => controller.markAlertAsRead(myUid, alert.cardId),
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