import 'package:NutriCam/modules/account/presentation/pages/user/select_option_user.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.maxWidth / 100;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/back/back.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectOptionUser(),
                   // builder: (context) => LoginUserView(),
                  ),
                );
              },
              child: Container(
                  padding: EdgeInsets.fromLTRB(40, 240, 40, 0),
                  child: Column(
                    children: [
                      Container(
                        child: Image.asset(
                          'assets/logo/img-logo.png',
                          height: 200,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(60, 0, 40, 0),
                        child: Image.asset(
                          'assets/logo/logo-app.png',
                        ),
                      ),
                    ],
                  )
              ),
            ),
          );
        },
      ),
    );
  }
}
