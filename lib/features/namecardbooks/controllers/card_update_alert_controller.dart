import 'package:get/get.dart';
import '../models/card_update_alert.dart';
import '../services/card_update_alert_service.dart';

class CardUpdateAlertController extends GetxController {
  final CardUpdateAlertService _service = CardUpdateAlertService();
  var alerts = <CardUpdateAlert>[].obs;

  Future<void> loadAlerts(String myUid) async {
    alerts.value = await _service.fetchChangedCards(myUid);
  }

  Future<void> markAlertAsRead(String myUid, String cardId) async {
    await _service.markAsChecked(myUid, cardId);
    await loadAlerts(myUid);
  }
} 