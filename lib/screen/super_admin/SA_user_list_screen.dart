// lib/screens/super_admin/SA_user_list_screen.dart
import 'package:asset_management/screen/super_admin/SA_user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/user.dart'; 

class SAUserListScreen extends StatefulWidget {
  const SAUserListScreen({Key? key}) : super(key: key);

  @override
  State<SAUserListScreen> createState() => _SAUserListScreenState();
}

class _SAUserListScreenState extends State<SAUserListScreen> {
  int _selectedUserTypeIndex = 0;

  final List<Map<String, String>> _customerUsers = [
    {
      'name': 'Syaiful',
      'email': 'user1@user.com',
      'addedDate': '25 Jan 2025',
      'companyName': 'PT Dunia Persada',
      'userId': '#000001',
    },
    {
      'name': 'Dina',
      'email': 'user2@user.com',
      'addedDate': '26 Feb 2025',
      'companyName': 'PT Sejahtera Abadi', 
      'userId': '#000002', 
    },
  ];

  final List<Map<String, String>> _adminUsers = [
    {
      'name': 'Margareth',
      'email': 'admin1@admin.com',
      'addedDate': '25 Jan 2025',
      'companyName': 'PT Global Tech', 
      'userId': '#ADMIN01', 
    },
    {
      'name': 'Irham',
      'email': 'admin2@admin.com',
      'addedDate': '26 Feb 2025',
      'companyName': 'PT Maju Bersama', 
      'userId': '#ADMIN02', 
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> displayedUsers =
        _selectedUserTypeIndex == 0 ? _customerUsers : _adminUsers;

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'User',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              color: Colors.white, 
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUserTypeIndex = 0;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedUserTypeIndex == 0 ? const Color.fromRGBO(52, 152, 219, 1) : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Customer',
                          style: TextStyle(
                            color: _selectedUserTypeIndex == 0 ? const Color.fromRGBO(52, 152, 219, 1) : Colors.grey[600],
                            fontWeight: _selectedUserTypeIndex == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUserTypeIndex = 1;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedUserTypeIndex == 1 ? const Color.fromRGBO(52, 152, 219, 1) : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: _selectedUserTypeIndex == 1 ? const Color.fromRGBO(52, 152, 219, 1) : Colors.grey[600],
                            fontWeight: _selectedUserTypeIndex == 1 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100, 
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1), width: 2.0), 
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0), 
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.white, 
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "User's list",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Period 1 Jan 2025 - 30 Dec 2025',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCountItem('Total', (_customerUsers.length + _adminUsers.length).toString()),
                              _buildCountItem('Customer', _customerUsers.length.toString()),
                              _buildCountItem('Admin', _adminUsers.length.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Displayed users list
                  displayedUsers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true, 
                          physics: const NeverScrollableScrollPhysics(), 
                          itemCount: displayedUsers.length,
                          itemBuilder: (context, index) {
                            final user = displayedUsers[index];
                            return _buildUserListItem(user);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromRGBO(52, 152, 219, 1)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUserListItem(Map<String, String> userMap) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white, 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userMap['name']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userMap['email']!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Added from ${userMap['addedDate']!}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                final userObject = User( 
                  name: userMap['name']!,
                  email: userMap['email']!,
                  companyName: userMap['companyName']!,
                  userId: userMap['userId']!,
                  addedDate: userMap['addedDate']!,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SAUserDetailScreen(user: userObject),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, 
                minimumSize: Size.zero, 
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detail',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/nodata.png',
            width: 100,
          ),
          const SizedBox(height: 20), 
          const Text(
            'No users found for this type.', 
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}