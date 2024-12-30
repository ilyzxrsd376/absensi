import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MiniGameSettingScreen extends StatefulWidget {
  @override
  _MiniGameSettingScreenState createState() => _MiniGameSettingScreenState();
}

class _MiniGameSettingScreenState extends State<MiniGameSettingScreen> {
  final TextEditingController mapelController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController jawabanAController = TextEditingController();
  final TextEditingController jawabanBController = TextEditingController();
  final TextEditingController jawabanCController = TextEditingController();
  final TextEditingController jawabanDController = TextEditingController();
  final TextEditingController jawabanBenarController = TextEditingController();

  Future<void> addQuestion() async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/mini-game/add-question'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'mapel': mapelController.text,
        'pertanyaan': questionController.text,
        'jawaban_a': jawabanAController.text,
        'jawaban_b': jawabanBController.text,
        'jawaban_c': jawabanCController.text,
        'jawaban_d': jawabanDController.text,
        'jawaban_benar': jawabanBenarController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Question added successfully')));
    } else {
      throw Exception('Failed to add question');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mini Game Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: mapelController,
              decoration: InputDecoration(labelText: 'Mapel'),
            ),
            TextField(
              controller: questionController,
              decoration: InputDecoration(labelText: 'Pertanyaan'),
            ),
            TextField(
              controller: jawabanAController,
              decoration: InputDecoration(labelText: 'Jawaban A'),
            ),
            TextField(
              controller: jawabanBController,
              decoration: InputDecoration(labelText: 'Jawaban B'),
            ),
            TextField(
              controller: jawabanCController,
              decoration: InputDecoration(labelText: 'Jawaban C'),
            ),
            TextField(
              controller: jawabanDController,
              decoration: InputDecoration(labelText: 'Jawaban D'),
            ),
            TextField(
              controller: jawabanBenarController,
              decoration: InputDecoration(labelText: 'Jawaban Benar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addQuestion,
              child: Text('Add Question'),
            ),
          ],
        ),
      ),
    );
  }
}
