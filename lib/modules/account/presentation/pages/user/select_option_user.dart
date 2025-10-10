import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/presentation/pages/user/login_user_view.dart';
import 'package:NutriCam/modules/account/presentation/pages/user/onboarding_instructions/onboarding_create_account.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';
import 'package:flutter/material.dart';

class SelectOptionUser extends StatelessWidget {
  const SelectOptionUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.maxWidth / 100;
          return Container(
            width: size * 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/back/back2.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/logo/logo-img-app.png',
                            height: 70,
                          ),
                        ],
                      )
                    ),
                    const SizedBox(
                      height: 130,
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           const Text(
                            '¡Comencemos juntos este viaje saludable! \n 🥗🍶🥕🧀',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                color: colorPurple,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          CustomButton(
                            text: 'Iniciar sesión',
                            backgroundColor: colorPurple,
                            textColor: colorWhite1,
                            width: size * 70,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginUserView()
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            text: 'Crear Cuenta',
                            backgroundColor: colorPurple,
                            textColor: colorWhite1,
                            width: size * 70,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const OnboardingCreateAccount()
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                )
            ),
          );
        },
      ),
    );
  }
}
