import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/data/data_sources/content_remote_data_sources_impl.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_menu_page/nutrienBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewMenuPageUser extends StatefulWidget {
  const ViewMenuPageUser({Key? key}) : super(key: key);

  @override
  State<ViewMenuPageUser> createState() => _ViewMenuPageUserState();
}

class _ViewMenuPageUserState extends State<ViewMenuPageUser> {
  bool notificacion50 = false, notificacion75 = false, notificacion100 = false;

  @override
  void initState() {
    super.initState();
    AccountRepositoryImpl.init();

    Future.microtask(() {
      final provider =
      Provider.of<NutriScamModuleProvider>(context, listen: false);
      provider.obtenerDatos();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<NutriScamModuleProvider>(
      builder: (_, progresoCalorias, __) {

        final progreso = (progresoCalorias.caloriasObjetivo > 0)
            ? (progresoCalorias.caloriasTotalesHoy / progresoCalorias.caloriasObjetivo).clamp(0.0, 1.0)
            : 0.0;

        final metaProteina = progresoCalorias.peso * 1.8;
        final metaGrasa = progresoCalorias.peso * 0.8;
        final metaCarb = progresoCalorias.peso * 2.5;
        final metaFibra = progresoCalorias.peso * 0.3;

        return Scaffold(
          body: Stack(
            children: [
              // Fondo decorativo
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/back/back5.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Contenido principal
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 35, 0, 0),
                      child: Row(
                        children: [
                          Image.asset('assets/logo/logo-app.png', height: 50),
                        ],
                      ),
                    ),
                    Image.asset('assets/iconos/nutri-salud.png', width: 90),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //barra de calorias
                          Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progreso,
                                  minHeight: 30,
                                  backgroundColor: Colors.grey[300],
                                  color: colorRed1,
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${progresoCalorias.caloriasTotalesHoy.toStringAsFixed(0)} kcal",
                                        style: const TextStyle(
                                            color: colorBlack,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${progresoCalorias.caloriasObjetivo.toStringAsFixed(0)} kcal",
                                        style: const TextStyle(
                                            color: colorBlack,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                              'Calorías ingeridas',
                            style: TextStyle(
                              color: colorBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Barras de nutrientes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: NutrientBarWidget(
                                  nombre: "Proteína",
                                  valorActual: progresoCalorias.totalProteina,
                                  valorMeta: metaProteina,
                                  color: colorOrange2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NutrientBarWidget(
                                  nombre: "Grasas",
                                  valorActual: progresoCalorias.totalGrasa,
                                  valorMeta: metaGrasa,
                                  color: colorGreen2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NutrientBarWidget(
                                  nombre: "Carbs",
                                  valorActual: progresoCalorias.totalCarbs,
                                  valorMeta: metaCarb,
                                  color: colorBlue2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NutrientBarWidget(
                                  nombre: "Fibra",
                                  valorActual: progresoCalorias.totalFibra,
                                  valorMeta: metaFibra,
                                  color: colorPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),



                          const SizedBox(height: 20),

                          if (progreso > 1)
                            const Text(
                              "🎉 ¡Has superado tu meta diaria!",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
