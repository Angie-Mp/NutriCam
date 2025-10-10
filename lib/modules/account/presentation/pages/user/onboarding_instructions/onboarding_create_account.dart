import 'package:NutriCam/modules/account/presentation/pages/user/create_account/create_account.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';
import 'package:flutter/material.dart';
import 'package:NutriCam/core/values/colors.dart';

class OnboardingCreateAccount extends StatefulWidget {
  const OnboardingCreateAccount({Key? key}) : super(key: key);

  @override
  State<OnboardingCreateAccount> createState() => _OnboardingCreateAccountState();
}

class _OnboardingCreateAccountState extends State<OnboardingCreateAccount> {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'imageIcon': 'assets/iconos/onbording1.png',
      'text': 'Hola! Felicidades por dar el primer paso',
    },
    {
      'imageIcon': 'assets/iconos/onbording2.png',
      'text': 'Cuando se trata de nutrición, encontrar lo que funciona para ti marca la diferencia.',
    },
    {
      'imageIcon': 'assets/iconos/onbording3.png',
      'text': 'Eres únic@ ❤️, también lo es nuestro programa.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final size = constraints.maxWidth / 100;
              return Scaffold(
                body: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = onboardingData[index];
                        return Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/back/back3.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logo/logo-app.png',
                                width: 190,
                              ),
                              Image.asset(
                                item['imageIcon']!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  item['text']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: colorBlack,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 180),
                            ],
                          ),
                        );
                      },
                    ),
                    //boton empezar
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          //indicadores
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              onboardingData.length,
                                  (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                width: currentPage == index ? 16 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentPage == index
                                      ? colorOrange
                                      : colorGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          //boton siguiente
                          if (currentPage == onboardingData.length - 1)
                            CustomButton(
                              text: 'Siguiente',
                              backgroundColor: colorPurple,
                              textColor: colorWhite1,
                              width: size * 70,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CreateAccount()
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
        )
    );
  }
}
