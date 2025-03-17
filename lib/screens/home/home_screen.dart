import 'package:flutter/material.dart';
import 'nfc_read_screen.dart'; // NFC 읽기 화면
import 'nfc_write_screen.dart'; // NFC 쓰기 화면

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Center(
            child: Text("홈 화면",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          NfcWriteScreen(), // NFC 쓰기 화면
          NfcReadScreen(), // NFC 읽기 화면
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc),
            label: 'NFC Write',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc),
            label: 'NFC Read',
          ),
        ],
      ),
    );
  }
}
