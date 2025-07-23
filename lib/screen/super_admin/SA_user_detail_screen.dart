// SA_user_detail_screen.dart
import 'package:asset_management/screen/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Preserved
import 'dart:convert'; // Preserved

class SAUserDetailScreen extends StatefulWidget {
  final Map<String, String> user; // Changed to Map<String, String> to match NEW UI

  const SAUserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SAUserDetailScreen> createState() => _SAUserDetailScreenState();
}

class _SAUserDetailScreenState extends State<SAUserDetailScreen> {
  // Using late to initialize _currentUser from widget.user in initState
  late Map<String, String> _currentUser;
  bool _isLoading = false; // Preserved for API calls

  @override
  void initState() {
    super.initState();
    _currentUser = Map<String, String>.from(widget.user);
    _fetchUserDetail(); // Preserved API call
  }

  Future<void> _fetchUserDetail() async { // Preserved
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/get_user_detail.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': _currentUser['id']}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _currentUser = Map<String, String>.from(data['user_data'].map((k, v) => MapEntry(k.toString(), v.toString())));
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch user detail: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserRole(UserRole newRole) async { // Preserved
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/update_user_role.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _currentUser['id'],
          'user_role': newRole.name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User role updated to ${newRole.name} successfully!')),
          );
          _fetchUserDetail(); // Refresh data after update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update role: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser() async { // Preserved
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete user ${_currentUser['name']}?'),
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

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await http.post(
          Uri.parse('http://assetin.my.id/skripsi/delete_user.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': _currentUser['id']}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User ${_currentUser['name']} deleted successfully!')),
            );
            Navigator.of(context).pop(); // Go back to previous screen (user list)
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete user: ${data['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode} - ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showComingSoonPopup(BuildContext context) {
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double consistentAppBarHeight = 100.0; // Standard height for image app bars

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'User Detail',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading // Preserved loading indicator
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/profile.png'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentUser['name'] ?? 'N/A',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currentUser['email'] ?? 'N/A',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow('User ID', _currentUser['id'] ?? 'N/A'),
                          _buildInfoRow('Phone', _currentUser['phone'] ?? 'N/A'),
                          _buildInfoRow('Role', _currentUser['role'] ?? 'N/A'),
                          if (_currentUser['organization_name'] != null && _currentUser['organization_name']!.isNotEmpty)
                            _buildInfoRow('Organization', _currentUser['organization_name']!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showComingSoonPopup(context), // Linked to coming soon as per NEW UI
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Edit User',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showComingSoonPopup(context), // Linked to coming soon as per NEW UI
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _deleteUser, // Preserved
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Delete User',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}