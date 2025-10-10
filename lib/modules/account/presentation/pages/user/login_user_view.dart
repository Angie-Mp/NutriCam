import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:NutriCam/modules/account/presentation/pages/view_home_user/home_page_admi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_input_account.dart';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/core/values/colors.dart';

class LoginUserView extends StatelessWidget {
  LoginUserView({super.key});

  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Consumer<NutriScamModuleProvider>(
      builder: (context, provider, child) => Scaffold(
        body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.maxWidth / 100;
          return Container(
            width: size * 100,
           // height: size * 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/back/back4.png'),
                fit: BoxFit.cover,
              ),
            ),
           child: Container(
             padding: const EdgeInsets.all(20),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const SizedBox(height: 120),
                 Image.asset(
                     'assets/iconos/verduras.png',
                   height: 150,
                 ),
                 const SizedBox(height: 20),
                 const Text(
                     'Inicia sesión',
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold
                   ),
                 ),
                 const SizedBox(height: 10),
                 const Text(
                   'Hola ¿Qué tal cómo has estado?',
                   style: TextStyle(
                       fontSize: 17,
                   ),
                 ),
                 const SizedBox(height: 40),
                 WidgetInputAccount(
                   textTitleInput: 'Ingresar correo',
                   controller: userController,
                 ),
                 WidgetInputAccount(
                   textTitleInput: 'Ingresar contraseña',
                   controller: passwordController,
                   obscureText: true,
                 ),
                 const SizedBox(height: 70),
                 if (provider.loading) const Center(child: CircularProgressIndicator()),
                 Center(
                   child: CustomButton(
                     text: 'Iniciar sesión',
                     backgroundColor: colorPurple,
                     textColor: Colors.white,
                     width: width * 0.6,
                     onPressed: () => buttonLoginFunction(context, provider),
                   ),
                 ),

               ],
             ),
           ),
          );

        }
      ),
    )
    );
  }

  //button iniciar sesion
  Future<void> buttonLoginFunction(BuildContext context, NutriScamModuleProvider provider) async {
    final email = userController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ToastWidget().toastError("Por favor ingresa correo y contraseña");
      return;
    }

    final success = await provider.loginUserAccount(email, password);
    if (success) {
      ToastWidget().toastSuccess('Sesión iniciada correctamente');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageAdmi()),
      );
    }
  }
}
