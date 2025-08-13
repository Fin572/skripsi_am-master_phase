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
  List<Map<String, dynamic>> _locations = []; 
  bool _isLoading = true; 
  bool _showSuccessPopup = false;
  bool _isEditing = false; 
  Set<String> _selectedLocationIds = {}; 

  final String _organizationId = "1"; 

  Future<void> _fetchLocations() async {
    setState(() {
      _isLoading = true;
      _locations.clear(); 
      _selectedLocationIds.clear(); 
    });
    final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/get_location.php'));

    print('Location API Response status: ${response.statusCode}');
    print('Location API Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Parsed location data: $data');
      if (data['status'] == 'success') {
        setState(() {
          _locations = List<Map<String, dynamic>>.from(data['locations']);
          print('Fetched locations: $_locations');
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

  Future<void> _deleteLocations() async {
    if (_selectedLocationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No locations selected for deletion.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${_selectedLocationIds.length} selected location(s)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); 
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _locations.removeWhere((location) => _selectedLocationIds.contains(location['location_id'].toString()));
        _selectedLocationIds.clear();
        if (_locations.isEmpty) {
          _isEditing = false; 
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected location(s) deleted.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations(); 
  }

  void _addLocation() async {
    final newLocation = await Navigator.push<Location>(
      context,
      MaterialPageRoute(builder: (context) => AddLocationScreen(organizationId: _organizationId)),
    );

    if (newLocation != null) {
      setState(() {
        _showSuccessPopup = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessPopup = false;
          });
        }
      });
      _fetchLocations(); 
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedLocationIds.clear(); 
      }
    });
  }

  void _toggleSelectLocation(String locationId) {
    setState(() {
      if (_selectedLocationIds.contains(locationId)) {
        _selectedLocationIds.remove(locationId);
      } else {
        _selectedLocationIds.add(locationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAssetsCount = _locations.fold(0, (sum, location) => sum + (int.tryParse(location['deviceCount']?.toString() ?? '0') ?? 0));

    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 245, 245, 245), 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95.0),
        child: Stack(
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
                    const Spacer(), 
                    if (_isEditing && _selectedLocationIds.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: _deleteLocations,
                      ),
                    if (_locations.isNotEmpty || _isEditing)
                      IconButton(
                        icon: Icon(_isEditing ? Icons.done_all : Icons.edit, color: Colors.white),
                        onPressed: _toggleEditMode,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: CompanyInfoCard(
                  ticketNumber: '#000001',
                  companyName: 'PT Dunia Persada',
                  deviceCount: _isLoading ? 'Loading...' : '$totalAssetsCount Device',
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _locations.isEmpty
                        ? SizedBox(
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
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _locations.length,
                            itemBuilder: (context, index) {
                              final location = _locations[index];
                              final locationId = location['location_id']?.toString() ?? 'Unknown';
                              final isSelected = _selectedLocationIds.contains(locationId);

                              return GestureDetector(
                                onLongPress: () {
                                  if (!_isEditing) {
                                    _toggleEditMode();
                                  }
                                  _toggleSelectLocation(locationId);
                                },
                                onTap: () {
                                  if (_isEditing) {
                                    _toggleSelectLocation(locationId);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AssetDevicesScreen(showSuccessPopup: false),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: _isEditing && isSelected
                                        ? const BorderSide(color: Colors.blue, width: 2.0)
                                        : BorderSide.none,
                                  ),
                                  color: Colors.white, 
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        if (_isEditing)
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              _toggleSelectLocation(locationId);
                                            },
                                            activeColor: Colors.blue,
                                          ),
                                        const Icon(Icons.business, size: 40, color: Colors.grey),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                location['name']?.toString() ?? 'Unknown',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Text(
                                                '#${locationId}',
                                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  const Icon(Icons.laptop_mac, size: 18),
                                                  const SizedBox(width: 5),
                                                  Text('${location['deviceCount']?.toString() ?? '0'} Devices',
                                                      style: const TextStyle(fontSize: 14)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!_isEditing)
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const AssetDevicesScreen(showSuccessPopup: false),
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
                              );
                            },
                          ),
              ),
              const SizedBox(height: 80),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _isEditing && _selectedLocationIds.isNotEmpty
                  ? ElevatedButton(
                      onPressed: _deleteLocations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Delete Selected',
                        style: TextStyle(color: Color.fromARGB(255, 119, 119, 119), fontSize: 18),
                      ),
                    )
                  : ElevatedButton(
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

          if (_showSuccessPopup)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: const SafeArea( 
                  child: Row(
                    children: [
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

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}