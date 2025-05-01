import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardMate',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CardDesignScreen(),
    );
  }
}

class CardDesignScreen extends StatefulWidget {
  const CardDesignScreen({super.key});

  @override
  _CardDesignScreenState createState() => _CardDesignScreenState();
}

class _CardDesignScreenState extends State<CardDesignScreen> {
  String? cardDesign;

  @override
  void initState() {
    super.initState();
    fetchCardDesign();
  }

  Future<void> fetchCardDesign() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/design'));
      if (response.statusCode == 200) {
        setState(() {
          cardDesign = jsonDecode(response.body)['design'];
        });
      } else {
        throw Exception('Failed to load card design');
      }
    } catch (e) {
      setState(() {
        cardDesign = 'Error loading design: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Design')),
      body: Center(
        child: cardDesign == null
            ? const CircularProgressIndicator()
            : Text(
                cardDesign!,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}