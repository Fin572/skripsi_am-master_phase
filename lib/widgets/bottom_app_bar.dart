import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onFabPressed;

  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onFabPressed,
  });

  int _mapPageIndexToBottomIndex(int index) {
    if (index == 0) return 0;
    if (index == 1) return 1;
    if (index == 2) return 3;
    if (index == 3) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: null,
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
            icon: SizedBox.shrink(),
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
