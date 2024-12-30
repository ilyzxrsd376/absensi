import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../constants/constant.dart';
import 'schedule_page.dart';
import 'material_page.dart';
import '../attendance_screen.dart';
import 'download_rekap_screen.dart';
import '../login_screen.dart'; 

class DashboardguruPage extends StatefulWidget {
  @override
  _DashboardguruPageState createState() => _DashboardguruPageState();
}

class _DashboardguruPageState extends State<DashboardguruPage> {
  String greeting = "Selamat Datang, Guru!";
  String name = "Loading...";  // Menampung nama guru
  String gender = "";  // Menampung jenis kelamin guru
  String? waliKelas;  // Menampung status wali kelas

  @override
  void initState() {
    super.initState();
    _getGuruData(); // Ambil data guru ketika halaman dibuka
  }

  Future<void> _getGuruData() async {
  final prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');  // Ambil username dari SharedPreferences
  String? storedName = prefs.getString('name');  // Ambil nama dari SharedPreferences
  String? storedGender = prefs.getString('jenis_kelamin');  // Ambil jenis kelamin dari SharedPreferences
  String? storedWaliKelas = prefs.getString('wali_kelas');  // Ambil status wali kelas dari SharedPreferences

  if (storedName != null && storedGender != null) {
    setState(() {
      name = storedName;  // Ambil nama dari SharedPreferences
      gender = storedGender;  // Ambil jenis kelamin dari SharedPreferences
      waliKelas = storedWaliKelas;  // Ambil status wali kelas dari SharedPreferences

      // Tentukan sapaan berdasarkan jenis kelamin
      if (gender == 'laki-laki') {
        greeting = "Selamat Datang, Pak $name!";
      } else if (gender == 'perempuan') {
        greeting = "Selamat Datang, Bu $name!";
      } else {
        greeting = "Selamat Datang, $name!";
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        backgroundColor: sidebarBackgroundColor,
      ),
      drawer: _buildSidebar(context),
      body: Container(
        color: primaryBackgroundColor,
        child: Padding(
          padding: globalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting, // Menampilkan sapaan sesuai dengan jenis kelamin
                style: titleTextStyle,
              ),
              const SizedBox(height: 16),
              Expanded(
  child: GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    children: [
      _buildDashboardTile(
        context,
        title: 'Kelola Materi',
        icon: Icons.book,
        color: primaryAccentColor,
        page: MaterialScreen(),
      ),
      _buildDashboardTile(
        context,
        title: 'Jadwal Mengajar',
        icon: Icons.schedule,
        color: quizMenuItemColor,
        page: SchedulePage(),
      ),
      // Hanya tampilkan Manajemen Kelas jika waliKelas tidak null
      // Hanya tampilkan Rekap Presensi jika waliKelas tidak null
      if (waliKelas != null && waliKelas!.isNotEmpty)
        _buildDashboardTile(
          context,
          title: 'Rekap Presensi',
          icon: Icons.list_alt,
          color: leaderboardMenuItemColor,
          page: AttendanceScreen(),
        ),
      // Hanya tampilkan Unduh Rekap Absensi jika waliKelas tidak null
      if (waliKelas != null && waliKelas!.isNotEmpty)
        _buildDashboardTile(
          context,
          title: 'Unduh Rekap Absensi',
          icon: Icons.download,
          color: textPrimaryColor,
          page: DownloadRekapScreen(),
        ),
    ],
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: sidebarBackgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: profileAvatarBackgroundColor,
                  child: Icon(Icons.person, size: 40, color: profileAvatarIconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  name,  // Menggunakan variabel name
                  style: TextStyle(fontSize: 18, color: sidebarTextColor),
                ),
              ],
            ),
          ),
          ListTile(
  leading: Icon(Icons.dashboard, color: sidebarIconColor),
  title: const Text('Dashboard', style: TextStyle(color: textPrimaryColor)),
  onTap: () {
    Navigator.pop(context);
  },
),
ListTile(
  leading: Icon(Icons.book, color: primaryAccentColor),
  title: const Text('Kelola Materi', style: TextStyle(color: textPrimaryColor)),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialScreen()));
  },
),
ListTile(
  leading: Icon(Icons.schedule, color: quizMenuItemColor),
  title: const Text('Jadwal Mengajar', style: TextStyle(color: textPrimaryColor)),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SchedulePage()));
  },
),
// Menampilkan item lain sesuai kondisi
if (waliKelas != null && waliKelas!.isNotEmpty)
  ListTile(
    leading: Icon(Icons.list_alt, color: leaderboardMenuItemColor),
    title: const Text('Rekap Presensi', style: TextStyle(color: textPrimaryColor)),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen()));
    },
  ),
if (waliKelas != null && waliKelas!.isNotEmpty)
  ListTile(
    leading: Icon(Icons.download, color: textPrimaryColor),
    title: const Text('Unduh Rekap Absensi', style: TextStyle(color: textPrimaryColor)),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadRekapScreen()));
    },
  ),
  ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              _logout(context); // Panggil fungsi logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context,
      {required String title, required IconData icon, required Color color, required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 5,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: tileTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    // Menghapus data sesi/token menggunakan SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data yang tersimpan

    // Navigasi kembali ke halaman login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()), // Ganti LoginScreen dengan halaman login Anda
      (route) => false, // Hapus semua rute sebelumnya
    );
  }
}