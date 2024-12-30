import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MiniGameScreen extends StatefulWidget {
  @override
  _MiniGameScreenState createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  late String username;
  String selectedMapel = 'Matematika'; // Mapel default

  @override
  void initState() {
    super.initState();
    _getUsername(); // Ambil username dari SharedPreferences
    fetchQuestions(); // Ambil soal dari API
  }

  // Fungsi untuk mengambil username dari SharedPreferences
  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? ''; // Ambil username yang disimpan
    });
  }

  // Fungsi untuk mengambil soal berdasarkan mapel secara random
  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse('https://ilyasa.verdantns.xyz/api/mini-game-questions/$selectedMapel'));

    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  // Fungsi untuk mengecek jawaban
  Future<void> checkAnswer(String answer) async {
    final question = questions[currentQuestionIndex];

    final response = await http.post(
      Uri.parse('https://ilyasa.verdantns.xyz/api/mini-game/check-answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username, // Gunakan username dari SharedPreferences
        'jawaban': answer,
        'question_id': question['id'],
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        if (answer == question['jawaban_benar']) {
          score += 10;
        }
        currentQuestionIndex++;
        isAnswered = true;
      });
    } else {
      throw Exception('Failed to check answer');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Mini Game')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Game - Score: $score'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown untuk memilih mapel
            DropdownButton<String>(
              value: selectedMapel,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMapel = newValue!;
                  fetchQuestions(); // Ambil soal sesuai mapel yang dipilih
                });
              },
              items: <String>['akl', 'tjkt', 'pm', 'mplb', 'tkl', 'dkv']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(currentQuestion['pertanyaan'], style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ...['jawaban_a', 'jawaban_b', 'jawaban_c', 'jawaban_d'].map((jawaban) {
              return ElevatedButton(
                onPressed: isAnswered
                    ? null
                    : () => checkAnswer(currentQuestion[jawaban]),
                child: Text(currentQuestion[jawaban]),
              );
            }).toList(),
            if (isAnswered)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAnswered = false;
                  });
                },
                child: Text('Next Question'),
              )
          ],
        ),
      ),
    );
  }
}
