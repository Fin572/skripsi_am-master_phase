// main_screen.dart
import 'package:asset_management/screen/Invoice.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile.dart';
import 'qrscan.dart';
import 'history.dart';
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
        HomePage(username: widget.userName, password: ''), // Assuming password is not directly used in HomePage for user
        History(),
        Invoice(),
        ProfilePage(),
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
    if (index == 0) return 0;
    if (index == 1) return 1;
    if (index == 3) return 2;
    if (index == 4) return 3;
    return 0;
  }

  int _mapPageIndexToBottomIndex(int index) {
    if (index == 0) return 0;
    if (index == 1) return 1;
    if (index == 2) return 3;
    if (index == 3) return 4;
    return 0;
  }

  List<BottomNavigationBarItem> get _currentBottomNavBarItems => [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: _iconSize), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history, size: _iconSize), label: 'History'),
        const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
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
            if (index == 2) return;
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