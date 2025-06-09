// lib/screen/super_admin/super_admin_main_screen.dart
import 'package:asset_management/screen/models/user_role.dart';
import 'package:asset_management/screen/qrscan.dart';
import 'package:asset_management/screen/super_admin/SA_history.dart';
import 'package:asset_management/screen/super_admin/SA_invoice.dart';
import 'package:asset_management/screen/super_admin/SA_profile.dart';
import 'package:asset_management/screen/super_admin/SA_home_page.dart';
import 'package:asset_management/widgets/bottom_app_bar.dart';
import 'package:flutter/material.dart';

class SuperAdminMainScreen extends StatefulWidget {
  final String userName;
  final UserRole userRole;

  const SuperAdminMainScreen({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<SuperAdminMainScreen> createState() => _SuperAdminMainScreenState();
}

class _SuperAdminMainScreenState extends State<SuperAdminMainScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == 2) return; // Skip the FAB placeholder slot
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Map the selectedIndex to the correct page index, skipping the FAB slot
    final List<Widget> _pages = [
      SuperAdminHomePage(userName: widget.userName, userRole: widget.userRole, userEmail: '',),
      SuperAdminHistory(userName: widget.userName, userRole: widget.userRole,userEmail: '',),
      Container(), // Placeholder for FAB slot
      SuperAdminInvoice(userName: widget.userName, userRole: widget.userRole,userEmail: '',),
      SuperAdminProfile(userName: widget.userName, userRole: widget.userRole,userEmail: '',),
    ];

    // Adjust the index to skip the FAB slot
    int pageIndex = _selectedIndex;
    if (_selectedIndex > 2) {
      pageIndex = _selectedIndex - 1;
    }

    return Scaffold(
      body: _pages[pageIndex], // Display the selected page
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QrScannerPage()),
          );
        },
        role: 'super_admin', // Set role for super admin-specific navbar customization
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QrScannerPage()),
            );
          },
          backgroundColor: Colors.blue,
          elevation: 3,
          child: const Icon(Icons.qr_code, color: Colors.white, size: 30),
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}