import 'package:asset_management/screen/auth_screen.dart';
import 'package:flutter/material.dart';

// Dummy AuthService for illustration
class AuthService {
  static Future<void> logout() async {
    await Future.delayed(Duration(seconds: 1)); // simulate logout delay
  }
}

class ProfilePage extends StatefulWidget {
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
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Tutup"),
        ),
      ],
    ),
  );
}

class _ProfilePageState extends State<ProfilePage> {
  bool isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("Profile",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        flexibleSpace: Image(
          image: AssetImage('assets/bg_image.png'),
          fit: BoxFit.fill,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/profile.png"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "user",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "user@user.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: Text("PT Dunia Persada"),
            onTap: () => showComingSoonPopup(context),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text("#00001"),
            onTap: () => showComingSoonPopup(context),
          ),
          ListTile(
            leading: Icon(Icons.assignment_ind_rounded),
            title: Text("Customer"),
            onTap: () => showComingSoonPopup(context),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _handleLogout(context),
                child: Text("Log Out",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
      title: Text("Confirm Logout"),
      content: Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(), // close dialog
          child: Text("Cancel"),
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
          child: Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

