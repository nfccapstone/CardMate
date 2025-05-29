import 'package:get/get.dart';
import '../models/card_update_alert.dart';
import '../services/card_update_alert_service.dart';

class CardUpdateAlertController extends GetxController {
  final CardUpdateAlertService _service = CardUpdateAlertService();
  var alerts = <CardUpdateAlert>[].obs;
  var isLoading = false.obs;
  var error = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever(isLoading, (_) => update());
  }

  Future<void> loadAlerts(String myUid) async {
    try {
      isLoading.value = true;
      error.value = null;
      var fetched = await _service.fetchChangedCards(myUid);

      // 최신순 정렬 (updatedAt 내림차순)
      fetched.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // 10개만 남기기
      alerts.value = fetched.take(10).toList();
    } catch (e) {
      error.value = '알림을 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAlertAsRead(String myUid, String cardId) async {
    try {
      isLoading.value = true;
      error.value = null;
      await _service.markAsChecked(myUid, cardId);
      await loadAlerts(myUid);
    } catch (e) {
      error.value = '알림을 읽음 처리하는 중 오류가 발생했습니다: $e';
    } finally {
      isLoading.value = false;
    }
  }
}