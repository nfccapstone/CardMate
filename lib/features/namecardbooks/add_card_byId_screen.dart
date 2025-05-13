import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCardByIdScreen extends StatelessWidget {
  final CardController cardController = Get.find();

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
