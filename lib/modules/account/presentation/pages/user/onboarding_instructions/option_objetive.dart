/*
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/presentation/pages/view_main_user/view_main_user.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_onboarding/button_options_user.dart';

class ViewObjetiveUser extends StatelessWidget {
  const ViewObjetiveUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final provider = Provider.of<NutriScamModuleProvider>(context);

    return Scaffold(
      body: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(20, 200, 20, 20),
        child: Column(
          children: [
            Container(height: 140, width: 140, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Cuál es tu objetivo?',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ButtonOptionsUser(
              onTap: () => selectionOptionObjetive(context, 'Perder peso sanamente'),
              height: width * 0.1,
              width: width * 60,
              color: Colors.blue,
              text: 'Perder peso sanamente',
              colorText: Colors.black,
            ),
            ButtonOptionsUser(
              onTap: () => selectionOptionObjetive(context, 'Ganar masa muscular'),
              height: width * 0.1,
              width: width * 60,
              color: Colors.blue,
              text: 'Ganar masa muscular',
              colorText: Colors.black,
            ),
            ButtonOptionsUser(
              onTap: () => selectionOptionObjetive(context, 'Tener una mejor alimentación'),
              height: width * 0.1,
              width: width * 60,
              color: Colors.blue,
              text: 'Tener una mejor alimentación',
              colorText: Colors.black,
            ),

            if (provider.loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  //button guardar seccion
  void selectionOptionObjetive(BuildContext context, String objetivo) async {
    final provider = Provider.of<NutriScamModuleProvider>(context, listen: false);
    await provider.saveObjectiveUser(objetivo);

    if (provider.success) {
      ToastWidget().toastSuccess('Objetivo guardado');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewMainUser()),
      );
    } else {
      ToastWidget().toastError('error');
    }
  }

}

 */