import 'package:asset_management/screen/devices_screen.dart';
import 'package:asset_management/screen/incident.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asset_management/screen/main_screen.dart'; // Import MainScreen
import 'package:asset_management/screen/models/user_role.dart'; // Import UserRole enum

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
  final String userName;
  final String userEmail;
  final UserRole userRole;
  final String organizationName; // Parameter for direct passing

  const UserHomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.organizationName,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late String _companyEmail; // Set in initState for consistency

  @override
  void initState() {
    super.initState();
    _companyEmail = widget.userEmail; // Use user's email as fallback; adjust if organization email is available
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
                _buildCompanyCard(), // Uses passed organizationName
                const SizedBox(height: 15), // From NEW UI

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), // From NEW UI
                  child: Text('Ticketing', style: TextStyle(fontWeight: FontWeight.bold)), // From NEW UI
                ),
                const SizedBox(height: 12), // From NEW UI

                _customCard(
                  title: 'Incident',
                  iconPath: 'assets/incident.png',
                  onTap: () {
                    Navigator.push(
                      context,
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

                _customCard(
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
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/company.png'),
                  ),
                  const SizedBox(width: 15), // From NEW UI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.organizationName.isEmpty ? 'No Company Name' : widget.organizationName, // Uses passed organizationName
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(_companyEmail, style: const TextStyle(color: Colors.grey)), // Uses _companyEmail
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
                  const SizedBox(height: 4), // Added a small space
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