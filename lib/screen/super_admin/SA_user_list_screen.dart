import 'package:asset_management/screen/super_admin/SA_user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/user.dart'; // Import the User model

class SAUserListScreen extends StatefulWidget {
  const SAUserListScreen({Key? key}) : super(key: key);

  @override
  State<SAUserListScreen> createState() => _SAUserListScreenState();
}

class _SAUserListScreenState extends State<SAUserListScreen> {
  // 0 for Customer, 1 for Admin
  int _selectedUserTypeIndex = 0;

  // Dummy data for Customer Users
  final List<Map<String, String>> _customerUsers = [
    {
      'name': 'Syaiful',
      'email': 'user1@user.com',
      'addedDate': '25 Jan 2025',
      'companyName': 'PT Dunia Persada', // Added
      'userId': '#000001', // Added
    },
    {
      'name': 'Dina',
      'email': 'user2@user.com',
      'addedDate': '26 Feb 2025',
      'companyName': 'PT Sejahtera Abadi', // Added
      'userId': '#000002', // Added
    },
  ];

  // Dummy data for Admin Users (Modified to include companyName and userId)
  final List<Map<String, String>> _adminUsers = [
    {
      'name': 'Margareth',
      'email': 'admin1@admin.com',
      'addedDate': '25 Jan 2025',
      'companyName': 'PT Global Tech', // Added
      'userId': '#ADMIN01', // Added
    },
    {
      'name': 'Irham',
      'email': 'admin2@admin.com',
      'addedDate': '26 Feb 2025',
      'companyName': 'PT Maju Bersama', // Added
      'userId': '#ADMIN02', // Added
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Determine which list to display based on the selected tab
    final List<Map<String, String>> displayedUsers =
        _selectedUserTypeIndex == 0 ? _customerUsers : _adminUsers;

    // Define the consistent AppBar height
    const double consistentAppBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: PreferredSize(
        // Set the preferredSize to the consistent height of 95.0
        preferredSize: const Size.fromHeight(consistentAppBarHeight),
        child: Stack(
          children: [
            // Background image that covers the entire PreferredSize area (95.0px)
            Image.asset(
              'assets/bg_image.png', // Ensure this path is correct
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
                        Navigator.pop(context); // Navigate back
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
          // Use Column to stack tabs, search bar, and content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User type tabs (Customer / Admin) - Now part of the scrollable body
            Container(
              height: 48,
              color: Colors.white, // White background for the tabs row
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
            // Search bar - Now part of the scrollable body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100, // Light grey background for search bar
                  enabledBorder: OutlineInputBorder(
                    // Border when not focused
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0), // Grey outline
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Border when focused
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: const Color.fromRGBO(52, 152, 219, 1), width: 2.0), // Blue outline when focused
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0), // Adjust padding
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Main body padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User's list summary card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.white, // Set card background to white
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
                          shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                          physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
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

  // Helper method to build count items in the summary card
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

  // Helper method to build a user list item card
  // This is the method that needs the crucial update for navigation
  Widget _buildUserListItem(Map<String, String> userMap) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white, // Set card background to white
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User icon (placeholder for now)
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
                // Create a User object from the map data BEFORE navigating
                final user = User(
                  name: userMap['name']!,
                  email: userMap['email']!,
                  companyName: userMap['companyName']!,
                  userId: userMap['userId']!,
                  addedDate: userMap['addedDate']!,
                );

                // Navigate to UserDetailScreen, passing the user object
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SAUserDetailScreen(user: user),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Remove default padding
                minimumSize: Size.zero, // Remove minimum size constraints
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min, // Wrap content tightly
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

  // Helper method for empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/nodata.png', // Make sure you have this asset
            width: 100,
          ),
          const SizedBox(height: 20), // Added SizedBox for spacing
          const Text(
            'No users found for this type.', // Added text for clarity
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}