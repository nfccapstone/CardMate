import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'card_id_controller.dart';

class CardIdScreen extends GetView<CardIdController> {
  const CardIdScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Text(
                "카드 ID 등록",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "회원가입이 완료되었습니다.\n카드 ID를 입력해주세요.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.cardIdController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "카드 ID",
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: "16자리 영어 대문자와 숫자 조합",
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.validateCardId,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("확인"),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.generateCardId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("카드 ID 자동 생성",
                        style: TextStyle(fontSize: 16)),
                  )),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.linkCardId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text("카드 ID 등록",
                            style: TextStyle(fontSize: 18)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
