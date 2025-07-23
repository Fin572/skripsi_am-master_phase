// SA_home_page.dart

import 'package:asset_management/screen/admin/admin_incident.dart';
import 'package:asset_management/screen/devices_screen.dart';
import 'package:asset_management/screen/super_admin/SA_add_org.dart';
import 'package:asset_management/screen/super_admin/SA_incident.dart';
import 'package:asset_management/screen/super_admin/SA_register.dart';
import 'package:asset_management/screen/super_admin/SA_user_list_screen.dart'; // Added import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asset_management/screen/models/user_role.dart';

import '../../widgets/comingsoon.dart'; // Ensure this path is correct if not directly used

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

class SuperAdminHomePage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final UserRole userRole;

  const SuperAdminHomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

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
                              Text(userName, style: const TextStyle(fontSize: 18, color: Colors.white)),
                              Text(userEmail, style: const TextStyle(color: Colors.white70)),
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
                  subtitle: '', // Passed empty subtitle
                  iconPath: 'assets/incident.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SAIncidentScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Devices & Organization', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                _customCard(
                  title: 'Devices & Organization',
                  subtitle: '', // Passed empty subtitle
                  iconPath: 'assets/Devices.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuperAdminAddOrganization()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                _customCard(
                  title: 'Register',
                  subtitle: '', // Passed empty subtitle
                  icon: Icons.person_add_alt_1, // Used IconData directly
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuperAdminRegister(_organizations: [],)), // Updated to match NEW UI parameter
                    );
                  },
                ),
                const SizedBox(height: 24),
                _customCard(
                  title: 'User List',
                  subtitle: '', // Passed empty subtitle
                  icon: Icons.person, // Used IconData directly
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SAUserListScreen()), // Directly navigate as per NEW UI
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
                      const Text("PT. Dunia Persada", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(userEmail, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    DateFormat("dd MMM").format(DateTime.now()),
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
    required String subtitle,
    String? iconPath,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    // Add an assertion to ensure either iconPath or icon (but not both) is provided
    assert(iconPath != null || icon != null, 'Either iconPath or icon must be provided to _customCard.');
    assert(!(iconPath != null && icon != null), 'Cannot provide both iconPath and icon to _customCard. Choose one.');

    Widget? iconWidget;
    if (iconPath != null) {
      iconWidget = SizedBox(
        height: 48,
        width: 48,
        child: Image.asset(iconPath, fit: BoxFit.contain),
      );
    } else if (icon != null) {
      iconWidget = Icon(icon, size: 48);
    }

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
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (iconWidget != null) iconWidget,
          ],
        ),
      ),
    );
  }
}