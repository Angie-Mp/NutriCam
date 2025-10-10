import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/presentation/pages/user/create_account/create_select_option.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_input_account.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> saveUserDataLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', nombreController.text);
    await prefs.setString('apellido', apellidoController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.maxWidth / 100;
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/back/back4.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 130),
                        Image.asset(
                          'assets/iconos/verduras.png',
                          width: 120,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Crear tu cuenta',
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: colorBlack),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Regístrate para guardar tu información',
                          style: TextStyle(fontSize: 15, color: colorBlack),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: size * 80,
                          child: Column(
                            children: [
                              WidgetInputAccount(
                                textTitleInput: 'Nombre',
                                controller: nombreController,
                              ),
                              WidgetInputAccount(
                                textTitleInput: 'Apellido',
                                controller: apellidoController,
                              ),
                              WidgetInputAccount(
                                textTitleInput: 'Correo electrónico',
                                controller: emailController,
                              ),
                              WidgetInputAccount(
                                textTitleInput: 'Contraseña',
                                controller: passwordController,
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Siguiente',
                          backgroundColor: colorPurple,
                          textColor: colorWhite1,
                          width: size * 70,
                          onPressed: buttonNextPage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //function boton
  void buttonNextPage() async {
    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validaciones
    if (nombre.isEmpty || apellido.isEmpty || email.isEmpty || password.isEmpty) {
      ToastWidget().toastError('Por favor completa todos los campos');
      return;
    }
    if (password.length < 8) {
      ToastWidget().toastError('La contraseña debe tener al menos 8 caracteres');
      return;
    }
    //guard sharedPreference
    await saveUserDataLocal();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateSelectOption(),
      ),
    );
  }
}
