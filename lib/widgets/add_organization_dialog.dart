import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddOrganizationDialog extends StatefulWidget {
  const AddOrganizationDialog({Key? key}) : super(key: key);

  @override
  State<AddOrganizationDialog> createState() => _AddOrganizationDialogState();
}

class _AddOrganizationDialogState extends State<AddOrganizationDialog> {
  final TextEditingController _organizationNameController = TextEditingController();
  bool _isLoading = false; // Preserved from original

  // Backend logic from original file
  Future<void> _addOrganization(String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/add_organization.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'organization_name': name}),
      );

      print('Add Status Code: ${response.statusCode}');
      print('Add Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop(name);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add organization: ${response.body}')),
        );
      }
    } catch (e) {
      print('Add Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not connect to server - $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // From NEW UI
      ),
      elevation: 0, // From NEW UI
      backgroundColor: Colors.transparent, // From NEW UI
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20), // From NEW UI
          margin: const EdgeInsets.only(top: 0), // From NEW UI
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white, // From NEW UI
            borderRadius: BorderRadius.circular(16.0), // From NEW UI
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // From NEW UI
                offset: const Offset(0, 10), // From NEW UI
                blurRadius: 10, // From NEW UI
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // From NEW UI
            children: <Widget>[
              Row( // From NEW UI
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // From NEW UI
                children: [
                  const Text(
                    'Add Organization', // From NEW UI
                    style: TextStyle(
                      fontSize: 26, // From NEW UI
                      fontWeight: FontWeight.bold, // From NEW UI
                      color: Colors.black, // From NEW UI
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close, color: Colors.grey.shade600, size: 24), // From NEW UI
                  ),
                ],
              ),
              const SizedBox(height: 20), // From NEW UI
              const Text(
                'Organization name *', // From NEW UI
                style: TextStyle(
                  fontSize: 18, // From NEW UI
                  color: Colors.black87, // From NEW UI
                ),
              ),
              const SizedBox(height: 8), // From NEW UI
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // From NEW UI
                  borderRadius: BorderRadius.circular(8.0), // From NEW UI
                  border: Border.all(color: const Color.fromARGB(166, 187, 186, 186)), // From NEW UI
                ),
                child: TextField(
                  controller: _organizationNameController,
                  decoration: const InputDecoration(
                    hintText: 'Organization Name', // From NEW UI
                    border: InputBorder.none, // From NEW UI
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0), // From NEW UI
                  ),
                ),
              ),
              const SizedBox(height: 30), // From NEW UI
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading // Preserved loading state
                      ? null
                      : () {
                          final name = _organizationNameController.text.trim();
                          if (name.isNotEmpty) {
                            _addOrganization(name); // Call original backend method
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an organization name')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // From NEW UI
                    padding: const EdgeInsets.symmetric(vertical: 15), // From NEW UI
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // From NEW UI
                    ),
                  ),
                  child: _isLoading // Preserved loading indicator
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add organization', // From NEW UI
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}