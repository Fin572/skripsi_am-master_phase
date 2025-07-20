import 'package:asset_management/screen/incident_ticket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for json decoding
import 'main_screen.dart';
import 'incident.dart'; // Example import for navigating to Incident screen
import 'devices_screen.dart'; // Example import for navigating to Devices screen
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

void showComingSoonPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Coming Soon"),
      content: const Text("Fitur ini sedang dalam pengembangan."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Tutup"),
        ),
      ],
    ),
  );
}

class HomePage extends StatefulWidget {
  final String username;
  final String password;

  HomePage({required this.username, required this.password});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String organizationName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'login': widget.username,
          'password': widget.password,
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Data: $data');

        if (data['status'] == 'success' && data.containsKey('organization_name')) {
          setState(() {
            organizationName = data['organization_name'];
          });
        } else {
          print('Login failed: ${data['message'] ?? 'No message provided'}');
          setState(() {
            organizationName = "Error: ${data['message'] ?? 'Unknown error'}";
          });
        }
      } else {
        print('HTTP Error: Status code ${response.statusCode}');
        setState(() {
          organizationName = "Error: HTTP ${response.statusCode}";
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        organizationName = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Scrollable foreground content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hi, Welcome",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage("assets/profile.png"),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "user@user.com",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                _buildCompanyCard(organizationName),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ticketing',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                _customCard(
                  title: 'Incident',
                  subtitle: 'Lorem ipsum',
                  iconPath: 'assets/incident.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Incident()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Devices',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                _customCard(
                  title: 'Devices',
                  subtitle: 'Lorem ipsum',
                  iconPath: 'assets/Devices.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DevicesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(String organizationName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/company.png'),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizationName.isEmpty || organizationName == 'Loading...' ? 'No Company Name' : organizationName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "user@user.com",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    DateFormat("dd MMM yyyy").format(DateTime.now()),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("09.00 - 17.00", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customCard({
    required String title,
    required String subtitle,
    String? iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (iconPath != null)
              SizedBox(
                height: 48,
                width: 48,
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}