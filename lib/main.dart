import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_list_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/discussion_forum_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/news_event_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/teacher/dashboard_guru_screen.dart';

void main() {
  runApp(SekolahApp());
}

class SekolahApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Sekolah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/events': (context) => EventListScreen(),
        '/leaderboard': (context) => LeaderboardScreen(),
        '/scan': (context) => QRScannerScreen(),
        '/splash': (context) => SplashScreen(),
        '/profile': (context) => ProfileScreen(),
        '/chat-history': (context) => ChatHistoryScreen(),
        '/discussion-forum': (context) => DiscussionForumScreen(),

        // Admin dashboard routes
        '/admin/attendance': (context) => AttendanceScreen(),
        '/admin/news-event': (context) => NewsEventScreen(),
      },
    );
  }
}
