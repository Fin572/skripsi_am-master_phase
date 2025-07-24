// main_screen.dart
import 'package:asset_management/screen/user_invoice.dart'; // Corrected import for UserInvoice
import 'package:flutter/material.dart';
import 'package:asset_management/screen/home_page.dart'; // Corrected import for UserHomePage
import 'package:asset_management/screen/profile.dart'; // Corrected import for UserProfile
import 'package:asset_management/screen/qrscan.dart'; // Ensure qrscan.dart exists in 'screen'
import 'package:asset_management/screen/history.dart'; // Corrected import for History
import 'package:asset_management/screen/models/user_role.dart'; // Import UserRole

class MainScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final UserRole userRole;

  const MainScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  List<Widget> get _userPages => [
    // FIX: Pass all required parameters to UserHomePage
    UserHomePage(
      userName: widget.userName,
      userEmail: widget.userEmail,
      userRole: widget.userRole,
    ),
    // History() constructor has no required parameters based on provided code,
    // so this line remains correct.
    History(),
    // FIX: Changed Invoice() to UserInvoice() and pass all required parameters
    UserInvoice(
      userName: widget.userName,
      userEmail: widget.userEmail,
      userRole: widget.userRole,
    ),
    // FIX: Pass all required parameters to UserProfile
    UserProfile(
      userName: widget.userName,
      userEmail: widget.userEmail,
      userRole: widget.userRole,
    ),
  ];

  // This should not be accessed for a 'user' MainScreen, but kept for consistency if needed in future.
  List<Widget> get _currentPages {
    return _userPages;
  }

  double get _iconSize => MediaQuery.of(context).size.width > 600 ? 32.0 : 24.0;
  double get _fabSize => MediaQuery.of(context).size.width > 600 ? 70.0 : 56.0;

  EdgeInsets get _fabPadding {
    final screenHeight = MediaQuery.of(context).size.height;
    return EdgeInsets.only(
      top: screenHeight * 0.08,
      bottom: screenHeight * 0.01,
    );
  }

  int _mapBottomIndexToPageIndex(int index) {
    if (index == 2) return _pageIndex; // The "empty" slot for FAB
    if (index == 0) return 0; // Home
    if (index == 1) return 1; // History
    if (index == 3) return 2; // Invoice (was at bottom nav index 3, maps to page 2)
    if (index == 4) return 3; // Profile (was at bottom nav index 4, maps to page 3)
    return 0; // Default to Home
  }

  int _mapPageIndexToBottomIndex(int index) {
    if (index == 0) return 0; // Home
    if (index == 1) return 1; // History
    if (index == 2) return 3; // Invoice (page 2 maps to bottom nav index 3)
    if (index == 3) return 4; // Profile (page 3 maps to bottom nav index 4)
    return 0; // Default to Home
  }

  List<BottomNavigationBarItem> get _currentBottomNavBarItems => [
    BottomNavigationBarItem(icon: Icon(Icons.home, size: _iconSize), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.history, size: _iconSize), label: 'History'),
    const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''), // FAB placeholder
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long, size: _iconSize), label: 'Invoice'),
    BottomNavigationBarItem(icon: Icon(Icons.person, size: _iconSize), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _currentPages[_pageIndex]),
      floatingActionButton: Padding(
        padding: _fabPadding,
        child: SizedBox(
          width: _fabSize,
          height: _fabSize,
          child: FloatingActionButton(
            onPressed: () {
              // Ensure QrScannerPage is imported correctly
              Navigator.push(context, MaterialPageRoute(builder: (context) => QrScannerPage()));
            },
            backgroundColor: Colors.blue,
            elevation: 3,
            shape: const CircleBorder(),
            child: Icon(Icons.qr_code, color: Colors.white, size: _iconSize * 1.2),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: BottomNavigationBar(
          currentIndex: _mapPageIndexToBottomIndex(_pageIndex),
          onTap: (index) {
            if (index == 2) return; // Ignore tap on FAB placeholder
            setState(() => _pageIndex = _mapBottomIndexToPageIndex(index));
          },
          type: BottomNavigationBarType.fixed,
          items: _currentBottomNavBarItems,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          backgroundColor: Colors.white,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}