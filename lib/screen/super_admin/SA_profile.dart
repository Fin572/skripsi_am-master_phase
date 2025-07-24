// SA_profile.dart
import 'package:asset_management/screen/auth_screen.dart';
import 'package:asset_management/screen/models/user_role.dart';
import 'package:flutter/material.dart';

// Dummy AuthService for illustration
class AuthService {
  static Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate logout delay
  }
}

class SuperAdminProfile extends StatefulWidget {
  final String userName;
  final String userEmail;
  final UserRole userRole;

  const SuperAdminProfile({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

void showComingSoonPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Coming Soon"),
      content: const Text("Fitur ini sedang dalam pengembangan."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(), // close dialog
          child: const Text("Tutup"),
        ),
      ],
    ),
  );
}

class _ProfilePageState extends State<SuperAdminProfile> {
  bool isAvailable = true; // This variable is not used in the current UI, can be removed if not for future use.

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0; // Standard height for image app bars

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Background image that covers the entire PreferredSize area
            Image.asset(
              'assets/bg_image.png',
              height: consistentAppBarHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Center(
                  child: const Text(
                    "Profile",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/profile.png"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("PT Dunia Persada"),
            onTap: () => showComingSoonPopup(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text("#00001"),
            onTap: () => showComingSoonPopup(context),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind_rounded),
            title: Text(widget.userRole.name),
            onTap: () => showComingSoonPopup(context),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _handleLogout(context),
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _handleLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(), // close dialog
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(); // close dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AuthScreen()),
              (route) => false, // remove all previous routes
            );
          },
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}