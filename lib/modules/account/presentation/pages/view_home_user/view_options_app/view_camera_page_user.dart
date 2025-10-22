import 'package:NutriCam/modules/account/presentation/widgets/widget_menu_page/widget_info_camera_photo.dart';
import 'package:flutter/material.dart';
import 'package:NutriCam/core/values/colors.dart';

class ViewCameraPageUser extends StatelessWidget {
  const ViewCameraPageUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: colorYellow,
            padding: const EdgeInsets.fromLTRB(15, 35, 0, 0),
            child: Row(
              children: [
                Image.asset('assets/logo/logo-app.png', height: 50),
              ],
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: WidgetInfoCameraPhoto(),
            ),
          ),
        ],
      ),
    );
  }
}
