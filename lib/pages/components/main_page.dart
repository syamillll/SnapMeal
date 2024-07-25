import 'package:flutter/material.dart';
import 'package:snapmeal/pages/components/bottom_nav_bar.dart';
import 'package:snapmeal/pages/favorite/favourite_page.dart';
import 'package:snapmeal/pages/menu/menu_page.dart';
import 'package:snapmeal/pages/scan/scan_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ScanPage(),
    const MenuPage(),
    const FavoritePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
