// lib/screens/incident_detail.dart
import 'dart:io';
import 'package:asset_management/widgets/company_info_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asset_management/screen/models/location.dart';
import 'package:asset_management/screen/models/asset.dart';
import 'package:asset_management/screen/models/incident_ticket.dart';

class IncidentDetail extends StatefulWidget {
  final List<Location> availableLocations;
  final List<Asset> availableAssets;

  const IncidentDetail({
    Key? key,
    required this.availableLocations,
    required this.availableAssets,
  }) : super(key: key);

  @override
  State<IncidentDetail> createState() => _IncidentDetailState();
}

class _IncidentDetailState extends State<IncidentDetail> {
  final _formKey = GlobalKey<FormState>();

  Location? _selectedLocation;
  Asset? _selectedAsset;
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File?> _incidentImages = List.filled(6, null);
  final List<String> _imageLabels = [
    'Tampak Depan',
    'Tampak Belakang',
    'Tampak Atas',
    'Tampak Bawah',
    'Lainnya 1',
    'Lainnya 2',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _canSubmit {
    bool isLocationSelected = _selectedLocation != null;
    bool isAssetSelected = _selectedAsset != null;
    bool isDescriptionFilled = _descriptionController.text.isNotEmpty;
    bool hasAtLeastOneImage = _incidentImages.any((file) => file != null);

    return isLocationSelected &&
        isAssetSelected &&
        isDescriptionFilled &&
        hasAtLeastOneImage;
  }

  void _submitTicket() {
    if (_formKey.currentState!.validate() && _canSubmit) {
      final String newTicketId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5, 11);

      final List<String> uploadedImagePaths = _incidentImages
          .whereType<File>()
          .map((file) => file.path)
          .toList();

      final newIncidentTicket = IncidentTicket(
        ticketId: newTicketId,
        asset: _selectedAsset!,
        location: _selectedLocation!,
        description: _descriptionController.text,
        submissionTime: DateTime.now(),
        imageUrls: uploadedImagePaths,
        status: 'Assigned',
      );

      // Pop with the new ticket object
      Navigator.pop(context, newIncidentTicket);
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
        _incidentImages[index] = File(pickedFile.path);
        _validateForm();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _incidentImages[index] = null;
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

  Future<bool?> _showCancelConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to discard this ticket creation?'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Incident",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: const Image(
          image: AssetImage('assets/bg_image.png'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            final bool? confirmed = await _showCancelConfirmationDialog();
            if (confirmed == true) {
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the new reusable CompanyInfoCard widget here
              // You can pass specific data if needed, or use defaults
              const CompanyInfoCard(), // Uses default values for ticket number, company, and devices

              const SizedBox(height: 20),
              _buildDropdownField<Location>(
                value: _selectedLocation,
                hintText: 'Select Location ID',
                labelText: 'Location ID',
                items: widget.availableLocations.map((location) {
                  return DropdownMenuItem<Location>(
                    value: location,
                    child: Text('${location.name} (${location.id})'),
                  );
                }).toList(),
                onChanged: (Location? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                    _selectedAsset = null;
                    _assetNameController.clear();
                  });
                },
                validator: (value) => value == null ? 'Location ID is required' : null,
              ),
              const SizedBox(height: 15),

              _buildDropdownField<Asset>(
                value: _selectedAsset,
                hintText: 'Select Asset ID',
                labelText: 'Asset ID',
                items: widget.availableAssets
                    .where((asset) => _selectedLocation == null || asset.locationId == _selectedLocation!.id)
                    .map((asset) {
                  return DropdownMenuItem<Asset>(
                    value: asset,
                    child: Text('${asset.name} (${asset.id})'),
                  );
                }).toList(),
                onChanged: (Asset? newValue) {
                  setState(() {
                    _selectedAsset = newValue;
                    _assetNameController.text = newValue?.name ?? '';
                  });
                },
                validator: (value) => value == null ? 'Asset ID is required' : null,
              ),
              const SizedBox(height: 15),

              _buildTextField(
                controller: _assetNameController,
                labelText: 'Asset Name',
                readOnly: true,
                hintText: 'Auto-filled from Asset ID',
              ),
              const SizedBox(height: 15),

              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter incident description',
                maxLines: 5,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),

              const Text('Upload Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                itemCount: _incidentImages.length + 1,
                itemBuilder: (context, index) {
                  if (index < _incidentImages.length) {
                    return _buildImageUploadSlot(index);
                  } else {
                    return _buildAddMoreButton();
                  }
                },
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final bool? confirmed = await _showCancelConfirmationDialog();
                        if (confirmed == true) {
                          Navigator.pop(context, false);
                        }
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
                      onPressed: _canSubmit ? _submitTicket : null,
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

  // --- REMOVED: _companycard() method is no longer needed here ---

  // Reuse these helper widgets from your original code (unchanged)
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

  Widget _buildImageUploadSlot(int index) {
    final file = _incidentImages[index];

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
                    child: Image.file(file!, fit: BoxFit.cover),
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
                        _imageLabels[index],
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
                    _imageLabels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    bool hasEmptySlot = _incidentImages.any((file) => file == null);
    if (!hasEmptySlot) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        int firstEmptyIndex = _incidentImages.indexWhere((file) => file == null);
        if (firstEmptyIndex != -1) {
          _showImageSourceSelection(firstEmptyIndex);
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
              'Add More',
              style: TextStyle(color: Colors.blueAccent, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}