import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/features/namecard/controllers/namecard_info_controller.dart';

class NameCardInfoScreen extends StatelessWidget {
  const NameCardInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NameCardInfoController>();

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text('이름 / 재직 정보', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Obx(() => GestureDetector(
                      onTap: controller.pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: controller.profileImage.value != null &&
                            controller.profileImage.value!.path.isNotEmpty
                            ? FileImage(controller.profileImage.value!)
                            : (controller.profileImageUrl.value.isNotEmpty
                                ? NetworkImage(controller.profileImageUrl.value)
                                : null) as ImageProvider?,
                        child: (controller.profileImage.value == null ||
                                controller.profileImage.value!.path.isEmpty) &&
                            controller.profileImageUrl.value.isEmpty
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                    )),
                    const SizedBox(height: 8),
                    const Text(
                      '프로필 이미지 변경',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                '기본 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(controller.nameController, '이름'),
              _buildTextField(controller.positionController, '직책'),
              _buildTextField(controller.departmentController, '부서'),
              _buildTextField(controller.companyController, '회사'),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveToFirebase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('저장하기'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
