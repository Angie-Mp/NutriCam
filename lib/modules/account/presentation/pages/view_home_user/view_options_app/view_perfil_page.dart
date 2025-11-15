import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewPerfilPage extends StatefulWidget {
  const ViewPerfilPage({super.key});

  @override
  State<ViewPerfilPage> createState() => _ViewPerfilPageState();
}

class _ViewPerfilPageState extends State<ViewPerfilPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NutriScamModuleProvider>(context, listen: false);
    provider.loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutriScamModuleProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = provider.createAccountUserModel;

        if (user == null) {
          return const Center(child: Text("No hay usuario logueado."));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: colorYellow,
                padding: const EdgeInsets.fromLTRB(15, 45, 0, 15),
                child: Row(
                  children: [
                    Image.asset('assets/iconos/nutri-salud.png', height: 50),
                    const SizedBox(width: 10),
                    Text(
                      "${user.nombre} ${user.apellido}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Column(
                  children: [
                    Text(
                        "Edad: ${provider.edad} años",
                      style: TextStyle(
                        color: colorPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              Text("Edad: ${provider.edad} años"),
              Text("Sexo: ${provider.sexo}"),
              Text("Peso actual: ${provider.peso.toStringAsFixed(1)} kg"),
              Text("Altura: ${provider.altura.toStringAsFixed(1)} cm"),
              Text("Objetivo: ${provider.objetivo}"),
              const SizedBox(height: 10),

              const SizedBox(height: 10),
              const Text("Consumo hoy:"),
              Text("Calorías: ${provider.caloriasTotalesHoy.toStringAsFixed(1)} kcal"),
              Text("Proteína: ${provider.totalProteina.toStringAsFixed(1)} g"),
              Text("Grasa: ${provider.totalGrasa.toStringAsFixed(1)} g"),
              Text("Carbohidratos: ${provider.totalCarbs.toStringAsFixed(1)} g"),
              Text("Fibra: ${provider.totalFibra.toStringAsFixed(1)} g"),
            ],
          ),
        );
      },
    );
  }
}
