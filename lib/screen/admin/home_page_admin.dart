import 'package:asset_management/screen/devices_screen.dart';
import 'package:asset_management/screen/admin/incident.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Container(
            height: MediaQuery.of(context).size.height * 0.33, // ~3/4 height of visible top area
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
                            children: const [
                              Text("Admin", style: TextStyle(fontSize: 18, color: Colors.white)),
                              Text("Admin@Admin.com", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                _buildCompanyCard(), // overlay
                const SizedBox(height: 15),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Ticketing', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),

                _customCard(
                  title: 'Incident',
                  subtitle: 'Lorem ipsum',
                  iconPath: 'assets/incident.png',
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminIncidentScreen()),
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
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/company.png'),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PT. Dunia Persada", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Admin@Admin.com", style: TextStyle(color: Colors.grey)),
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
