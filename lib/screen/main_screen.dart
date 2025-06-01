import 'package:asset_management/screen/Invoice.dart';
import 'package:asset_management/widgets/bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile.dart';
import 'qrscan.dart';
import 'history.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final String password;

  const MainScreen({Key? key, required this.username, required this.password}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(username: widget.username, password: widget.password),
      History(),
      Container(),
      Invoice(),
      ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Add Action'),
              content: Text('FAB action placeholder'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Add Action'),
              content: Text('FAB action placeholder'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
