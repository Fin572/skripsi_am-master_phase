import 'package:asset_management/screen/models/organization.dart';
import 'package:asset_management/screen/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import 'package:asset_management/screen/models/app_user.dart'; 

class SuperAdminRegister extends StatefulWidget {
  final List<Organization> organizations; 

  const SuperAdminRegister({Key? key, required this.organizations}) : super(key: key);

  @override
  State<SuperAdminRegister> createState() => _SuperAdminRegisterState(); 
}

class _SuperAdminRegisterState extends State<SuperAdminRegister> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _confirmPasswordController = TextEditingController(); 

  final _formKey = GlobalKey<FormState>();
  UserRole? _selectedRole; 
  Organization? _selectedOrganization;

  bool _obscurePassword = true; 
  bool _obscureConfirmPassword = true; 
  bool _isLoading = false; 

  final List<AppUser> _appUsers = [];

  List<Organization> _fetchedOrganizations = [];


  @override
  void initState() {
    super.initState();

    if (widget.organizations.isEmpty) {
      _fetchOrganizations();
    } else {
      _fetchedOrganizations = widget.organizations;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://assetin.my.id/skripsi/fetch_organizations.php'));
      print('Fetch Organizations Status: ${response.statusCode}');
      print('Fetch Organizations Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _fetchedOrganizations = data.map((item) => Organization(id: item['organization_id'], name: item['organization_name'])).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load organizations: Status ${response.statusCode}')));
      }
    } catch (e) {
      print('Fetch Organizations Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching organizations: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true; 
      });

      try {
        final response = await http.post(
          Uri.parse('http://assetin.my.id/skripsi/register_user.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _emailController.text, 
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'role': _selectedRole?.name, 
            'organization_id': _selectedOrganization?.id,
            'phone_number': _phoneController.text, 
          }),
        );

        print('Register Status Code: ${response.statusCode}');
        print('Register Response Body: ${response.body}');

        if (response.body.isEmpty || !response.body.startsWith('{')) {
          throw Exception('Invalid response from server: ${response.body}');
        }

        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'User registered successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ${_nameController.text} registered successfully!')),
          );
          _formKey.currentState!.reset(); 
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _phoneController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _selectedRole = null;
            _selectedOrganization = null;
            _obscurePassword = true; 
            _obscureConfirmPassword = true; 
          });

          final newUser = AppUser(
            id: responseData['user_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text, 
            phone: _phoneController.text,
            role: _selectedRole ?? UserRole.unknown,
            organization: _selectedRole == UserRole.customer ? _selectedOrganization : null,
          );
          _appUsers.add(newUser);

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${responseData['error'] ?? responseData['message']}')),
          );
        }
      } catch (e) {
        print('Error during registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; 
        });
      }
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
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText.replaceAll('*', ''), 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: _buildInputDecoration(labelText, hintText).copyWith(
            suffixIcon: showVisibilityToggle
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (controller == _passwordController) {
                          _obscurePassword = !_obscurePassword;
                        } else if (controller == _confirmPasswordController) {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label, // 
    required T? value,
    required String hintText,
    required List<T> items,
    String Function(T)? itemToString, 
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label.replaceAll('*', ''),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        DropdownButtonFormField<T>(
          value: value,
          decoration: _buildDropdownInputDecoration(hintText),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemToString?.call(item) ?? item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;
    final fontSize = screenSize.width * 0.045;
    final buttonHeight = screenSize.height * 0.07;
    final fieldSpacing = screenSize.height * 0.03;

    const double consistentAppBarHeight = 100.0; 

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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea( 
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column( 
                  children: [
                    Expanded( 
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey, 
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: fieldSpacing), 
                              _buildDropdownField<UserRole>(
                                label: 'Choose Level*', 
                                value: _selectedRole,
                                hintText: 'Customer/user', 
                                items: UserRole.values
                                    .where((role) => role != UserRole.unknown && role != UserRole.superAdmin)
                                    .toList(),
                                itemToString: (role) => role.name, 
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedRole = newValue;
                                    if (newValue == UserRole.admin) {
                                      _selectedOrganization = null; 
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select account type'; 
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              if (_selectedRole == UserRole.customer)
                                _buildDropdownField<Organization>(
                                  label: 'Organization name*',
                                  value: _selectedOrganization,
                                  hintText: 'organization name', 
                                  items: _fetchedOrganizations, 
                                  itemToString: (org) => org.name,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedOrganization = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null && _selectedRole == UserRole.customer) {
                                      return 'Please select an organization'; 
                                    }
                                    return null;
                                  },
                                )
                              else
                                const SizedBox.shrink(),
                              if (_selectedRole == UserRole.customer) SizedBox(height: fieldSpacing),


                              // Name
                              _buildTextField(
                                _nameController,
                                'Name*', 
                                'Name', 
                                TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Name is required';
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              // Email
                              _buildTextField(
                                _emailController,
                                'Email*', 
                                'name@example.com', 
                                TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Email is required';
                                  if (!value.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              _buildTextField(
                                _passwordController,
                                'Password*', 
                                'Minimum 6 characters', 
                                TextInputType.visiblePassword,
                                obscureText: _obscurePassword,
                                showVisibilityToggle: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Password is required';
                                  if (value.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              // Confirm Password
                              _buildTextField(
                                _confirmPasswordController,
                                'Confirm password*', 
                                '', 
                                TextInputType.visiblePassword,
                                obscureText: _obscureConfirmPassword,
                                showVisibilityToggle: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please confirm your password';
                                  if (value != _passwordController.text) return 'Passwords do not match';
                                  return null;
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
                        onPressed: _registerUser, 
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