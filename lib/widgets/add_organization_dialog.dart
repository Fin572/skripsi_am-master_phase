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
  bool _isLoading = false;

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
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Organization',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Organization name *',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color.fromARGB(166, 187, 186, 186)),
                ),
                child: TextField(
                  controller: _organizationNameController,
                  decoration: const InputDecoration(
                    hintText: 'Organization Name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          final name = _organizationNameController.text.trim();
                          if (name.isNotEmpty) {
                            _addOrganization(name);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an organization name')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add organization',
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