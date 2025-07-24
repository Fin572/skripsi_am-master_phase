import 'package:asset_management/screen/auth_screen.dart';
import 'package:asset_management/screen/models/user_role.dart'; // Import UserRole
import 'package:flutter/material.dart';

// Dummy AuthService for illustration (preserved from original profile.dart)
class AuthService {
  static Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate logout delay
  }
}

// showComingSoonPopup function (preserved from original profile.dart)
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

class UserProfile extends StatefulWidget {
  // Fields to store the passed data (from user_profile NEW UI.dart)
  final String userName;
  final String userEmail;
  final UserRole userRole;

  // Constructor to receive the data (from user_profile NEW UI.dart)
  const UserProfile({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState(); // Renamed state class
}

class _UserProfileState extends State<UserProfile> { // Renamed state class
  bool isAvailable = true; // Preserved from original profile.dart

  // _handleLogout function (preserved from original profile.dart)
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
              // Perform actual logout logic here if any before navigating
              AuthService.logout().then((_) { // Simulate backend logout
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()), // Navigate to AuthScreen
                  (route) => false, // remove all previous routes
                );
              });
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the consistent AppBar height (from user_profile NEW UI.dart)
    const double consistentAppBarHeight = 100.0; // Standard height for image app bars

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Background image that covers the entire PreferredSize area
            Image.asset(
              'assets/bg_image.png', // From user_profile NEW UI.dart
              height: consistentAppBarHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Center( // Centered title as in NEW UI
                  child: const Text(
                    "Profile", // From user_profile NEW UI.dart
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(245,245,245, 245), // From user_profile NEW UI.dart
      body: Column(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // From original profile.dart
              padding: const EdgeInsets.all(16.0), // From original profile.dart
              margin: const EdgeInsets.all(16.0), // From original profile.dart
              decoration: BoxDecoration(
                color: Colors.white, // From user_profile NEW UI.dart
                borderRadius: BorderRadius.circular(10), // From original profile.dart
                border: Border.all(color: Colors.grey.shade300), // From original profile.dart
              ),
              child: Column(
                children: [
                  const CircleAvatar( // From original profile.dart
                    radius: 40,
                    backgroundImage: AssetImage("assets/profile.png"),
                  ),
                  const SizedBox(height: 10), // From original profile.dart
                  // Use the passed data (from user_profile NEW UI.dart)
                  Text(
                    widget.userName, // Access the data from the widget property
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.userEmail, // Access the data from the widget property
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business), // From original profile.dart
            title: const Text("PT Dunia Persada"), // From original profile.dart
            onTap: () => showComingSoonPopup(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_box), // From original profile.dart
            title: const Text("#00001"), // From original profile.dart
            onTap: () => showComingSoonPopup(context),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind_rounded), // From original profile.dart
            title: Text(widget.userRole.name), // Display the user's role (from user_profile NEW UI.dart)
            onTap: () => showComingSoonPopup(context),
          ),
          const Spacer(), // From original profile.dart
          Padding(
            padding: const EdgeInsets.all(16.0), // From original profile.dart
            child: SizedBox(
              width: double.infinity, // From original profile.dart
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // From original profile.dart
                  padding: const EdgeInsets.symmetric(vertical: 16), // From original profile.dart
                ),
                onPressed: () => _handleLogout(context), // Uses the _handleLogout function defined in this class
                child: const Text(
                  "Log Out", // From original profile.dart
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), // From original profile.dart
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}