import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for json decoding
import 'package:asset_management/screen/models/location.dart'; // Ensure this model exists and matches your data structure

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({Key? key}) : super(key: key);

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  MapController? mapController;
  // Example: Monas, Jakarta. Use LatLng from latlong2
  final LatLng _center = const LatLng(-6.1753924, 106.8271528);
  // LatLng for the current center of the map, used for submission
  LatLng _currentMapCenter = const LatLng(-6.1753924, 106.8271528); // Initialize with default

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _personInChargeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitLocation() async {
    if (_formKey.currentState!.validate()) {
      // Hardcoded values for testing (from original file)
      String organizationId = "2";
      String locationPICId = _personInChargeController.text; // Using PIC from form now

      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/add_location.php'), // Your server URL
        body: {
          'organization_id': organizationId,
          'location_name': _locationNameController.text,
          'address': _addressController.text,
          'detail': _detailController.text,
          'locationPIC_id': locationPICId,
          'phone_number': _phoneNumberController.text,
          'latitude': _currentMapCenter.latitude.toString(), // Pass current map center
          'longitude': _currentMapCenter.longitude.toString(), // Pass current map center
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location added successfully!')),
        );
        Navigator.pop(context); // Close the screen after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add location: ${data['message']}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _addressController.dispose();
    _detailController.dispose();
    _personInChargeController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(245,245,245, 245),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95.0), // Height similar to your example
        child: Stack(
          children: [
            // Background image for the AppBar
            Image.asset(
              'assets/bg_image.png', // Ensure this path is correct
              height: 95,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Content of the AppBar (back button and title)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Add location',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250, // Height for the map
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 15.0,
                      onPositionChanged: (position, hasGesture) {
                        // Update the current map center when the map moves
                        if (position.center != null) {
                          setState(() {
                            _currentMapCenter = position.center!;
                          });
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app', // Replace with your package name
                      ),
                    ],
                  ),
                  const Center(
                    // This is the static pin visually in the center
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _locationNameController,
                      labelText: 'Location name',
                      hintText: 'Kantor pusat cakung',
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _addressController,
                      labelText: 'Address',
                      hintText: 'Jl pertiwi 12',
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _detailController,
                      labelText: 'Detail',
                      hintText: 'Disebelah SPBU',
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _personInChargeController,
                      labelText: 'Person in charge',
                      hintText: 'Davin',
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phoneNumberController,
                      labelText: 'Phone number',
                      hintText: '081208120812',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(245, 255, 255, 255),
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Submit',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: '$labelText*',
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}