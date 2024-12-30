import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants/constant.dart';

class ClassManagementScreen extends StatefulWidget {
  @override
  _ClassManagementScreenState createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  String? waliKelas;

  // Data kelas yang ada di aplikasi
  final Map<String, List<Map<String, String>>> dataKelas = {
    "Pemasaran 10.3": [
      {"name": "Nau", "phone": "081234567890"},
      {"name": "Nau", "phone": "081234567891"},
      {"name": "Nau", "phone": "081234567892"},
    ],
    "TJKT 10.1": [
      {"name": "Nau", "phone": "081234567893"},
      {"name": "Nau", "phone": "081234567894"},
      {"name": "Nau", "phone": "081234567895"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _getWaliKelas(); // Ambil wali_kelas saat halaman pertama kali dibuka
  }

  Future<void> _getWaliKelas() async {
    final prefs = await SharedPreferences.getInstance();
    final String username = 'username_user'; // Ganti dengan username yang sesuai

    final response = await http.get(
      Uri.parse('http://yourapi.com/api/get-wali-kelas/$username'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        waliKelas = data['wali_kelas'];
        // Simpan wali_kelas ke SharedPreferences
        prefs.setString('wali_kelas', waliKelas!);
      });
    } else {
      // Tampilkan pesan jika wali_kelas tidak ditemukan
      setState(() {
        waliKelas = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kelas'),
        backgroundColor: primaryAccentColor,
      ),
      body: Container(
        color: Colors.white,
        child: waliKelas == null
            ? Center(child: Text('Tidak ada kelas yang ditugaskan sebagai wali kelas'))
            : StudentListPage(kelas: waliKelas!, siswa: dataKelas[waliKelas!]!),
      ),
    );
  }
}

class StudentListPage extends StatelessWidget {
  final String kelas;
  final List<Map<String, String>> siswa;

  const StudentListPage({required this.kelas, required this.siswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Siswa $kelas'),
        backgroundColor: primaryAccentColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ListView.builder(
          itemCount: siswa.length,
          itemBuilder: (context, index) {
            final siswaName = siswa[index]['name']!;
            final noTelp = siswa[index]['phone']!;
            final absen = index + 1;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 5,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/${siswaName.toLowerCase().replaceAll(" ", "_")}_profile.jpg'),
                  radius: 24,
                ),
                title: Row(
                  children: [
                    Text(
                      '$absen. $siswaName',
                      style: TextStyle(color: textPrimaryColor, fontSize: 16),
                    ),
                  ],
                ),
                subtitle: Text(
                  'No Telp: $noTelp',
                  style: TextStyle(color: greyTextColor, fontSize: 14),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
