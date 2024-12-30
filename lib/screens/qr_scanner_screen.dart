import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String scannedData = "Belum ada data";

  @override
  void initState() {
    super.initState();
    scanQRCode(); // Mulai scan QR langsung setelah halaman terbuka
  }

  Future<void> scanQRCode() async {
    try {
      // Mulai scan QR langsung
      var result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        setState(() {
          scannedData = result.rawContent;
        });

        // Kirim data ke API
        sendDataToAPI(scannedData);
      }
    } catch (e) {
      setState(() {
        scannedData = "Error: $e";
      });
    }
  }

  Future<void> sendDataToAPI(String baseUrl) async {
    try {
      // Ambil data siswa dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String name = prefs.getString('name') ?? "Tidak ada nama";
      final String kelas = prefs.getString('kelas') ?? "Tidak ada kelas";
      final String jurusan = prefs.getString('jurusan') ?? "Tidak ada jurusan";
      final String tanggal = DateTime.now().toIso8601String();

      // Buat URL lengkap dengan parameter
      final String url = "$baseUrl?" +
          "name=${Uri.encodeComponent(name)}" +
          "&kelas=${Uri.encodeComponent(kelas)}" +
          "&jurusan=${Uri.encodeComponent(jurusan)}" +
          "&tanggal_absen=$tanggal" +
          "&status_absen=Hadir";

      // Kirim request ke API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          scannedData = "Absensi berhasil untuk $name";
        });
      } else {
        setState(() {
          scannedData = "Gagal mengirim data: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        scannedData = "Error saat mengirim data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scannedData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Kamu bisa menambahkan widget untuk memperjelas kalau kamera sedang scanning
            CircularProgressIndicator(), // Indikator loading selama scan
          ],
        ),
      ),
    );
  }
}
