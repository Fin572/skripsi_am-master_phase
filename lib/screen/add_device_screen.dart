// lib/screens/add_device_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asset_management/screen/models/location.dart'; // Reusing Location model
import 'package:asset_management/widgets/company_info_card.dart'; // Reusing CompanyInfoCard

class AddDeviceScreen extends StatefulWidget {
  // We need to pass available locations for the dropdown
  final List<Location> availableLocations;

  const AddDeviceScreen({Key? key, required this.availableLocations}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();

  Location? _selectedLocation;
  String? _selectedCategory;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _personInChargeController = TextEditingController();
  final TextEditingController _personInChargePhoneController = TextEditingController();

  final List<File?> _deviceImages = List.filled(5, null); // 4 specific views + 1 add more
  final List<String> _imageLabels = [
    'Front View',
    'Rear View',
    'Top View',
    'Bottom View',
    'Other', // For the 'Add More' slot if it becomes dynamic
  ];

  // Dummy categories for the dropdown
  final List<String> _availableCategories = [
    'CCTV',
    'Electronics',
    'Furniture',
    'Vehicles',
    'Machinery',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_validateForm);
    _assetNameController.addListener(_validateForm);
    _personInChargeController.addListener(_validateForm);
    _personInChargePhoneController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _assetNameController.dispose();
    _personInChargeController.dispose();
    _personInChargePhoneController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {}); // Rebuilds to enable/disable submit button
  }

  bool get _canSubmit {
    bool isLocationSelected = _selectedLocation != null;
    bool isCategorySelected = _selectedCategory != null;
    bool isQuantityFilled = _quantityController.text.isNotEmpty;
    bool isAssetNameFilled = _assetNameController.text.isNotEmpty;
    bool isPersonInChargeFilled = _personInChargeController.text.isNotEmpty;
    bool isPersonInChargePhoneFilled = _personInChargePhoneController.text.isNotEmpty;
    bool hasAtLeastOneImage = _deviceImages.any((file) => file != null);

    return isLocationSelected &&
        isCategorySelected &&
        isQuantityFilled &&
        isAssetNameFilled &&
        isPersonInChargeFilled &&
        isPersonInChargePhoneFilled &&
        hasAtLeastOneImage;
  }

  void _submitDevice() {
    if (_formKey.currentState!.validate() && _canSubmit) {
      // Collect data and simulate submission
      print('Submitting Device:');
      print('Location: ${_selectedLocation!.name}');
      print('Category: $_selectedCategory');
      print('Quantity: ${_quantityController.text}');
      print('Asset Name: ${_assetNameController.text}');
      print('Person In Charge: ${_personInChargeController.text}');
      print('Phone: ${_personInChargePhoneController.text}');
      print('Images: ${_deviceImages.whereType<File>().map((f) => f.path).toList()}');

      // TODO: Implement actual device submission logic (e.g., API call)
      // On success, pop back to AssetDevicesScreen, possibly with a success flag
      Navigator.pop(context, true); // Signal success to previous screen
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
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
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
          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator ?? (value) => value == null ? 'This field is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, false); // Indicate cancellation if simply going back
          },
        ),
        title: const Text(
          'Add device', // Title from image
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
              _buildDropdownField<Location>(
                value: _selectedLocation,
                hintText: 'Select Location ID',
                labelText: 'Location ID',
                items: widget.availableLocations.map((location) {
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
                labelText: 'Asset name',
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
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submitDevice : null, // Disable if not valid
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? Colors.blueAccent : Colors.grey,
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
    // Labels specific to this "Add Device" screen
    final List<String> currentImageLabels = [
      'Front View',
      'Rear View',
      'Top View',
      'Bottom View',
      'Add More', // Last slot is for 'Add More'
    ];

    final file = _deviceImages[index];

    // For the 'Add More' slot (the last one)
    if (index == _deviceImages.length - 1) {
      if (_deviceImages.sublist(0, _deviceImages.length - 1).every((img) => img != null)) {
        // If all specific slots are filled, don't show "Add More"
        return const SizedBox.shrink();
      }
      return GestureDetector(
        onTap: () {
          // If a slot before the last one is empty, use that
          int targetIndex = _deviceImages.sublist(0, _deviceImages.length -1).indexWhere((img) => img == null);
          if (targetIndex != -1) {
             _showImageSourceSelection(targetIndex);
          } else {
             // If all specific slots are full, you might want to show a message or do nothing
             // In this case, the `_deviceImages` only has 5 slots as per current design (4 + 1 for "Add More" concept)
             // If you want more than 4, _deviceImages list size needs to be larger than 5 and logic adjusted
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All specific image slots are filled.')),
             );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 5),
              Text(
                currentImageLabels[index], // "Add More"
                style: TextStyle(color: Colors.blueAccent, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // For specific view slots (Front, Rear, Top, Bottom)
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
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
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
                        currentImageLabels[index],
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
                    currentImageLabels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}