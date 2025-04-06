import 'package:cardmate/screens/namecardbooks/card_controller.dart';
import 'package:cardmate/screens/namecardbooks/card_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCardScreen2 extends StatelessWidget {
  final CardController cardController = Get.find();
  final CardModel card;

  EditCardScreen2({required this.card});

  final nameCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameCtrl.text = card.name;
    positionCtrl.text = card.position;
    departmentCtrl.text = card.department;
    companyCtrl.text = card.company;
    idCtrl.text = card.id;

    return Scaffold(
      appBar: AppBar(title: Text("명함 수정")),
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
                final updatedCard = CardModel(
                  id: card.id,
                  name: nameCtrl.text,
                  company: companyCtrl.text,
                  position: positionCtrl.text,
                  department: departmentCtrl.text,
                );
                cardController.updateCard(updatedCard);
                Get.back();
              },
              child: Text('저장'),
            )
          ],
        ),
      ),
    );
  }
}
