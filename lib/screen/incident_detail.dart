import 'dart:io';
import 'package:asset_management/widgets/company_info_card.dart'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:asset_management/screen/models/location.dart';
import 'package:asset_management/screen/models/asset.dart'; 
import 'package:asset_management/screen/models/incident_ticket.dart';

class IncidentDetailScreen extends StatefulWidget {
  final List<Location> availableLocations;
  final List<Asset> availableAssets;

  const IncidentDetailScreen({
    Key? key,
    this.availableLocations = const [],
    this.availableAssets = const [],
  }) : super(key: key);

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  Location? _selectedLocation;
  Asset? _selectedAsset;
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File?> _incidentImages = List.filled(6, null);
  final List<String> _imageLabels = [
    'Front View', 
    'Rear View',
    'Top View', 
    'Bottom View', 
    'Other 1',
    'Other 2', 
  ];

  List<Location> _availableLocations = []; 
  List<Asset> _availableAssets = []; 
  bool _isLoadingLocations = true;
  bool _isLoadingAssets = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchAssets();
    _descriptionController.addListener(_validateForm);
    _assetNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/location_get.php')).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Location API request timed out');
          return http.Response('{"status": "error", "message": "Request timed out"}', 408);
        },
      );
      print('Location API Response status: ${response.statusCode}');
      print('Location API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed location data: $data');

        String status = (data['status'] as String?)?.toLowerCase() ?? '';
        if (status == 'success') {
          List<dynamic>? locations = data['locations'] ?? data['location'] ?? data['data'];
          if (locations != null && locations.isNotEmpty) {
            setState(() {
              _availableLocations = locations.map((location) {
                print('Processing location: $location');
                return Location(
                  id: (location['location_id'] ?? location['id'] ?? '').toString(),
                  name: location['name'] as String? ?? 'Unknown',
                );
              }).toList();
              print('Available locations: $_availableLocations');
              _isLoadingLocations = false;
            });
          } else {
            print('No locations found in response');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No locations found')),
            );
            setState(() {
              _isLoadingLocations = false;
            });
          }
        } else {
          print('API error: status is not success - ${data['message'] ?? 'Unknown error'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to load locations')),
          );
          setState(() {
            _isLoadingLocations = false;
          });
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations: ${response.statusCode}')),
        );
        setState(() {
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      print('Exception in _fetchLocations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching locations: $e')),
      );
      setState(() {
        _isLoadingLocations = false;
      });
    }
  }

  Future<void> _fetchAssets() async {
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/devices_get.php')).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Devices API request timed out');
          return http.Response('{"status": "error", "message": "Request timed out"}', 408);
        },
      );
      print('Devices API Response status: ${response.statusCode}');
      print('Devices API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed devices data: $data');

        String status = (data['status'] as String?)?.toLowerCase() ?? '';
        if (status == 'success') {
          List<dynamic>? devices = data['devices'] ?? data['device'] ?? data['data'];
          if (devices != null && devices.isNotEmpty) {
            setState(() {
              _availableAssets = devices.map((device) {
                print('Processing device: $device');
                final locationId = device['location_id'] != null
                    ? device['location_id'].toString()
                    : '0';
                return Asset(
                  id: device['id'].toString(),
                  name: device['name'] as String? ?? 'Unknown',
                  locationId: locationId,
                  category: device['category'] as String? ?? 'Device', 
                  locationInfo: device['location_info'] as String? ?? '', 
                  latitude: (device['latitude'] as num?)?.toDouble() ?? 0.0,
                  longitude: (device['longitude'] as num?)?.toDouble() ?? 0.0, 
                  personInCharge: device['person_in_charge'] as String? ?? '', 
                  phoneNumber: device['phone_number'] as String? ?? '', 
                  barcodeData: device['barcode_data'] as String? ?? '', 
                );
              }).toList();
              print('Available assets: $_availableAssets');
              _isLoadingAssets = false;
            });
          } else {
            print('No devices found in response');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No devices found')),
            );
            setState(() {
              _isLoadingAssets = false;
            });
          }
        } else {
          print('API error: status is not success - ${data['message'] ?? 'Unknown error'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to load devices')),
          );
          setState(() {
            _isLoadingAssets = false;
          });
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load devices: ${response.statusCode}')),
        );
        setState(() {
          _isLoadingAssets = false;
        });
      }
    } catch (e) {
      print('Exception in _fetchAssets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching devices: $e')),
      );
      setState(() {
        _isLoadingAssets = false;
      });
    }
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _canSubmit {
    bool isLocationSelected = _selectedLocation != null;
    bool isAssetSelected = _selectedAsset != null;
    bool isDescriptionFilled = _descriptionController.text.trim().isNotEmpty;
    bool hasAtLeastOneImage = _incidentImages.any((file) => file != null);

    print('Can submit check: isLocationSelected=$isLocationSelected, isAssetSelected=$isAssetSelected, '
        'isDescriptionFilled=$isDescriptionFilled, hasAtLeastOneImage=$hasAtLeastOneImage');

    return isLocationSelected &&
        isAssetSelected &&
        isDescriptionFilled &&
        hasAtLeastOneImage;
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate() && _canSubmit) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://assetin.my.id/skripsi/add_incident.php'),
      );

      print('Preparing to submit form data:');
      print('location_id: ${_selectedLocation!.id}');
      print('asset_id: ${_selectedAsset!.id}');
      print('asset_name: ${_assetNameController.text}');
      print('description: ${_descriptionController.text}');
      print('status: Assigned');

      request.fields['location_id'] = _selectedLocation!.id.toString();
      request.fields['asset_id'] = _selectedAsset!.id;
      request.fields['description'] = _descriptionController.text;
      request.fields['status'] = 'Assigned'; 
      request.fields['asset_name'] = _assetNameController.text;

      final List<String> imageFieldNames = ['image_0', 'image_1', 'image_2', 'image_3', 'image_4', 'image_5'];
      int imageCount = 0;
      for (int i = 0; i < _incidentImages.length; i++) {
        if (_incidentImages[i] != null) {
          print('Uploading image for ${imageFieldNames[i]}: ${_incidentImages[i]!.path}');
          request.files.add(await http.MultipartFile.fromPath(
            imageFieldNames[i],
            _incidentImages[i]!.path,
            filename: '${imageFieldNames[i]}.jpg',
          ));
          imageCount++;
        }
      }
      print('Total images uploaded: $imageCount');

      print('Submitting data: ${request.fields}');

      try {
        var response = await request.send();
        var responseBody = await http.Response.fromStream(response);

        print('Response status: ${response.statusCode}');
        print('Response body: ${responseBody.body}');

        if (response.statusCode == 200) {
          var data = json.decode(responseBody.body);
          if (data['status'] == 'success') {
            final newIncidentTicket = IncidentTicket(
              ticketId: data['id'].toString(), 
              asset: _selectedAsset!,
              location: _selectedLocation!,
              description: _descriptionController.text,
              submissionTime: DateTime.now(),
              imageUrls: _incidentImages.whereType<File>().map((file) => file.path).toList(),
              status: 'Assigned',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
            Navigator.pop(context, newIncidentTicket);
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
      String validationError = '';
      if (_selectedLocation == null) {
        validationError += 'Location ID is required. ';
      }
      if (_selectedAsset == null) {
        validationError += 'Asset ID is required. ';
      }
      if (_descriptionController.text.trim().isEmpty) {
        validationError += 'Description is required. ';
      }
      if (!_incidentImages.any((file) => file != null)) {
        validationError += 'At least one image is required. ';
      }
      print('Validation failed: $validationError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError.isNotEmpty
              ? validationError
              : 'Please fill all required fields and upload at least one image.'),
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
        print('Image picked for index $index: ${pickedFile.path}');
        _validateForm();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _incidentImages[index] = null;
      print('Image removed for index $index');
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
              const CompanyInfoCard(
                ticketNumber: '#000001', 
                companyName: 'PT Dunia Persada', 
                deviceCount: '0 Device', 
              ),

              const SizedBox(height: 20),
              _isLoadingLocations
                  ? const Center(child: CircularProgressIndicator())
                  : _availableLocations.isEmpty
                      ? const Center(child: Text('No locations available'))
                      : _buildDropdownField<Location>(
                          value: _selectedLocation,
                          hintText: 'Select Location ID',
                          labelText: 'Location ID',
                          items: _availableLocations.map((location) {
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
                              print('Selected location: $_selectedLocation');
                              _validateForm();
                            });
                          },
                          validator: (value) {
                            print('Location validator: value=$value');
                            return value == null ? 'Location ID is required' : null;
                          },
                        ),
              const SizedBox(height: 15),

              _isLoadingAssets
                  ? const Center(child: CircularProgressIndicator())
                  : _availableAssets.isEmpty
                      ? const Center(child: Text('No assets available'))
                      : _buildDropdownField<Asset>(
                          value: _selectedAsset,
                          hintText: 'Select Device ID',
                          labelText: 'Device ID',
                          items: _availableAssets
                              .where((asset) {
                                if (_selectedLocation == null) return true;
                                return asset.locationId == _selectedLocation!.id;
                              })
                              .map((asset) {
                                return DropdownMenuItem<Asset>(
                                  value: asset,
                                  child: Text('${asset.name} (${asset.id})'),
                                );
                              })
                              .toList(),
                          onChanged: (Asset? newValue) {
                            setState(() {
                              _selectedAsset = newValue;
                              _assetNameController.text = newValue?.name ?? '';
                              print('Selected asset: $_selectedAsset');
                              _validateForm();
                            });
                          },
                          validator: (value) {
                            print('Asset validator: value=$value');
                            return value == null ? 'Asset ID is required' : null;
                          },
                        ),
              const SizedBox(height: 15), 

              _buildTextField(
                controller: _assetNameController,
                labelText: 'Device Name', 
                readOnly: true,
                hintText: 'Auto-filled from Device ID',
              ),
              const SizedBox(height: 15), 

              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter incident description',
                maxLines: 5,
                validator: (value) {
                  print('Description validator: value=$value');
                  return value == null || value.trim().isEmpty ? 'Description is required' : null;
                },
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
                itemCount: _incidentImages.length,
                itemBuilder: (context, index) {
                  return _buildImageUploadSlot(index); 
                },
              ),
              if (_incidentImages.any((file) => file == null)) 
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _buildAddMoreButton(), 
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
                        backgroundColor: const Color.fromARGB(245, 255, 255, 255), 
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
                      onPressed: _canSubmit ? _submitTicket : null, 
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
      minLines: maxLines > 1 ? maxLines : null, 
      decoration: InputDecoration(
        labelText: '$labelText*',
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always, 
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!), 
          borderRadius: BorderRadius.circular(8.0), 
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1), width: 2.0), 
          borderRadius: BorderRadius.circular(8.0), 
        ),
        filled: true, 
        fillColor: readOnly ? Colors.grey[200] : Colors.white, 
        contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0), 
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)
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
          border: Border.all(color: const Color.fromRGBO(52, 152, 219, 1), width: 2), 
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 40, color: Color.fromRGBO(52, 152, 219, 1)), 
            const SizedBox(height: 5), 
            const Text(
              'Add More', 
              style: TextStyle(color: Color.fromRGBO(52, 152, 219, 1), fontSize: 14), 
            ),
          ],
        ),
      ),
    );
  }
}