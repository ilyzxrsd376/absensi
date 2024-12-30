import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaderboard',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.yellow,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[300]),
        ),
      ),
      home: LeaderboardScreen(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<dynamic>> leaderboardData;

  @override
  void initState() {
    super.initState();
    leaderboardData = fetchLeaderboardData();
  }

  Future<List<dynamic>> fetchLeaderboardData() async {
    final response = await http.get(Uri.parse('https://ilyasa.verdantns.xyz/api/leaderboard'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leaderboard data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Leaderboard", style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.yellow,
            tabs: [
              Tab(text: 'Profile', icon: Icon(Icons.person, color: Colors.white)),
              Tab(text: 'Points', icon: Icon(Icons.score, color: Colors.white)),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: leaderboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.yellow));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No Data Available', style: TextStyle(color: Colors.white)));
            }

            final data = snapshot.data!;
            return TabBarView(
              children: [
                _buildProfileLeaderboard(data),
                _buildPointsLeaderboard(data),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileLeaderboard(List<dynamic> data) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final user = data[index];
        return Card(
          color: Color(0xFF333333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                user['foto_profil'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png', // Fallback image
              ),
              onBackgroundImageError: (_, __) {
                // Handle error if image is not valid
              },
            ),
            title: Text(user['name'], style: TextStyle(color: Colors.white)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Class: ${user['kelas']}", style: TextStyle(color: Colors.grey[400])),
                Text("Level: ${user['progress_level']}", style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsLeaderboard(List<dynamic> data) {
    // Sort the data by points in descending order
    data.sort((a, b) => b['points'].compareTo(a['points']));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final user = data[index];
        return Card(
          color: Color(0xFF333333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                user['foto_profil'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png', // Fallback image
              ),
              onBackgroundImageError: (_, __) {
                // Handle error if image is not valid
              },
            ),
            title: Text(user['name'], style: TextStyle(color: Colors.white)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Class: ${user['kelas']}", style: TextStyle(color: Colors.grey[400])),
                Text("Points: ${user['points']}", style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        );
      },
    );
  }
}
