import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:NutriCam/modules/account/presentation/pages/user/aliment_day/food_of_the_day.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_menu_page/nutrienBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewMenuPageUser extends StatefulWidget {
  const ViewMenuPageUser({Key? key}) : super(key: key);

  @override
  State<ViewMenuPageUser> createState() => _ViewMenuPageUserState();
}

class _ViewMenuPageUserState extends State<ViewMenuPageUser> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider =
      Provider.of<NutriScamModuleProvider>(context, listen: false);
      await provider.initUserData();
      await provider.obtenerDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutriScamModuleProvider>(
      builder: (_, provider, __) {
        // Calcular progreso de calorías
        final progreso = (provider.metasCalorias > 0)
            ? (provider.caloriasTotalesHoy / provider.metasCalorias).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: colorWhite1,
                  image: DecorationImage(
                    image: AssetImage('assets/back/back5.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              //
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo superior
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 35, 0, 0),
                      child: Row(
                        children: [
                          Image.asset('assets/logo/logo-app.png', height: 50),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Image.asset('assets/iconos/nutri-salud.png', width: 90),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                        "${provider.caloriasTotalesHoy.toStringAsFixed(0)} kcal",
                                        style: const TextStyle(
                                            color: colorBlack,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${provider.metasCalorias.toStringAsFixed(0)} kcal objetivo",
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
                          const SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: NutrientBarWidget(
                                    nombre:
                                    "Proteína",
                                    valorActual: provider.totalProteina,
                                    valorMeta: provider.metasProteina,
                                    color: colorOrange2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: NutrientBarWidget(
                                    nombre:
                                    "Grasas",
                                    valorActual: provider.totalGrasa,
                                    valorMeta: provider.metasGrasa,
                                    color: colorGreen2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: NutrientBarWidget(
                                    nombre:
                                    "Carbo.",
                                    valorActual: provider.totalCarbs,
                                    valorMeta: provider.metasCarbs,
                                    color: colorBlue2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: NutrientBarWidget(
                                    nombre:
                                    "Fibra",
                                    valorActual: provider.totalFibra,
                                    valorMeta: provider.metasFibra,
                                    color: colorPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //ver recomendaciones diarias
                          const SizedBox(height: 40),
                          GestureDetector(
                           onTap: (){
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => FoodOfTheDay(),
                               ),
                             );
                           },
                           child: Container(
                             padding: const EdgeInsets.all(15),
                             decoration: BoxDecoration(
                               color: colorWhite1,
                               borderRadius: BorderRadius.circular(15),
                               border: Border.all(
                                 color: colorYellow,
                                 width: 3,
                               ),
                             ),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 Container(
                                     padding: const EdgeInsets.all(8),
                                     decoration: BoxDecoration(
                                       color: colorGreen2.withOpacity(0.15),
                                       borderRadius: BorderRadius.circular(12),
                                     ),
                                     child: Image.asset(
                                       'assets/iconos/comidas/almuerzo.png',
                                       height: 45,
                                     )
                                 ),
                                 const SizedBox(width: 15),
                                 const Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       "Alimentos de hoy",
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 16,
                                         color: colorBlack,
                                       ),
                                     ),
                                     SizedBox(height: 4),
                                     Text(
                                       "Consulta tus comidas registradas del día",
                                       style: TextStyle(
                                         fontSize: 12,
                                         color: colorGrey,
                                       ),
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                         )
                        ],
                      ),
                    )
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
