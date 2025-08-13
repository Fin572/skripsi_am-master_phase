import 'package:asset_management/screen/super_admin/SA_asset_category_detail_screen.dart';
import 'package:asset_management/screen/super_admin/SA_asset_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:asset_management/screen/models/asset.dart'; 

class SuperAdminDevicesScreen extends StatefulWidget {
  const SuperAdminDevicesScreen({Key? key}) : super(key: key);

  @override
  State<SuperAdminDevicesScreen> createState() => _SADevicesScreenState();
}

class _SADevicesScreenState extends State<SuperAdminDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    final String companyId = '#000001';
    final String companyName = 'PT Dunia Persada';
    final String assetCount = '0 Asset';

    final dummyAsset = Asset(
      id: '#001001',
      name: 'Server Rack A',
      category: 'IT Equipment',
      locationId: '#110000',
      locationInfo: 'Main Office - Server Room',
      latitude: -6.2088, 
      longitude: 106.8456, 
      personInCharge: 'Budi Santoso',
      phoneNumber: '081234567890',
      barcodeData: 'SRACKA001', 
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(245,245,245, 245),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/bg_image.png',
                    height: 95,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Devices',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: CompanyInfoCard(
                          ticketNumber: '#000001',
                          companyName: 'PT Dunia Persada',
                          deviceCount: '0 Asset',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.white, 
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.business, size: 40, color: Colors.grey),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Main Office',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Text(
                                        '#110000',
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 5),
                                      const Row(
                                        children: [
                                          Icon(Icons.laptop_mac, size: 18),
                                          SizedBox(width: 5),
                                          Text('4 Devices', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SAAssetDevicesScreen(asset: dummyAsset),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Text('Detail', style: TextStyle(color: Colors.blue)),
                                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}