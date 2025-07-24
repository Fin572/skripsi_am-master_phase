// auth_screen.dart
import 'package:asset_management/screen/admin/admin_main_screen.dart';
import 'package:asset_management/screen/main_screen.dart';
import 'package:asset_management/screen/models/user_role.dart';
import 'package:asset_management/screen/super_admin/SA_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for json decoding

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Renamed _loginController to _emailController for NEW UI consistency
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  // Renamed _loginError to _emailError for NEW UI consistency
  bool _emailError = false;
  bool _passwordError = false;

  void showComingSoonPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Coming Soon"),
        content: const Text("Fitur ini sedang dalam pengembangan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Future<void> loginUser() async {
    // Trim the input to remove any leading/trailing whitespace
    final login = _emailController.text.trim(); // Use _emailController for 'login' parameter
    final password = _passwordController.text.trim();

    // Reset error states before new login attempt
    setState(() {
      _emailError = false;
      _passwordError = false;
    });

    final response = await http.post(
      Uri.parse('http://assetin.my.id/skripsi/login.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'login': login,
        'password': password,
      },
    );

    final data = json.decode(response.body);

    if (data['status'] == 'success') {
      String role = data['role'];
      String organizationName = data['organization_name']; // Extract organization_name from response
      // Assuming 'email' is also returned from the API for each user.
      String userEmail = data['email'] ?? '$login@example.com'; // Use actual email if provided, else construct one
      Widget targetScreen;

      // Redirect based on role
      if (role == 'customer') {
        targetScreen = MainScreen(
          userName: login,
          userEmail: userEmail,
          userRole: UserRole.customer,
          organizationName: organizationName, // Pass the extracted organizationName
        );
      } else if (role == 'admin') {
        targetScreen = AdminMainScreen(
          userName: login,
          userEmail: userEmail,
          userRole: UserRole.admin,
        );
      } else if (role == 'super_admin') {
        targetScreen = SuperAdminMainScreen(
          userName: login,
          userEmail: userEmail,
          userRole: UserRole.superAdmin,
        );
      } else {
        // Handle unknown role
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown role: $role')),
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => targetScreen),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _emailError = true; // Set _emailError for login failure
        _passwordError = true; // Set _passwordError for login failure
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration( // Changed to const
          image: DecorationImage(
            image: AssetImage('assets/auth.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Assetin',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40), // From NEW UI
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24), // From NEW UI
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ), // From NEW UI
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // From NEW UI
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8), // From NEW UI
                        const Text.rich( // Changed to const
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 158, 158, 158),
                                ),
                              ),
                              TextSpan(
                                text: 'Assetin',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        // Email Field - Now uses _emailController
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: const TextSpan( // Changed to const
                              text: 'Email ', // From NEW UI
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4), // From NEW UI
                        TextFormField(
                          controller: _emailController, // Using _emailController
                          decoration: InputDecoration(
                            hintText: 'Email', // From NEW UI
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (_emailError) // Using _emailError
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Wrong Email', // From NEW UI
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16), // From NEW UI
                        // Password Field
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: const TextSpan( // Changed to const
                              text: 'Password', // From NEW UI
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4), // From NEW UI
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password', // From NEW UI
                            filled: true,
                            fillColor: Colors.grey[100],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => showComingSoonPopup(context),
                              child: const Text(
                                'Forgot Password?', // From NEW UI
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            if (_passwordError)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  'Wrong Password', // From NEW UI
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 40), // From NEW UI
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(52, 152, 219, 1), // From NEW UI
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14), // From NEW UI
                            ),
                          ),
                          onPressed: loginUser, // Uses the preserved loginUser method
                          child: const Text(
                            'Login', // From NEW UI
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24), // From NEW UI

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}