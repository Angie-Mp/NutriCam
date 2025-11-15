import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/presentation/pages/view_home_user/view_options_app/view_camera_page_user.dart';
import 'package:NutriCam/modules/account/presentation/pages/view_home_user/view_options_app/view_menu_page_user.dart';
import 'package:NutriCam/modules/account/presentation/pages/view_home_user/view_options_app/view_perfil_page.dart';
import 'package:flutter/material.dart';

class HomePageAdmi extends StatefulWidget {
  const HomePageAdmi({super.key});

  @override
  State<HomePageAdmi> createState() => _HomePageAdmiState();
}

class _HomePageAdmiState extends State<HomePageAdmi> {
  int selectedIndex = 0;

  final List<Widget> selectPages = [
    ViewMenuPageUser(),
    ViewCameraPageUser(),
    ViewPerfilPage(),
  ];

  void onTapOptionButtons(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectPages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: colorWhite1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onTapOptionButtons,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: colorPurple,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Image.asset(
                      'assets/iconos/button_navigator/home.png',
                      height: selectedIndex == 0 ? 40 : 30,
                    ),
                  ),
                  label: 'Menú',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Image.asset(
                      'assets/iconos/button_navigator/camara.png',
                      height: selectedIndex == 1 ? 40 : 30,
                    ),
                  ),
                  label: 'Tomar foto',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Image.asset(
                      'assets/iconos/button_navigator/perfil.png',
                      height: selectedIndex == 2 ? 40 : 30,
                    ),
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
