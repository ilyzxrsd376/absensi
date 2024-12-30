import 'package:flutter/material.dart';
import 'chat_history_screen.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String username = "@Loading...";
  String profileImageUrl =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
  String jurusan = "Loading...";  // Menambahkan jurusan

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? usernameToFetch = prefs.getString('username');
  String? jurusanFromPrefs = prefs.getString('jurusan');  // Mengambil jurusan dari SharedPreferences

  if (usernameToFetch == null) {
    setState(() {
      name = "No user logged in";
      username = "@NotAvailable";
      jurusan = "Jurusan tidak tersedia";  // Menampilkan jurusan default jika tidak ada
    });
    return;
  }

  final url = Uri.parse('https://ilyasa.verdantns.xyz/api/siswa?username=$usernameToFetch');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        name = data['name'] ?? "Name not found";
        username = '@${data['username'] ?? "Username not found"}';
        profileImageUrl = data['foto_profil'] ?? profileImageUrl;
        jurusan = data['jurusan'] ?? jurusanFromPrefs ?? "Jurusan tidak ditemukan";  // Mengambil jurusan dari API atau SharedPreferences
        nameController.text = name;
        usernameController.text = data['username'] ?? "";
      });
    } else {
      setState(() {
        name = "Siswa not found";
        username = "@NotAvailable";
        jurusan = "Jurusan tidak ditemukan";  // Menampilkan pesan jika gagal mengambil data
      });
    }
  } catch (e) {
    setState(() {
      name = "Error fetching user";
      username = "@Error";
      jurusan = "Error fetching jurusan";
    });
  }
}

  Future<void> _updateProfile() async {
    String name = nameController.text.trim();
    String username = usernameController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name and Username cannot be empty")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token not found. Please login again.")),
      );
      return;
    }

    final url = Uri.parse('https://ilyasa.verdantns.xyz/api/profile/update');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated: ${data['message']}')),
      );
      setState(() {
        this.name = name;
        this.username = username;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF121212),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFF181818),
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                username,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Jurusan: $jurusan',  // Menampilkan jurusan di sini
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey[600]),
            SizedBox(height: 16),
            _buildExpandableSection(
              context: context,
              title: "Pengaturan Notifikasi",
              leadingIcon: Icons.notifications,
              children: [
                _buildSwitchListTile("Terima Notifikasi", true),
                _buildSwitchListTile("Notifikasi Email", true),
              ],
            ),
            _buildExpandableSection(
              context: context,
              title: "Ubah Kata Sandi",
              leadingIcon: Icons.lock,
              children: [
                _buildPasswordField("Kata Sandi Lama"),
                _buildPasswordField("Kata Sandi Baru"),
                _buildPasswordField("Konfirmasi Kata Sandi Baru"),
                _buildActionButtons(context),
              ],
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.white),
              title: Text("Riwayat Chat", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text("Keluar", style: TextStyle(color: Colors.white)),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required BuildContext context,
    required String title,
    required IconData leadingIcon,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(leadingIcon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      backgroundColor: Color(0xFF2A2E35),
      children: children,
    );
  }

  Widget _buildPasswordField(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchListTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      value: value,
      onChanged: (bool value) {},
      activeTrackColor: Colors.blueAccent,
      activeColor: Colors.white,
      inactiveTrackColor: Colors.grey[800],
      inactiveThumbColor: Colors.grey[600],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Batal", style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement save functionality here
          },
          child: Text("Simpan"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A73E8),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Keluar',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF2A2E35),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear all saved data

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text("Keluar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        );
      },
    );
  }
}
