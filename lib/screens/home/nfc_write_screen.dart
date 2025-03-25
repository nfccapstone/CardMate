import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cardmate/getX/controllers/nfc_write_controller.dart';

class NfcWriteScreen extends StatelessWidget {
  const NfcWriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NfcWriteController controller = Get.put(NfcWriteController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NFC 명함 저장",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildInputField(controller.nameController, "이름", Icons.person),
              const SizedBox(height: 12),
              _buildInputField(controller.phoneController, "전화번호", Icons.phone),
              const SizedBox(height: 12),
              _buildInputField(controller.emailController, "이메일", Icons.email),
              const SizedBox(height: 12),
              _buildInputField(controller.companyController, "소속", Icons.business),
              const SizedBox(height: 12),

              // ✅ 직종 드롭다운 추가
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.jobCategory.value.isEmpty
                        ? null
                        : controller.jobCategory.value,
                    items: controller.jobCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.jobCategory.value = value;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "직종",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                  )),
              const SizedBox(height: 12),

              _buildInputField(controller.positionController, "직함", Icons.badge),
              const SizedBox(height: 12),
              _buildInputField(controller.addressController, "주소", Icons.location_on),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: controller.writeNfcData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "💾  NFC에 정보 저장",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
    );
  }
}
