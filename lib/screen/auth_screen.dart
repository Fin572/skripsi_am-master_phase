import 'package:asset_management/screen/admin/admin_main_screen.dart';
import 'package:asset_management/screen/main_screen.dart';
import 'package:asset_management/screen/models/user_role.dart';
import 'package:asset_management/screen/super_admin/SA_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
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
    final login = _emailController.text.trim(); 
    final password = _passwordController.text.trim();

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
      String organizationName = data['organization_name'];
      String userEmail = data['email'] ?? '$login@example.com'; 
      Widget targetScreen;

      if (role == 'customer') {
        targetScreen = MainScreen(
          userName: login,
          userEmail: userEmail,
          userRole: UserRole.customer,
          organizationName: organizationName, 
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
        _emailError = true; 
        _passwordError = true; 
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
        decoration: const BoxDecoration( 
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
                const SizedBox(height: 40), 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24), 
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ), 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), 
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
                        const SizedBox(height: 8), 
                        const Text.rich( 
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: const TextSpan( 
                              text: 'Email ', 
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
                        const SizedBox(height: 4), 
                        TextFormField(
                          controller: _emailController, 
                          decoration: InputDecoration(
                            hintText: 'Email', 
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (_emailError) 
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Wrong Email',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16), 
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: const TextSpan(
                              text: 'Password', 
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
                        const SizedBox(height: 4), 
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password', 
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
                                'Forgot Password?', 
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            if (_passwordError)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  'Wrong Password', 
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14), 
                            ),
                          ),
                          onPressed: loginUser,
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24), 

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