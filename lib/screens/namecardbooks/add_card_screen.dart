import 'package:cardmate/screens/namecardbooks/card_controller.dart';
import 'package:cardmate/screens/namecardbooks/card_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatelessWidget {
  final CardController cardController = Get.find();

  final nameCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("명함 추가")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: '이름')),
            TextField(
                controller: positionCtrl,
                decoration: InputDecoration(labelText: '직책')),
            TextField(
                controller: departmentCtrl,
                decoration: InputDecoration(labelText: '부서')),
            TextField(
                controller: companyCtrl,
                decoration: InputDecoration(labelText: '회사')),
            TextField(
                controller: idCtrl,
                decoration: InputDecoration(labelText: 'CardMateID')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newCard = CardModel(
                  id: '',
                  name: nameCtrl.text,
                  position: positionCtrl.text,
                  department: departmentCtrl.text,
                  company: companyCtrl.text,
                );
                cardController.addCard(newCard);
                Get.back();
              },
              child: Text('등록'),
            )
          ],
        ),
      ),
    );
  }
}
