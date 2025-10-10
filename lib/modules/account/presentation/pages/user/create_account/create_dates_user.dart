import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/data/models/create_account_model.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:NutriCam/modules/account/presentation/pages/user/select_option_user.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_input_account.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NutriCam/core/values/colors.dart';
import 'package:provider/provider.dart';

class CreateDatesUser extends StatefulWidget {
  const CreateDatesUser({super.key});

  @override
  State<CreateDatesUser> createState() => _CreateDatesUserState();
}

class _CreateDatesUserState extends State<CreateDatesUser> {
  String nombre = '';
  String apellido = '';
  String email = '';
  String password = '';
  String objetivo = '';
  String tipoMeta = '';
  final TextEditingController edadController = TextEditingController();
  final TextEditingController metrosController = TextEditingController();
  final TextEditingController centimetrosController = TextEditingController();
  String? selectedGenero;
  final TextEditingController pesoActualController = TextEditingController();
  final TextEditingController pesoIdealController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

// 🔹 Cargar datos de SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('nombre') ?? '';
      apellido = prefs.getString('apellido') ?? '';
      email = prefs.getString('email') ?? '';
      password = prefs.getString('password') ?? '';
      objetivo = prefs.getString('objetivo') ?? '';
      selectedGenero = prefs.getString('genero');
      tipoMeta = prefs.getString('tipoMeta') ?? '';
    });
  }

// 🔹 Guardar datos nuevos (ej. género, edad)
  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('edad', edadController.text);
    await prefs.setString('genero', selectedGenero ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.maxWidth / 100;
          return Stack(
            children: [
// Fondo
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/back/back2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 90),
                      Image.asset(
                        'assets/iconos/fruta.png',
                        width: 120,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Cuéntanos',
                            style: TextStyle(
                              color: colorBlack,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' $nombre',
                            style: const TextStyle(
                              fontSize: 25,
                              color: colorOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Queremos saber de ti 😊',
                        style: TextStyle(fontSize: 15, color: colorBlack),
                      ),
                      const SizedBox(height: 20),
                      //form
                      Container(
                        width: size * 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: colorGray2,
                                border: Border.all(color: colorBlack, width: 1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonFormField<String>(
                                value: selectedGenero,
                                hint: const Text(
                                    "Sexo"),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "Femenino",
                                    child: Text("Femenino"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Masculino",
                                    child: Text("Masculino"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedGenero = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            WidgetInputAccount(
                              textTitleInput: 'Edad',
                              controller: edadController,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child:  WidgetInputAccount(
                                    textTitleInput: 'metros',
                                    controller: metrosController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: WidgetInputAccount(
                                    textTitleInput: 'cm',
                                    controller: centimetrosController,
                                  ),
                                ),
                              ],
                            ),
                            WidgetInputAccount(
                              textTitleInput: 'Peso actual',
                              controller: pesoActualController,
                            ),
                            WidgetInputAccount(
                              textTitleInput: 'Peso Ideal',
                              controller: pesoIdealController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      //btn guardar
                      CustomButton(
                        text: 'Guardar',
                        backgroundColor: colorPurple,
                        textColor: colorWhite1,
                        width: size * 70,
                          onPressed: () async {
                            if (edadController.text.isEmpty ||
                                selectedGenero == null ||
                                pesoActualController.text.isEmpty ||
                                pesoIdealController.text.isEmpty ||
                                metrosController.text.isEmpty ||
                                centimetrosController.text.isEmpty) {
                              ToastWidget().toastError('Por favor completa todos los campos');
                              return;
                            }
                            //cargar datos de SharedPreferences
                            final prefs = await SharedPreferences.getInstance();
                            final nombre = prefs.getString('nombre') ?? '';
                            final apellido = prefs.getString('apellido') ?? '';
                            final email = prefs.getString('email') ?? '';
                            final password = prefs.getString('password') ?? '';
                            final objetivo = prefs.getString('objetivo') ?? '';
                            final tipoMeta = prefs.getString('tipoMeta') ?? '';
                            //altura
                            final altura = "${metrosController.text.trim()}.${centimetrosController.text.trim()}";

                            //Crear el modelo del usuario
                            final user = CreateAccountUserModel(
                              uid: '',
                              nombre: nombre,
                              apellido: apellido,
                              edad: edadController.text.trim(),
                              altura: altura,
                              genero: selectedGenero ?? '',
                              pesoActual: pesoActualController.text.trim(),
                              pesoIdeal: pesoIdealController.text.trim(),
                              email: email,
                            );
                            final provider = Provider.of<NutriScamModuleProvider>(context, listen: false);
                            await provider.createAccountUser(context, user, password);

                            //Si se crea correctamente, guarda el objetivo en otra colección
                            if (provider.messageToast.contains("Usuario creado correctamente.")) {
                             // await provider.saveObjectiveUser(objetivo);
                              await provider.saveObjectiveUser(objetivo, tipoMeta);
                              debugPrint('Usuario y objetivo guardados correctamente');
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(
                                  builder: (_) => const SelectOptionUser()
                              ));
                            }
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

