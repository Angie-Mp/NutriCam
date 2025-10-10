import 'package:NutriCam/modules/account/presentation/pages/view_home_user/home_page_admi.dart';
import 'package:NutriCam/modules/account/presentation/pages/view_home_user/photo_view_admi.dart';
import 'package:flutter/material.dart';

class ViewMainUser extends StatefulWidget {
  const ViewMainUser({super.key});

  @override
  State<ViewMainUser> createState() => _ViewMainUserState();
}

class _ViewMainUserState extends State<ViewMainUser> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageAdmi(),        // Página inicial
     TakePhotoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Tomar Foto',
          ),
        ],
      ),
    );
  }
}
