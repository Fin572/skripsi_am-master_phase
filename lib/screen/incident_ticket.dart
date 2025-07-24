// // lib/screens/incident_detail_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:asset_management/screen/models/location.dart';
// import 'package:asset_management/screen/models/asset.dart';
// import 'package:asset_management/screen/models/incident_ticket.dart';

// class IncidentDetailScreen extends StatefulWidget {
//   final List<Location> availableLocations;
//   final List<Asset> availableAssets;

//   const IncidentDetailScreen({
//     Key? key,
//     required this.availableLocations,
//     required this.availableAssets,
//   }) : super(key: key);

//   @override
//   State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
// }

// class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
//   final _formKey = GlobalKey<FormState>();

//   Location? _selectedLocation;
//   Asset? _selectedAsset;
//   final TextEditingController _assetNameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   final List<File?> _incidentImages = List.filled(6, null);
//   final List<String> _imageLabels = [
//     'Tampak Depan',
//     'Tampak Belakang',
//     'Tampak Atas',
//     'Tampak Bawah',
//     'Lainnya 1',
//     'Lainnya 2',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _descriptionController.addListener(_validateForm);
//   }

//   @override
//   void dispose() {
//     _assetNameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   void _validateForm() {
//     setState(() {});
//   }

//   bool get _canSubmit {
//     bool isLocationSelected = _selectedLocation != null;
//     bool isAssetSelected = _selectedAsset != null;
//     bool isDescriptionFilled = _descriptionController.text.isNotEmpty;
//     bool hasAtLeastOneImage = _incidentImages.any((file) => file != null);

//     return isLocationSelected &&
//         isAssetSelected &&
//         isDescriptionFilled &&
//         hasAtLeastOneImage;
//   }

//   void _submitTicket() {
//     if (_formKey.currentState!.validate() && _canSubmit) {
//       final String newTicketId =
//           DateTime.now().millisecondsSinceEpoch.toString().substring(5, 11);

//       final List<String> uploadedImagePaths = _incidentImages
//           .whereType<File>()
//           .map((file) => file.path)
//           .toList();

//       final newIncidentTicket = IncidentTicket(
//         ticketId: newTicketId,
//         asset: _selectedAsset!,
//         location: _selectedLocation!,
//         description: _descriptionController.text,
//         submissionTime: DateTime.now(),
//         imageUrls: uploadedImagePaths,
//         status: 'Assigned',
//       );

//       Navigator.pop(context, newIncidentTicket);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields and upload at least one image.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _pickImage(int index, ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _incidentImages[index] = File(pickedFile.path);
//         _validateForm();
//       });
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _incidentImages[index] = null;
//       _validateForm();
//     });
//   }

//   void _showImageSourceSelection(int index) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Photo Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(index, ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(index, ImageSource.camera);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         toolbarHeight: 100,
//         title: const Text(
//           "Incident",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         flexibleSpace: const Image(
//           image: AssetImage('assets/bg_image.png'),
//           fit: BoxFit.cover,
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           onChanged: _validateForm,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _companycard(), // NEW method call

//               const SizedBox(height: 20),
//               _buildDropdownField<Location>(
//                 value: _selectedLocation,
//                 hintText: 'Select Location ID',
//                 labelText: 'Location ID',
//                 items: widget.availableLocations.map((location) {
//                   return DropdownMenuItem<Location>(
//                     value: location,
//                     child: Text('${location.name} (${location.id})'),
//                   );
//                 }).toList(),
//                 onChanged: (Location? newValue) {
//                   setState(() {
//                     _selectedLocation = newValue;
//                     _selectedAsset = null;
//                     _assetNameController.clear();
//                   });
//                 },
//                 validator: (value) => value == null ? 'Location ID is required' : null,
//               ),
//               const SizedBox(height: 15),

//               _buildDropdownField<Asset>(
//                 value: _selectedAsset,
//                 hintText: 'Select Asset ID',
//                 labelText: 'Asset ID',
//                 items: widget.availableAssets
//                     .where((asset) => _selectedLocation == null || asset.locationId == _selectedLocation!.id)
//                     .map((asset) {
//                   return DropdownMenuItem<Asset>(
//                     value: asset,
//                     child: Text('${asset.name} (${asset.id})'),
//                   );
//                 }).toList(),
//                 onChanged: (Asset? newValue) {
//                   setState(() {
//                     _selectedAsset = newValue;
//                     _assetNameController.text = newValue?.name ?? '';
//                   });
//                 },
//                 validator: (value) => value == null ? 'Asset ID is required' : null,
//               ),
//               const SizedBox(height: 15),

//               _buildTextField(
//                 controller: _assetNameController,
//                 labelText: 'Asset Name',
//                 readOnly: true,
//                 hintText: 'Auto-filled from Asset ID',
//               ),
//               const SizedBox(height: 15),

//               _buildTextField(
//                 controller: _descriptionController,
//                 labelText: 'Description',
//                 hintText: 'Enter incident description',
//                 maxLines: 5,
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Description is required' : null,
//               ),
//               const SizedBox(height: 20),

//               const Text('Upload Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 1.2,
//                 ),
//                 itemCount: _incidentImages.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index < _incidentImages.length) {
//                     return _buildImageUploadSlot(index);
//                   } else {
//                     return _buildAddMoreButton();
//                   }
//                 },
//               ),
//               const SizedBox(height: 30),

//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.grey),
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                       child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _canSubmit ? _submitTicket : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _canSubmit ? Colors.blueAccent : Colors.grey,
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                       child: const Text('Submit', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//  Widget _companycard() {
//   final String ticketNumber = '#000001';
//   final String companyName = 'PT Dunia Persada';
//   final String assetCount = '0 Asset';

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//     child: Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           )
//         ],
//       ),
//       child: Column(
//         children: [
//           const CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.white,
//             child: Icon(Icons.apartment, size: 30, color: Colors.blue),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             ticketNumber,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             companyName,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.desktop_windows, color: Colors.white70, size: 16),
//               const SizedBox(width: 4),
//               Text(
//                 assetCount,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   // Reuse these helper widgets from your original code
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     String? hintText,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       readOnly: readOnly,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: '$labelText*',
//         hintText: hintText,
//         border: const OutlineInputBorder(),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey[400]!),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         filled: readOnly,
//         fillColor: readOnly ? Colors.grey[200] : null,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       ),
//       validator: validator ??
//           (value) {
//             if (!readOnly && (value == null || value.isEmpty)) {
//               return 'This field is required';
//             }
//             return null;
//           },
//     );
//   }

//   Widget _buildDropdownField<T>({
//     required T? value,
//     required String hintText,
//     required String labelText,
//     required List<DropdownMenuItem<T>> items,
//     required void Function(T?) onChanged,
//     String? Function(T?)? validator,
//   }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: '$labelText*',
//         hintText: hintText,
//         border: const OutlineInputBorder(),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey[400]!),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
//           borderRadius: BorderRadius.all(Radius.circular(8.0)),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       ),
//       items: items,
//       onChanged: onChanged,
//       validator: validator ?? (value) => value == null ? 'This field is required' : null,
//     );
//   }

//   Widget _buildImageUploadSlot(int index) {
//     final file = _incidentImages[index];

//     return GestureDetector(
//       onTap: () {
//         if (file == null) _showImageSourceSelection(index);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8.0),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: file == null
//             ? const Center(child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey))
//             : Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.file(file, fit: BoxFit.cover),
//                   Positioned(
//                     top: 4,
//                     right: 4,
//                     child: GestureDetector(
//                       onTap: () => _removeImage(index),
//                       child: const Icon(Icons.close, color: Colors.red, size: 20),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildAddMoreButton() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: const Center(
//         child: Icon(Icons.add, size: 30, color: Colors.grey),
//       ),
//     );
//   }
// }