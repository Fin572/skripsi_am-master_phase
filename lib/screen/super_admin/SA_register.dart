import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/user_role.dart';
import 'package:asset_management/screen/models/organization.dart';
import 'package:asset_management/screen/models/app_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuperAdminRegister extends StatefulWidget {
  const SuperAdminRegister({Key? key}) : super(key: key);

  @override
  State<SuperAdminRegister> createState() => _SuperAdminUserListScreenState();
}

class _SuperAdminUserListScreenState extends State<SuperAdminRegister> {
  final List<AppUser> _appUsers = [];
  final List<Organization> _organizations = [];
  bool _isLoading = false;

  final _registerFormKey = GlobalKey<FormState>();
  UserRole? _selectedRegisterRole;
  Organization? _selectedOrganizationForUser;
  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
  }

  @override
  void dispose() {
    _registerUsernameController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://assetin.my.id/skripsi/fetch_organizations.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _organizations.clear();
          _organizations.addAll(data.map((item) => Organization(
                id: item['organization_id'].toString(),
                name: item['organization_name'],
              )));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch organizations: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching organizations: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/register_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _registerUsernameController.text,
          'name': _registerNameController.text,
          'email': _registerEmailController.text,
          'password': _registerPasswordController.text,
          'role': _selectedRegisterRole!.name,
          'organization_id': _selectedRegisterRole == UserRole.customer
              ? _selectedOrganizationForUser?.id
              : null,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] != null) {
          setState(() {
            _registerFormKey.currentState!.reset();
            _selectedRegisterRole = null;
            _selectedOrganizationForUser = null;
            _registerUsernameController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User "${_registerNameController.text}" registered successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register user: ${responseData['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register user: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering user: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String labelText, String hintText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black),
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  InputDecoration _buildDropdownInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText,
      String hintText,
      TextInputType keyboardType, {
        bool obscureText = false,
        bool showVisibilityToggle = false,
        VoidCallback? onVisibilityToggle,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: _buildInputDecoration(labelText, hintText).copyWith(
        suffixIcon: showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (labelText.toLowerCase().contains('email') && !value.contains('@')) {
          return 'Enter a valid email';
        }
        if (labelText.toLowerCase().contains('password') && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (labelText.toLowerCase().contains('confirm password')) {
          if (value != _registerPasswordController.text) {
            return 'Passwords do not match';
          }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;
    final fontSize = screenSize.width * 0.045;
    final buttonHeight = screenSize.height * 0.07;
    final fieldSpacing = screenSize.height * 0.03;
    const double consistentAppBarHeight = 95.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: fieldSpacing),
                              DropdownButtonFormField<UserRole>(
                                decoration: _buildDropdownInputDecoration('Choose Level*'),
                                value: _selectedRegisterRole,
                                hint: const Text('Customer/user'),
                                items: const [
                                  DropdownMenuItem(value: UserRole.customer, child: Text('Customer/user')),
                                  DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                                ],
                                onChanged: (UserRole? newValue) {
                                  setState(() {
                                    _selectedRegisterRole = newValue;
                                    if (newValue == UserRole.admin) {
                                      _selectedOrganizationForUser = null;
                                    }
                                  });
                                },
                                validator: (value) => value == null ? 'Please select account type' : null,
                              ),
                              SizedBox(height: fieldSpacing),
                              if (_selectedRegisterRole != UserRole.admin)
                                DropdownButtonFormField<Organization>(
                                  decoration: _buildDropdownInputDecoration('organization name*'),
                                  value: _selectedOrganizationForUser,
                                  hint: const Text('organization name'),
                                  items: _organizations.map((org) {
                                    return DropdownMenuItem<Organization>(
                                      value: org,
                                      child: Text(org.name),
                                    );
                                  }).toList(),
                                  onChanged: (Organization? newValue) {
                                    setState(() {
                                      _selectedOrganizationForUser = newValue;
                                    });
                                  },
                                  validator: (value) => value == null && _selectedRegisterRole != UserRole.admin ? 'Please select an organisation' : null,
                                )
                              else
                                const SizedBox.shrink(),
                              if (_selectedRegisterRole != UserRole.admin) SizedBox(height: fieldSpacing),
                              _buildTextField(
                                _registerUsernameController,
                                'Username*',
                                'Username',
                                TextInputType.text,
                              ),
                              SizedBox(height: fieldSpacing),
                              _buildTextField(
                                _registerNameController,
                                'Name*',
                                'Name',
                                TextInputType.text,
                              ),
                              SizedBox(height: fieldSpacing),
                              _buildTextField(
                                _registerEmailController,
                                'Email*',
                                'Email',
                                TextInputType.emailAddress,
                              ),
                              SizedBox(height: fieldSpacing),
                              _buildTextField(
                                _registerPasswordController,
                                'Password*',
                                'Password',
                                TextInputType.visiblePassword,
                                obscureText: _obscurePassword,
                                showVisibilityToggle: true,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              _buildTextField(
                                _registerConfirmPasswordController,
                                'Confirm password*',
                                'Confirm password',
                                TextInputType.visiblePassword,
                                obscureText: _obscureConfirmPassword,
                                showVisibilityToggle: true,
                                onVisibilityToggle: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_registerFormKey.currentState!.validate()) {
                                  if (_registerPasswordController.text != _registerConfirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }
                                  _registerUser();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: fieldSpacing),
                  ],
                ),
              ),
      ),
    );
  }
}