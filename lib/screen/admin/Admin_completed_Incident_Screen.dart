// Admin_completed_Incident_Screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:asset_management/widgets/company_info_card.dart';

class AdminCompleteIncidentScreen extends StatefulWidget {
  final Map<String, String> incident;
  final Function(Map<String, String>) onIncidentCompleted;

  const AdminCompleteIncidentScreen({
    Key? key,
    required this.incident,
    required this.onIncidentCompleted,
  }) : super(key: key);

  @override
  State<AdminCompleteIncidentScreen> createState() => _AdminCompleteIncidentScreenState();
}

class _AdminCompleteIncidentScreenState extends State<AdminCompleteIncidentScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  @override
  void dispose() {
    _priceController.dispose();
    _picController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitCompletion() {
    if (_priceController.text.isEmpty || _picController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, String> completedIncident = Map<String, String>.from(widget.incident);
    completedIncident['status'] = 'Completed';
    completedIncident['price'] = _priceController.text;
    completedIncident['pic_completed'] = _picController.text;
    completedIncident['completion_description'] = _descriptionController.text;
    completedIncident['completed_image_urls'] = _selectedImages.map((e) => e.path).join(',');

    widget.onIncidentCompleted(completedIncident);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0;

    final String companyInfo = widget.incident['companyInfo']!;
    final List<String> companyParts = companyInfo.split(' - ');
    final String companyName = companyParts[0].trim();
    final String companyId = companyParts.length > 1 ? companyParts[1].trim() : '';

    final String displayDeviceCount = widget.incident['title']!.contains('CCTV') ? '4 Devices' : 'N/A Devices';

    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 245, 245, 245),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            Image.asset(
              'assets/bg_image.png',
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Complete Incident',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyInfoCard(
                ticketNumber: companyId,
                companyName: companyName,
                deviceCount: displayDeviceCount,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _priceController,
                label: 'Price',
                hintText: 'Enter price (e.g., \$150.00)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _picController,
                label: 'PIC',
                hintText: 'Enter Person In Charge name',
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Enter completion details',
                isMultiline: true,
              ),
              const SizedBox(height: 20),

              const Text(
                'Upload Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildImageSelectionGrid(),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool isMultiline = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: isMultiline ? null : 1,
          minLines: isMultiline ? 3 : 1,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelectionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Add Image', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        } else {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  _selectedImages[index],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}