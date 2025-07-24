import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected, required String role, required Null Function() onFabPressed,
  });

  int _mapPageIndexToBottomIndex(int index) {
    if (index == 0) return 0;
    if (index == 1) return 1;
    if (index == 2) return 3; // Index 2 in page is actually 3rd item in bottom nav (Invoice)
    if (index == 3) return 4; // Index 3 in page is actually 4th item in bottom nav (Profile)
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(), // 👈 supports FAB notch
      notchMargin: 8.0,
      child: BottomNavigationBar(
        currentIndex: _mapPageIndexToBottomIndex(selectedIndex),
        onTap: (bottomIndex) {
          if (bottomIndex == 2) return; // Skip FAB slot
          onTabSelected(bottomIndex);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(), // Middle space for FAB
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}