
import 'package:NutriCam/modules/account/presentation/pages/user/create_account/create_dates_user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_onboarding/button_options_user.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';

class CreateSelectOption extends StatefulWidget {
  const CreateSelectOption({super.key});

  @override
  State<CreateSelectOption> createState() => _CreateSelectOptionState();
}

class _CreateSelectOptionState extends State<CreateSelectOption> {
  String nombre = '';
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('nombre') ?? '';
    });
  }

// Selecciona una opción
  void selectOptionObjetive(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth / 100;
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/back/back2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/logo/img-logo.png', width: 70),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Hola',
                                  style: TextStyle(
                                    color: colorBlack,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' $nombre',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: colorOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Cuál es tu objetivo?',
                              style: TextStyle(fontSize: 14, color: colorBlack),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

// Botones de opciones
                    ButtonOptionsUser(
                      onTap: () => selectOptionObjetive('Perder peso sanamente'),
                      height: size * 17,
                      width: size * 80,
                      color: selectedOption == 'Perder peso sanamente'
                          ? colorBlue1
                          : colorGray2,
                      text: 'Perder peso sanamente',
                      colorText: colorBlack,
                    ),
                    const SizedBox(height: 10),
                    ButtonOptionsUser(
                      onTap: () => selectOptionObjetive(
                          'Ganar masa muscular y reducir grasa corporal'),
                      height: size * 17,
                      width: size * 80,
                      color: selectedOption ==
                          'Ganar masa muscular y reducir grasa corporal'
                          ? colorBlue1
                          : colorGray2,
                      text: 'Ganar masa muscular y reducir grasa corporal',
                      colorText: colorBlack,
                    ),
                    const SizedBox(height: 10),
                    ButtonOptionsUser(
                      onTap: () => selectOptionObjetive(
                          'Ganar masa muscular y de forma secundaria, reducir grasa corporal'),
                      height: size * 17,
                      width: size * 80,
                      color: selectedOption ==
                          'Ganar masa muscular y de forma secundaria, reducir grasa corporal'
                          ? colorBlue1
                          : colorGray2,
                      text:
                      'Ganar masa muscular y de forma secundaria, reducir grasa corporal',
                      colorText: colorBlack,
                    ),
                    const SizedBox(height: 10),
                    ButtonOptionsUser(
                      onTap: () =>
                          selectOptionObjetive('Comer más saludable sin perder peso'),
                      height: size * 17,
                      width: size * 80,
                      color: selectedOption ==
                          'Comer más saludable sin perder peso'
                          ? colorBlue1
                          : colorGray2,
                      text: 'Comer más saludable sin perder peso',
                      colorText: colorBlack,
                    ),
                    const SizedBox(height: 70),

// Botón siguiente
                    CustomButton(
                      text: 'Siguiente',
                      backgroundColor: colorPurple,
                      textColor: colorWhite1,
                      width: size * 70,
                      onPressed: () async {
                        if (selectedOption == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor selecciona un objetivo'),
                            ),
                          );
                          return;
                        }
                        await saveUserObjective();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateDatesUser()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// Guarda objetivo y tipoMeta
  Future<void> saveUserObjective() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('objetivo', selectedOption ?? '');

// Nuevo campo: tipoMeta (bajar, subir o mantener)
    String tipoMeta = '';
    if (selectedOption == 'Perder peso sanamente') {
      tipoMeta = 'bajar';
    } else if (selectedOption ==
        'Ganar masa muscular y reducir grasa corporal' ||
        selectedOption ==
            'Ganar masa muscular y de forma secundaria, reducir grasa corporal') {
      tipoMeta = 'subir';
    } else {
      tipoMeta = 'mantener';
    }

    await prefs.setString('tipoMeta', tipoMeta);
  }
}

