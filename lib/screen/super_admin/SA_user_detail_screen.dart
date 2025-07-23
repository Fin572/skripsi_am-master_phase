import 'package:flutter/material.dart';
import 'package:asset_management/screen/models/user.dart'; // Import the User model

class SAUserDetailScreen extends StatelessWidget {
  final User user; // The user object passed from the previous screen

  const SAUserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the consistent AppBar height
    const double consistentAppBarHeight = 95.0;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: PreferredSize(
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Profile Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.white, // Set card background to white
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Company Info List Tile (contained within a single Card now)
              Card(
                elevation: 2, // Added elevation back for a card effect
                margin: EdgeInsets.zero, // No margin as they connect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Overall card border
                ),
                color: Colors.white, // Set card background to white
                child: Column(
                  children: [
                    _buildDetailTile(
                      icon: Icons.business,
                      label: user.companyName,
                      isFirst: true, // Apply top border radius
                    ),
                    _buildDetailTile(
                      icon: Icons.person, // Assuming this is for user ID, consistent with `person` icon
                      label: user.userId,
                      isLast: true, // Apply bottom border radius
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Spacing before the button

              // Delete User Button
              SizedBox(
                width: double.infinity, // Make button full width
                child: ElevatedButton(
                  onPressed: () {
                    // Implement delete user logic here
                    // Show a confirmation dialog before deleting
                    _showDeleteConfirmationDialog(context, user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255), // White background
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Red text from design, matching common delete color
                    side: const BorderSide(color: Color.fromARGB(255, 219, 219, 219), width: 1), // Red border
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0, // No shadow
                  ),
                  child: const Text(
                    'Delete user',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build detail tiles
  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the tile
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(10))
            : isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(10))
                : BorderRadius.zero,
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation dialog for deleting a user
  void _showDeleteConfirmationDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          backgroundColor: const Color.fromARGB(245,245,245, 245),
          content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 0, 0, 0)),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 0, 0, 0)),
              child: const Text('Delete'),
              onPressed: () {
                // Implement actual delete logic here
                print('Deleting user: ${user.name}');
                // After successful deletion, you might want to:
                // 1. Pop this screen off the stack
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.of(context).pop(); // Go back to the UserListScreen
                // 2. Potentially show a success message on the UserListScreen
                // (You would need to pass a callback or use a state management solution for this)
              },
            ),
          ],
        );
      },
    );
  }
}