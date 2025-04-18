import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatelessWidget {
  final CardController cardController = Get.find();

  // final nameCtrl = TextEditingController();
  // final positionCtrl = TextEditingController();
  // final departmentCtrl = TextEditingController();
  // final companyCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("아이디로 명함 등록")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idCtrl,
                decoration: InputDecoration(labelText: 'CardMateID'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // final newCard = CardModel(
                  //   id: '',
                  //   name: nameCtrl.text,
                  //   position: positionCtrl.text,
                  //   department: departmentCtrl.text,
                  //   company: companyCtrl.text,
                  // );
                  cardController.addCardById(idCtrl.text);
                  Get.back();
                },
                child: Text('등록'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
