import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart'; // Impor model Event

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.judul),
        backgroundColor: Color(0xFF212121),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.judul,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              
              // Tanggal event
              Text(
                event.tanggal,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              
              // Gambar event dengan error handling
              event.gambar.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.gambar, // Ganti 'localhost' dengan '10.0.2.2' untuk emulator
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        print('Error loading image: $error');
                        return Center(child: Icon(Icons.broken_image, size: 50));
                      },
                    )
                  : Center(child: Icon(Icons.broken_image, size: 50)),
              SizedBox(height: 20),

              // Deskripsi event
              Text(
                event.isi,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
