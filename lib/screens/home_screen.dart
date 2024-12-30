import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'event_list_screen.dart';
import 'leaderboard_screen.dart';
import 'mini_game_screen.dart';
import 'event_detail_screen.dart';
import 'attendance_screen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _sliderTimer;
  String username = "Loading...";
  String profileImageUrl =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
  bool isSecretary = false;

  List<Event> events = [];
  String role = "siswa";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchUsername();
    _fetchEvents();
  }

  Future<void> _fetchUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usernameToFetch = prefs.getString('username');

    if (usernameToFetch == null) {
      setState(() {
        username = "No user logged in";
      });
      return;
    }

    final url = Uri.parse('https://ilyasa.verdantns.xyz/api/siswa?username=$usernameToFetch');
    try {
      final response = await http.get(url);

      // Debugging: Print response body untuk memastikan apakah itu JSON atau HTML
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Cek respons yang diterima

      // Cek apakah respons berupa HTML (misalnya jika mengandung tag <html>)
      if (response.body.contains("<html>")) {
        setState(() {
          username = "Received HTML instead of JSON. Likely an error page.";
        });
        print("Error: HTML response received");
      } else if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          setState(() {
            username = data['name'] ?? data['username'] ?? "Unknown User";
            profileImageUrl = data['foto_profil'] ?? 
                "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";

            role = data['role'] ?? 'siswa';
            isSecretary = (data['is_secretary'] ?? false) is bool
                ? data['is_secretary']
                : (data['is_secretary'] == 1); // Konversi integer ke bool
          });

          print('isSecretary: $isSecretary');
        } catch (e) {
          setState(() {
            username = "Invalid response format";
          });
          print("Error decoding response: $e");
        }
      } else {
        setState(() {
          username = "Failed to fetch user. Status code: ${response.statusCode}";
        });
        print("Failed to fetch user: ${response.body}");
      }
    } catch (e) {
      setState(() {
        username = "Error fetching user: $e";
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchEvents() async {
    final url = Uri.parse('https://ilyasa.verdantns.xyz/api/events');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          events = data.map<Event>((event) => Event.fromJson(event)).toList();
        });
        _startSlider();
      } else {
        print("Failed to fetch events: ${response.statusCode}, body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  void _startSlider() {
    _sliderTimer = Timer.periodic(Duration(seconds: 6), (Timer timer) {
      if (events.isNotEmpty) {
        if (_currentPage < events.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF212121),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Color(0xFF1D1F24),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildEventSlider(),
            SizedBox(height: 20),
            _buildMenuBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back", style: TextStyle(fontSize: 16, color: Colors.grey[500])),
            Text(
              username,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: CircleAvatar(
            backgroundColor: Color(0xFF607D8B),
            radius: 25,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildEventSlider() {
    if (events.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Color(0xFF37474F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.gambar,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMenuItem("QR Absence", Icons.qr_code_scanner, Color(0xFF1565C0), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen()));
        }),
        if (isSecretary)
          _buildMenuItem("Absence List", Icons.list, Color(0xFF4CAF50), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AttendanceScreen()),
            );
          }),
        _buildMenuItem("School Events", Icons.event, Color(0xFFAB47BC), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EventListScreen()));
        }),
        _buildMenuItem("Leaderboard", Icons.leaderboard, Color(0xFFFF7043), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderboardScreen()));
        }),
        _buildMenuItem("Mini Game", Icons.quiz, Color(0xFF66BB6A), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MiniGameScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
