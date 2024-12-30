import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'event_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image
import '../models/event.dart';  // Mengimpor Event dari folder models

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> events;

  @override
  void initState() {
    super.initState();
    events = fetchEvents();
  }

  // Fetch data from API
  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('https://ilyasa.verdantns.xyz/api/events'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1F24),
      appBar: AppBar(
        title: Text(
          "Daftar Event",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Color(0xFF1E1E1E),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Event>>(
        future: events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available.'));
          } else {
            final eventList = snapshot.data!;
            return ListView.builder(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                final event = eventList[index];
                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: event.gambar.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: event.gambar, // URL gambar dari API
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        )
                      : Icon(Icons.image_not_supported, size: 50),
                  title: Text(event.judul),
                  subtitle: Text(event.tanggal),
                  onTap: () {
                    // Mengirimkan objek Event ke EventDetailScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
