// SA_register.dart
import 'package:asset_management/screen/models/organization.dart';
import 'package:asset_management/screen/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Preserved
import 'dart:convert'; // Preserved
import 'package:asset_management/screen/models/app_user.dart'; // Added as used in NEW UI for _appUsers list

class SuperAdminRegister extends StatefulWidget {
  final List<Organization> organizations; // Preserved required parameter

  const SuperAdminRegister({Key? key, required this.organizations}) : super(key: key);

  @override
  State<SuperAdminRegister> createState() => _SuperAdminRegisterState(); // Consistent state class name
}

class _SuperAdminRegisterState extends State<SuperAdminRegister> {
  // Controllers dari SA_register.dart asli, disesuaikan dengan kebutuhan UI baru
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // Ini adalah _usernameController dari file asli, diubah menjadi _phoneController untuk UI baru
  final _confirmPasswordController = TextEditingController(); // Dari NEW UI

  final _formKey = GlobalKey<FormState>();
  UserRole? _selectedRole; // Menggunakan UserRole enum langsung
  Organization? _selectedOrganization; // Menggunakan Organization model langsung

  bool _obscurePassword = true; // Untuk toggle visibilitas password
  bool _obscureConfirmPassword = true; // Untuk toggle visibilitas confirm password
  bool _isLoading = false; // State untuk indikator loading (dari backend asli)

  // List kosong untuk _appUsers, sesuai dengan SA_register NEW UI.dart
  // Meskipun ini adalah layar register, NEW UI-nya memiliki list ini.
  final List<AppUser> _appUsers = [];

  // Variabel untuk menyimpan organisasi yang fetched jika organizations di widget kosong
  List<Organization> _fetchedOrganizations = [];


  @override
  void initState() {
    super.initState();
    // Menggunakan organizations yang dilewatkan melalui widget
    // Jika widget.organizations kosong, baru fetch dari API
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

  // Backend: Fetch Organizations (dari SA_register.dart asli)
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


  // Backend: Register User (dari SA_register.dart asli)
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Validasi konfirmasi password (dari NEW UI)
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true; // Aktifkan loading
      });

      try {
        final response = await http.post(
          Uri.parse('http://assetin.my.id/skripsi/register_user.php'), // Endpoint backend
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            // Data yang dikirim ke backend, sesuai dengan SA_register.dart asli
            'username': _emailController.text, // Menggunakan email sebagai username untuk backend jika tidak ada field username terpisah di UI baru
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'role': _selectedRole?.name, // Menggunakan UserRole enum .name untuk string role
            'organization_id': _selectedOrganization?.id, // Menggunakan Organization model .id
            'phone_number': _phoneController.text, // Menambahkan phone number
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
          // Bersihkan semua field formulir setelah sukses
          _formKey.currentState!.reset(); // Reset form state
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _phoneController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _selectedRole = null;
            _selectedOrganization = null;
            _obscurePassword = true; // Reset password visibility
            _obscureConfirmPassword = true; // Reset confirm password visibility
          });

          // Tambahkan user baru ke _appUsers (sesuai NEW UI), jika memang untuk daftar lokal
          final newUser = AppUser(
            id: responseData['user_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text, // Peringatan: Tidak disarankan menyimpan password
            phone: _phoneController.text,
            role: _selectedRole ?? UserRole.unknown, // Pastikan role tidak null
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
          _isLoading = false; // Matikan loading
        });
      }
    }
  }


  // Helper Widgets: Input Decorations (dari NEW UI)
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

  // Helper Widget: TextField Generik (gabungan dari SA_register.dart asli & NEW UI)
  Widget _buildTextField(
      TextEditingController controller,
      String labelText, // e.g. "Name*"
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
            labelText.replaceAll('*', ''), // Hapus asterisk dari teks label di widget Text
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
                        // Toggle visibilitas berdasarkan controller yang dilewatkan
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

  // Helper Widget: Dropdown Field Generik (gabungan dari SA_register.dart asli & NEW UI)
  Widget _buildDropdownField<T>({
    required String label, // e.g. "Choose Level*"
    required T? value,
    required String hintText,
    required List<T> items,
    String Function(T)? itemToString, // Opsional: untuk tampilan item kustom
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label.replaceAll('*', ''), // Hapus asterisk dari label
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

    const double consistentAppBarHeight = 100.0; // Dari NEW UI

    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar belakang dari NEW UI
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Gambar latar belakang AppBar (dari NEW UI)
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
                      'Register', // Judul dari NEW UI
                      style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading // Indikator loading (dari backend asli)
          ? const Center(child: CircularProgressIndicator())
          : SafeArea( // Menggunakan SafeArea untuk konten body
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column( // Menggunakan Column untuk memanfaatkan Expanded dan menangani tombol di bawah
                  children: [
                    Expanded( // Membuat SingleChildScrollView mengambil semua ruang yang tersedia
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey, // Menggunakan _formKey asli
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: fieldSpacing), // Spasi atas
                              // Dropdown 1: Pilih Level (User/Customer atau Admin)
                              _buildDropdownField<UserRole>(
                                label: 'Choose Level*', // Label dari NEW UI
                                value: _selectedRole,
                                hintText: 'Customer/user', // Hint dari NEW UI
                                items: UserRole.values
                                    .where((role) => role != UserRole.unknown && role != UserRole.superAdmin) // Kecualikan unknown dan superAdmin
                                    .toList(),
                                itemToString: (role) => role.name, // Tampilkan nama enum
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedRole = newValue;
                                    if (newValue == UserRole.admin) {
                                      _selectedOrganization = null; // Kosongkan organisasi jika Admin dipilih
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select account type'; // Pesan dari NEW UI
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              // Dropdown 2: Pilih Organisasi (tergantung peran yang dipilih)
                              if (_selectedRole == UserRole.customer) // Hanya tampilkan jika peran 'User' dipilih
                                _buildDropdownField<Organization>(
                                  label: 'Organization name*', // Label dari NEW UI
                                  value: _selectedOrganization,
                                  hintText: 'organization name', // Hint dari NEW UI
                                  items: _fetchedOrganizations, // Menggunakan fetched organizations
                                  itemToString: (org) => org.name,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedOrganization = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null && _selectedRole == UserRole.customer) {
                                      return 'Please select an organization'; // Pesan dari NEW UI
                                    }
                                    return null;
                                  },
                                )
                              else
                                const SizedBox.shrink(),
                              // Spasi hanya jika dropdown organisasi ditampilkan
                              if (_selectedRole == UserRole.customer) SizedBox(height: fieldSpacing),


                              // Name
                              _buildTextField(
                                _nameController,
                                'Name*', // Label dari NEW UI
                                'Name', // Hint dari NEW UI
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
                                'Email*', // Label dari NEW UI
                                'Email', // Hint dari NEW UI
                                TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Email is required';
                                  if (!value.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              // Password
                              _buildTextField(
                                _passwordController,
                                'Password*', // Label dari NEW UI
                                'Password', // Hint dari NEW UI
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
                                'Confirm password*', // Label dari NEW UI
                                'Confirm password', // Hint dari NEW UI
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

                              // Phone Number - Ditambahkan kembali dari SA_register.dart asli
                              _buildTextField(
                                _phoneController,
                                'Phone Number*', // Label dari asli
                                'Enter phone number', // Hint dari asli
                                TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Phone number is required';
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing), // Spasi setelah phone number
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Tombol Register ditempatkan langsung di Column utama
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _registerUser, // Menggunakan _registerUser asli untuk interaksi backend
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Dari NEW UI
                          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02), // Padding responsif
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Dari NEW UI
                          ),
                        ),
                        child: _isLoading // Tampilkan indikator loading jika sedang sibuk
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Register', // Teks dari NEW UI
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize, // Ukuran font responsif
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: fieldSpacing), // Spasi di bawah tombol
                  ],
                ),
              ),
            ),
    );
  }
}