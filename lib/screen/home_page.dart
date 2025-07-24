import 'package:asset_management/screen/devices_screen.dart';
import 'package:asset_management/screen/incident.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asset_management/screen/main_screen.dart'; // Import MainScreen
import 'package:asset_management/screen/models/user_role.dart'; // Import UserRole enum
import 'package:http/http.dart' as http; // For backend interaction
import 'dart:convert'; // For json decoding


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

class UserHomePage extends StatefulWidget {
  // 1. Declare final fields to store the passed data
  final String userName;
  final String userEmail;
  final UserRole userRole; // Add this
  // Removed password from here as it's not ideal to pass directly to HomePage for fetching.
  // Instead, the fetchUserData will rely on the initially passed userName (login)
  // or you'd fetch user data based on authenticated session/token.
  // For now, I'll keep the original logic as close as possible using userName as 'login'.

  // 2. Add a constructor to receive the data
  const UserHomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String organizationName = "Loading..."; // From original home_page.dart
  // Added userEmail as a state variable for use in _buildCompanyCard for consistency
  String _companyEmail = "user@user.com";

  @override
  void initState() {
    super.initState();
    // Assuming 'login' in your API is equivalent to userName here
    _fetchUserData(widget.userName); // Use widget.userName for fetching
  }

  // Merged fetchUserData from original home_page.dart
  Future<void> _fetchUserData(String loginUsername) async {
    try {
      // In a real app, you would not send password again here.
      // You'd typically use a token or session.
      // But adhering to the original file's logic for now.
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'login': loginUsername,
          // If you have a password from login, you could pass it,
          // but for security, usually, you don't re-send it.
          // Assuming the API allows fetching org name by login only after initial auth.
          'password': 'any_password', // Placeholder, ideally remove or use secure token
        },
      );

      print('Response Status (UserHomePage fetchUserData): ${response.statusCode}');
      print('Response Body (UserHomePage fetchUserData): ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Data (UserHomePage fetchUserData): $data');

        if (data['status'] == 'success' && data.containsKey('organization_name')) {
          setState(() {
            organizationName = data['organization_name'];
            _companyEmail = data['email'] ?? widget.userEmail; // Update company email if provided
          });
        } else {
          print('Fetch user data failed: ${data['message'] ?? 'No message provided'}');
          setState(() {
            organizationName = "Error: ${data['message'] ?? 'Unknown error'}";
          });
        }
      } else {
        print('HTTP Error (UserHomePage fetchUserData): Status code ${response.statusCode}');
        setState(() {
          organizationName = "Error: HTTP ${response.statusCode}";
        });
      }
    } catch (e) {
      print('Exception (UserHomePage fetchUserData): $e');
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
                const SizedBox(height: 60), // From NEW UI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16), // From NEW UI
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hi, Welcome", style: TextStyle(fontSize: 22, color: Colors.white)), // From NEW UI
                      const SizedBox(height: 16), // From NEW UI
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage("assets/profile.png"),
                          ),
                          const SizedBox(width: 10), // From NEW UI
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.userName, style: const TextStyle(fontSize: 18, color: Colors.white)), // Uses widget.userName
                              Text(widget.userEmail, style: const TextStyle(color: Colors.white70)), // Uses widget.userEmail
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4), // From NEW UI
                _buildCompanyCard(), // Now calls the updated method
                const SizedBox(height: 15), // From NEW UI

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), // From NEW UI
                  child: Text('Ticketing', style: TextStyle(fontWeight: FontWeight.bold)), // From NEW UI
                ),
                const SizedBox(height: 12), // From NEW UI

                _customCard( // Uses the updated _customCard
                  title: 'Incident',
                  iconPath: 'assets/incident.png',
                  onTap: (){
                    Navigator.push(
                      context,
                      // For customer, it's the base Incident screen
                      MaterialPageRoute(builder: (context) => const Incident(isAdmin: false)),
                    );
                  },
                ),
                const SizedBox(height: 12), // From NEW UI

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), // From NEW UI
                  child: Text('Devices', style: TextStyle(fontWeight: FontWeight.bold)), // From NEW UI
                ),
                const SizedBox(height: 12), // From NEW UI

                _customCard( // Uses the updated _customCard
                  title: 'Devices',
                  iconPath: 'assets/Devices.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DevicesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24), // From NEW UI
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildCompanyCard to match NEW UI and use fetched data
  Widget _buildCompanyCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255), // From NEW UI
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // From NEW UI
        child: Padding(
          padding: const EdgeInsets.all(16.0), // From NEW UI
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar( // From NEW UI
                    radius: 25,
                    backgroundImage: AssetImage('assets/company.png'),
                  ),
                  const SizedBox(width: 15), // From NEW UI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizationName.isEmpty || organizationName == 'Loading...' ? 'No Company Name' : organizationName, // Uses fetched organizationName
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // From NEW UI
                      Text(_companyEmail, style: const TextStyle(color: Colors.grey)), // Uses updated _companyEmail
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20), // From NEW UI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // From NEW UI
                children: [
                  Text(
                    DateFormat("dd MMM yyyy").format(DateTime.now()), // From NEW UI
                    style: const TextStyle(fontWeight: FontWeight.bold), // From NEW UI
                  ),
                  const Text("09.00 - 17.00", style: TextStyle(color: Colors.grey)), // From NEW UI
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated _customCard to match NEW UI (removed subtitle)
  Widget _customCard({
    required String title,
    String? iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16), // From NEW UI
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // From NEW UI
        decoration: BoxDecoration(
          color: Colors.white, // From NEW UI
          borderRadius: BorderRadius.circular(16), // From NEW UI
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300, // From NEW UI
              blurRadius: 6, // From NEW UI
              offset: const Offset(0, 2), // From NEW UI
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // From NEW UI
                  // Subtitle removed as per NEW UI design for this card
                  const SizedBox(height: 4), // Added a small space even if subtitle is gone
                ],
              ),
            ),
            if (iconPath != null)
              SizedBox(
                height: 48, // From NEW UI
                width: 48, // From NEW UI
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}