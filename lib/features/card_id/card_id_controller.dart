import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'i_card_id_service.dart';

class CardIdController extends GetxController {
  final ICardIdService _cardIdService;
  final String userId;

  CardIdController({
    required ICardIdService cardIdService,
    required this.userId,
  }) : _cardIdService = cardIdService;

  final cardIdController = TextEditingController();
  final isLoading = false.obs;
  final isCardIdValid = false.obs;

  Future<void> generateCardId() async {
    try {
      isLoading.value = true;
      final cardId = await _cardIdService.generateUniqueCardId();
      cardIdController.text = cardId;
      await validateCardId(); // 자동 생성된 ID의 유효성 검사
    } catch (e) {
      Get.snackbar(
        "오류",
        "카드 ID 생성 중 오류가 발생했습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateCardId() async {
    try {
      isLoading.value = true;

      if (!_cardIdService.isValidCardIdFormat(cardIdController.text.trim())) {
        Get.snackbar(
          "오류",
          "카드 ID는 16자리의 영어 대문자와 숫자 조합이어야 합니다.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        isCardIdValid.value = false;
        return;
      }

      final isValid =
          await _cardIdService.validateCardId(cardIdController.text.trim());
      isCardIdValid.value = isValid;

      if (!isValid) {
        Get.snackbar(
          "오류",
          "유효하지 않은 카드 ID입니다.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "오류",
        "카드 ID 확인 중 오류가 발생했습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> linkCardId() async {
    if (!isCardIdValid.value) {
      Get.snackbar(
        "오류",
        "유효한 카드 ID를 먼저 확인해주세요.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      final success = await _cardIdService.linkCardIdToUser(
        userId,
        cardIdController.text.trim(),
      );

      if (success) {
        Get.snackbar("성공", "카드 ID가 등록되었습니다.");
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          "오류",
          "카드 ID 등록에 실패했습니다.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "오류",
        "카드 ID 등록 중 오류가 발생했습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    cardIdController.dispose();
    super.onClose();
  }
}
