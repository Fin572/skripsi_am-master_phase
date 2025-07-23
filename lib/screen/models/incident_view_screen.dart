// lib/screens/incident_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asset_management/screen/models/incident_ticket.dart';
import 'package:asset_management/widgets/company_info_card.dart';
import 'dart:convert';
import 'dart:typed_data';

class IncidentViewScreen extends StatelessWidget {
  final IncidentTicket incidentTicket;

  const IncidentViewScreen({Key? key, required this.incidentTicket}) : super(key: key);

  static const List<String> _imageLabels = [
    'Tampak Depan',
    'Tampak Belakang',
    'Tampak Atas',
    'Tampak Bawah',
    'Lainnya 1',
    'Lainnya 2',
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.orange;
      case 'On progress':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReadOnlyField({
    required String labelText,
    required String value,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: labelText,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            children: const [
              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Text(
            value.isEmpty ? (hintText ?? '') : value,
            style: TextStyle(
              color: value.isEmpty ? Colors.grey[500] : Colors.black,
              fontSize: 16,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('IncidentTicket data: $incidentTicket'); // Tambahan debug
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Incident",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: const Image(
          image: AssetImage('assets/bg_image.png'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CompanyInfoCard(),
            const SizedBox(height: 20),
            _buildReadOnlyField(
              labelText: 'Location ID',
              value: '${incidentTicket.location.id} - ${incidentTicket.location.name}',
            ),
            const SizedBox(height: 15),
            _buildReadOnlyField(
              labelText: 'Asset ID',
              value: incidentTicket.asset.id,
            ),
            const SizedBox(height: 15),
            _buildReadOnlyField(
              labelText: 'Asset Name',
              value: incidentTicket.asset.name,
              hintText: 'Auto-filled from Asset ID',
            ),
            const SizedBox(height: 15),
            _buildReadOnlyField(
              labelText: 'Description',
              value: incidentTicket.description,
              maxLines: 5,
              hintText: 'No description provided',
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
              itemCount: 4,
              itemBuilder: (context, index) {
                final imageBase64 = index < incidentTicket.imageUrls.length ? incidentTicket.imageUrls[index] : null;
                final String imageLabel = index < _imageLabels.length ? _imageLabels[index] : '';
                print('Image $index - Base64: $imageBase64');

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageBase64 != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Builder(
                              builder: (context) {
                                try {
                                  print('Decoding image $index with length: ${imageBase64.length}');
                                  final decoded = base64Decode(imageBase64);
                                  print('Decoded length: ${decoded.length}');
                                  if (decoded.isEmpty) {
                                    print('Empty decoded data for image $index');
                                    return const Center(child: Icon(Icons.error, color: Colors.red, size: 40));
                                  }
                                  return Image.memory(
                                    decoded,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                      if (wasSynchronouslyLoaded) return child;
                                      return AnimatedOpacity(
                                        opacity: frame == null ? 0 : 1,
                                        duration: const Duration(seconds: 1),
                                        child: child,
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error decoding image $index: $error');
                                      print('Stack trace: $stackTrace');
                                      return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                                    },
                                  );
                                } catch (e, stack) {
                                  print('Exception decoding image $index: $e');
                                  print('Stack trace: $stack');
                                  return const Center(child: Icon(Icons.error, color: Colors.red, size: 40));
                                }
                              },
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
                                  imageLabel,
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
                              imageLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}