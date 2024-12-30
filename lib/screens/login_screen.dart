import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'teacher/dashboard_guru_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Cek status login saat aplikasi dibuka
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      final response = await http.get(
        Uri.parse('https://ilyasa.verdantns.xyz/api/siswa?username=$username'),
      );
      if (response.statusCode == 200) {
        final siswaData = json.decode(response.body);
        if (siswaData['is_admin'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else if (siswaData['is_teacher'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardguruPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://ilyasa.verdantns.xyz/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);

        final siswaResponse = await http.get(
          Uri.parse('https://ilyasa.verdantns.xyz/api/siswa?username=$username'),
        );
        final guruResponse = await http.get(
          Uri.parse('https://ilyasa.verdantns.xyz/api/guru?username=$username'),
        );

        if (siswaResponse.statusCode == 200) {
          final siswaData = json.decode(siswaResponse.body);
          prefs.setString('name', siswaData['name']);
          prefs.setString('jurusan', siswaData['jurusan']);
          prefs.setString('foto_profil', siswaData['foto_profil']);
          prefs.setString('role', siswaData['role']);
          prefs.setBool('is_admin', siswaData['is_admin']);
          prefs.setBool('is_teacher', siswaData['is_teacher']);

          if (siswaData['is_admin'] == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (siswaData['is_teacher'] == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardguruPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } else if (guruResponse.statusCode == 200) {
          final guruData = json.decode(guruResponse.body);
          prefs.setString('name', guruData['name']);
          prefs.setString('wali_kelas', guruData['wali_kelas']);
          prefs.setString('foto_profil', guruData['foto_profil']);
          prefs.setString('jenis_kelamin', guruData['jenis_kelamin']);
          prefs.setString('role', 'guru');
          prefs.setBool('is_teacher', true);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardguruPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          _showErrorDialog("Data Tidak Ditemukan", "Akun tidak terdaftar sebagai siswa atau guru.");
        }
      } else {
        _showErrorDialog("Login Gagal", "Username atau password salah.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
      _showErrorDialog("Terjadi Kesalahan", "Terjadi kesalahan saat login, coba lagi.");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: Colors.redAccent)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black87,
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/logo.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Selamat Datang di Aplikasi Sekolah",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Silakan masuk untuk melanjutkan",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        _buildTextField(_usernameController, "Username", Icons.person),
                        SizedBox(height: 20),
                        _buildPasswordTextField(),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            backgroundColor: Colors.greenAccent,
                            elevation: 5,
                            shadowColor: Colors.black45,
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "© 2024 SMKN 1 KOTA TANGERANG",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoadingAnimation(),
                      SizedBox(height: 20),
                      Text(
                        "Sedang memuat... Mohon tunggu",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black45,
        labelText: label,
        labelStyle: TextStyle(color: Colors.greenAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.greenAccent),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black45,
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.greenAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.greenAccent),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.greenAccent,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = Tween<double>(begin: 1.0, end: 1.5).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0 + index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
              ),
            );
            final translate = Tween<double>(begin: 0.0, end: -10.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0 + index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
              ),
            );
            return Transform.translate(
              offset: Offset(0, translate.value),
              child: Transform.scale(
                scale: scale.value,
                child: Container(
                  width: 15,
                  height: 15,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}