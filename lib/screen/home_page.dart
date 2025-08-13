import 'package:asset_management/screen/devices_screen.dart';
import 'package:asset_management/screen/incident.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asset_management/screen/main_screen.dart'; 
import 'package:asset_management/screen/models/user_role.dart'; 

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
  final String organizationName; 

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
  late String _companyEmail;
  @override
  void initState() {
    super.initState();
    _companyEmail = widget.userEmail; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

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
                      const Text("Hi, Welcome", style: TextStyle(fontSize: 22, color: Colors.white)),
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
                              Text(widget.userName, style: const TextStyle(fontSize: 18, color: Colors.white)), 
                              Text(widget.userEmail, style: const TextStyle(color: Colors.white70)), 
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4), 
                _buildCompanyCard(), 
                const SizedBox(height: 15), 

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), 
                  child: Text('Ticketing', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12), 

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
                const SizedBox(height: 12), 

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), 
                  child: Text('Devices', style: TextStyle(fontWeight: FontWeight.bold)), 
                ),
                const SizedBox(height: 12), 

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
                const SizedBox(height: 24), 
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
        color: const Color.fromARGB(255, 255, 255, 255), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
        child: Padding(
          padding: const EdgeInsets.all(16.0), 
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/company.png'),
                  ),
                  const SizedBox(width: 15), 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.organizationName.isEmpty ? 'No Company Name' : widget.organizationName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(_companyEmail, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    DateFormat("dd MMM yyyy").format(DateTime.now()), 
                    style: const TextStyle(fontWeight: FontWeight.bold), 
                  ),
                  const Text("09.00 - 17.00", style: TextStyle(color: Colors.grey)),
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
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4), 
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