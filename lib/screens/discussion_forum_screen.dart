import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discussion Forum & Chat App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Color(0xFF2F3136),
        ),
        scaffoldBackgroundColor: Color(0xFF36393F),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.dark, 
      home: DiscussionForumScreen(),
    );
  }
}

class DiscussionForumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum Diskusi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Diskusi Guru dan Murid",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDiscussionItem(context, "Diskusi 1: Metode Pembelajaran", "Guru A", "assets/teacher1.png"),
                  _buildDiscussionItem(context, "Diskusi 2: Perencanaan Kegiatan", "Guru B", "assets/teacher2.png"),
                  _buildDiscussionItem(context, "Diskusi 3: Tugas Murid", "Murid C", "assets/student1.png"),
                  _buildDiscussionItem(context, "Diskusi 4: Pengalaman Belajar", "Murid D", "assets/student2.png"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionItem(BuildContext context, String title, String userName, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MessageScreen(username: userName)),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imagePath),
            radius: 30,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Diposting oleh: $userName",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageScreen extends StatefulWidget {
  final String username;

  MessageScreen({required this.username});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Map<String, String>> messages = [
    {'sender': 'Guru A', 'message': 'Apakah kamu sudah selesai tugas?', 'image': 'assets/teacher1.png', 'time': '1:29 PM'},
    {'sender': 'You', 'message': 'Belum, masih dalam progress.', 'image': 'assets/student1.png', 'time': '1:30 PM'},
    {'sender': 'Guru A', 'message': 'Ayo,cepet kita ngopi', 'image': 'assets/teacher1.png', 'time': '1:31 PM'},
    {'sender': 'You', 'message': 'Siap!', 'image': 'assets/student1.png', 'time': '1:32 PM'},
  ];

  TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'You',
          'message': _controller.text,
          'image': 'assets/student1.png',
          'time': 'Now'
        });
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.username}"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isCurrentUser = messages[index]['sender'] == 'You';
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(messages[index]['image']!),
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    messages[index]['sender']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentUser ? Colors.blue[300] : Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    messages[index]['time']!,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? Color(0xFF4A90E2) : Color(0xFF40444B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  messages[index]['message']!,
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.grey[200],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Tulis Pesan...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFF40444B),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Color(0xFF4A90E2)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
