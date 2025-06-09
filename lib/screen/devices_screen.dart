import 'package:asset_management/screen/asset_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:asset_management/screen/add_location_screen.dart';
import 'package:asset_management/screen/models/location.dart'; 
import 'package:asset_management/widgets/company_info_card.dart'; 

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Map<String, dynamic>> _locations = []; // List to store fetched locations
  bool _isLoading = true; // To manage loading state
  bool _showSuccessPopup = false;

  // This method will fetch locations from the database
  Future<void> _fetchLocations() async {
    final response = await http.get(Uri.parse('http://192.168.1.9/Skripsi/get_location.php')); // Changed IP to 192.168.1.10

    print('Location API Response status: ${response.statusCode}');
    print('Location API Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Parsed location data: $data');
      if (data['status'] == 'success') {
        setState(() {
          _locations = List<Map<String, dynamic>>.from(data['locations']);
          print('Fetched locations: $_locations'); // Added debug log
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch locations: ${data['message']}')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching locations: ${response.statusCode}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations when the page loads
  }

  // Method to navigate to Add Location page
  void _addLocation() async {
    final newLocation = await Navigator.push<Location>(
      context,
      MaterialPageRoute(builder: (context) => const AddLocationScreen()),
    );

    if (newLocation != null) {
      setState(() {
        // You can add new location to the list here if needed
        _showSuccessPopup = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessPopup = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String companyId = '#000001';
    final String companyName = 'PT Dunia Persada';
    final String assetCount = '0 Asset';

    return Scaffold(
      backgroundColor: Colors.grey[100],
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

                      // Custom widget for company info
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: CompanyInfoCard(
                          ticketNumber: '#000001',
                          companyName: 'PT Dunia Persada',
                          deviceCount: '0 Asset',
                        ),
                      ),

                      // Display locations fetched from server
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: _locations.map((location) {
                            print('Rendering location: $location'); // Added debug log
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
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
                                          Text(
                                            location['location_name']?.toString() ?? 'Unknown', // Added toString() for safety
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            '#${location['location_id']?.toString() ?? 'Unknown'}', // Added toString() for safety
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: const [
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
                                            builder: (context) => const AssetDevicesScreen(showSuccessPopup: true),
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
                            );
                          }).toList(),
                        ),
                      ),

                      // Show no data if no locations found
                      if (_locations.isEmpty && !_isLoading)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/nodata.png', width: 100),
                                const SizedBox(height: 20),
                                const Text(
                                  "No data available",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
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

          // Floating add location button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                onPressed: _addLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Add location',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          // Success popup
          if (_showSuccessPopup)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: SafeArea(
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Success! Location has been added',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}