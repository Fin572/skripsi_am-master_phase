import 'dart:io';
import 'package:asset_management/screen/asset_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:asset_management/screen/models/location.dart';
import 'package:asset_management/widgets/company_info_card.dart';

class AddDeviceScreen extends StatefulWidget {
  // Removed `required List<Location> availableLocations` from constructor
  // as it's now fetched internally.
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  Location? _selectedLocation;
  String? _selectedCategory;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _personInChargeController = TextEditingController(); // Updated from _locationPICController
  final TextEditingController _personInChargePhoneController = TextEditingController(); // New controller

  final List<File?> _deviceImages = List.filled(5, null); // 4 specific views + 1 for "Add More" concept
  final List<String> _imageLabels = [
    'Front View',
    'Rear View',
    'Top View',
    'Bottom View',
    'Add More', // Last slot is for 'Add More'
  ];

  final List<String> _availableCategories = [
    'CCTV',
    'Electronics',
    'Furniture',
    'Vehicles',
    'Machinery',
  ];

  List<Location> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _quantityController.addListener(_validateForm);
    _assetNameController.addListener(_validateForm);
    _personInChargeController.addListener(_validateForm); // Listen to new PIC controller
    _personInChargePhoneController.addListener(_validateForm); // Listen to new phone controller
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _assetNameController.dispose();
    _personInChargeController.dispose(); // Dispose new PIC controller
    _personInChargePhoneController.dispose(); // Dispose new phone controller
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/location_get.php'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['locations'] != null) {
          setState(() {
            _availableLocations = (data['locations'] as List)
                .map((location) => Location(
                      id: location['location_id'].toString(), // <--- CHANGED THIS LINE: Removed int.parse()
                      name: location['name'] as String,
                    ))
                .toList();
            print('Available locations: $_availableLocations');
          });
        } else {
          print('API error or no locations: ${data['message'] ?? 'No locations found'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'No locations found')),
          );
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching locations: $e')),
      );
    }
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _canSubmit {
    bool isLocationSelected = _selectedLocation != null;
    bool isCategorySelected = _selectedCategory != null;
    bool isQuantityFilled = _quantityController.text.isNotEmpty;
    bool isAssetNameFilled = _assetNameController.text.isNotEmpty;
    bool isPersonInChargeFilled = _personInChargeController.text.isNotEmpty; // Updated to new PIC field
    bool isPersonInChargePhoneFilled = _personInChargePhoneController.text.isNotEmpty; // New phone field
    bool hasAtLeastOneImage = _deviceImages.sublist(0, 4).any((file) => file != null); // Check only specific image slots

    return isLocationSelected &&
        isCategorySelected &&
        isQuantityFilled &&
        isAssetNameFilled &&
        isPersonInChargeFilled &&
        isPersonInChargePhoneFilled &&
        hasAtLeastOneImage;
  }

  Future<void> _submitDevice() async {
    if (_formKey.currentState!.validate() && _canSubmit) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://assetin.my.id/skripsi/add_device.php'),
      );

      request.fields['location_id'] = _selectedLocation!.id.toString();
      request.fields['device_type'] = _selectedCategory!;
      request.fields['locationPIC_id'] = _personInChargeController.text; // Using _personInChargeController for locationPIC_id
      request.fields['quantity'] = _quantityController.text;
      request.fields['name'] = _assetNameController.text;
      request.fields['phone_number'] = _personInChargePhoneController.text; // New phone number field

      final List<String> imageFieldNames = ['front_view', 'rear_view', 'top_view', 'bottom_view'];
      for (int i = 0; i < 4; i++) { // Loop only for the first 4 specific image slots
        if (_deviceImages[i] != null) {
          print('Uploading image for ${imageFieldNames[i]}: ${_deviceImages[i]!.path}');
          request.files.add(await http.MultipartFile.fromPath(
            imageFieldNames[i],
            _deviceImages[i]!.path,
            filename: '${imageFieldNames[i]}.jpg',
          ));
        }
      }

      // Log data yang akan dikirim
      print('Submitting data: ${request.fields}');

      try {
        var response = await request.send();
        var responseBody = await http.Response.fromStream(response);

        print('Response status: ${response.statusCode}');
        print('Response body: ${responseBody.body}');

        if (response.statusCode == 200) {
          var data = json.decode(responseBody.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AssetDevicesScreen(showSuccessPopup: true),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server error')),
          );
        }
      } catch (e) {
        print('Exception during submission: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and upload at least one image.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage(int index, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _deviceImages[index] = File(pickedFile.path);
        _validateForm();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _deviceImages[index] = null;
      _validateForm();
    });
  }

  void _showImageSourceSelection(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper for general text fields (can be reused) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: '$labelText*',
        hintText: hintText,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true, // Always fill the field
        fillColor: readOnly ? Colors.grey[200] : Colors.white, // White when not readOnly, grey when readOnly
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      validator: validator ??
          (value) {
            if (!readOnly && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
    );
  }


  // --- Helper for dropdown fields (can be reused) ---
  Widget _buildDropdownField<T>({
    required T? value,
    required String hintText,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: '$labelText*',
        hintText: hintText,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(52, 152, 219, 1), width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator ?? (value) => value == null ? 'This field is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the consistent AppBar height
    const double consistentAppBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Background image that covers the entire PreferredSize area (95.0px)
            Image.asset(
              'assets/bg_image.png', // Ensure this path is correct
              height: consistentAppBarHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context, false); // Indicate cancellation if simply going back
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Add device', // Title from image
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _validateForm, // Validate on any form field change
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Info Card
              const CompanyInfoCard(
                ticketNumber: '#000001',
                companyName: 'PT Dunia Persada',
                deviceCount: '0 Device', // As per image for initial state
              ),
              const SizedBox(height: 20),

              // Location ID Dropdown
              FutureBuilder<List<Location>>(
                future: Future.value(_availableLocations), // Use Future.value for immediate data
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || _availableLocations.isEmpty) {
                    return const Text('No locations available');
                  } else {
                    return _buildDropdownField<Location>(
                      value: _selectedLocation,
                      hintText: 'Select Location ID',
                      labelText: 'Location ID',
                      items: _availableLocations.map((location) {
                        return DropdownMenuItem<Location>(
                          value: location,
                          child: Text('${location.id} - ${location.name}'),
                        );
                      }).toList(),
                      onChanged: (Location? newValue) {
                        setState(() {
                          _selectedLocation = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Location ID is required' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 15),

              // Category and Quantity in a Row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField<String>(
                      value: _selectedCategory,
                      hintText: 'Select Category',
                      labelText: 'Category',
                      items: _availableCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Category is required' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 120, // Fixed width for Quantity field
                    child: _buildTextField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      keyboardType: TextInputType.number,
                      hintText: 'e.g., 1',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Invalid Qty';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Asset name
              _buildTextField(
                controller: _assetNameController,
                labelText: 'Device name',
                hintText: 'e.g., CCTV Unit 01',
                validator: (value) => value == null || value.isEmpty ? 'Asset name is required' : null,
              ),
              const SizedBox(height: 15),

              // Person in charge
              _buildTextField(
                controller: _personInChargeController,
                labelText: 'Person in charge',
                hintText: 'e.g., John Doe',
                validator: (value) => value == null || value.isEmpty ? 'Person in charge is required' : null,
              ),
              const SizedBox(height: 15),

              // Person in charge's phone number
              _buildTextField(
                controller: _personInChargePhoneController,
                labelText: 'Person in charge\'s phone number',
                keyboardType: TextInputType.phone,
                hintText: 'e.g., +6281234567890',
                validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 20),

              // Upload Images Section
              const Text('Upload Images*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: _deviceImages.length, // 5 slots from image
                itemBuilder: (context, index) {
                  return _buildImageUploadSlot(index);
                },
              ),
              const SizedBox(height: 30),

              // Cancel and Submit Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Pop back and signal cancellation
                        Navigator.pop(context, false);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(245, 255, 255, 255),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submitDevice : null, // Disable if not valid
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? const Color.fromRGBO(52, 152, 219, 1) : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Image Upload Slots (adapted for this screen) ---
  Widget _buildImageUploadSlot(int index) {
    final file = _deviceImages[index];

    // For the 'Add More' slot (the last one, index 4)
    if (index == _deviceImages.length - 1) {
      // Show 'Add More' only if at least one of the first 4 slots is empty
      if (_deviceImages.sublist(0, _deviceImages.length - 1).every((img) => img != null)) {
        return const SizedBox.shrink(); // Hide if all specific slots are filled
      }
      return GestureDetector(
        onTap: () {
          // Find the first empty specific slot (indices 0-3) to add an image
          int targetIndex = _deviceImages.sublist(0, 4).indexWhere((img) => img == null);
          if (targetIndex != -1) {
            _showImageSourceSelection(targetIndex);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All specific image slots (Front, Rear, Top, Bottom) are filled.'), backgroundColor: Colors.red,),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color.fromRGBO(52, 152, 219, 1), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 40, color: const Color.fromRGBO(52, 152, 219, 1)),
              const SizedBox(height: 5),
              Text(
                _imageLabels[index], // "Add More"
                textAlign: TextAlign.center,
                style: const TextStyle(color: const Color.fromRGBO(52, 152, 219, 1), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // For specific view slots (Front, Rear, Top, Bottom, indices 0-3)
    return GestureDetector(
      onTap: () {
        if (file == null) _showImageSourceSelection(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 119, 119, 119),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8.0)),
                      ),
                      child: Text(
                        _imageLabels[index], // e.g., "Front View"
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 5),
                  Text(
                    _imageLabels[index], // e.g., "Front View"
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}