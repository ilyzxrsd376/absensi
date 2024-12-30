import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatHistoryScreen(),
    );
  }
}

class ChatHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Chat"),
        backgroundColor: Color(0xFF1A73E8),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 10, 
        itemBuilder: (context, index) {
          return Card(
            color: Colors.blue[50], 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  "${index + 1}",
                  style: TextStyle(color: Color(0xFF1A73E8)),
                ),
              ),
              title: Text("Percakapan ${index + 1}"),
              subtitle: Text("Riwayat pesan dengan kontak ${index + 1}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(contactId: index + 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final int contactId;

  ChatScreen({required this.contactId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [
    {'sender': 'User1', 'message': 'Oe ngap?'},
    {'sender': 'You', 'message': 'Oe, kenape?'},
    {'sender': 'User1', 'message': 'Ngopi kuy'},
    {'sender': 'You', 'message': 'Gas lah'},
  ]; 
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'You',
          'message': _controller.text,
        });
        _controller.clear(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Percakapan dengan Kontak ${widget.contactId}"),
        backgroundColor: Color(0xFF1A73E8),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: _messages[index]['sender'] == 'You'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _messages[index]['sender'] == 'You'
                          ? Color(0xFF1A73E8) 
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _messages[index]['message']!,
                      style: TextStyle(
                        color: _messages[index]['sender'] == 'You'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
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
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
