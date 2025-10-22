import 'dart:io';
import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_menu_page/widget_inof_nutritional_img.dart';
import 'package:NutriCam/modules/account/presentation/widgets/widget_user/widget_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FoodOfTheDay extends StatefulWidget {
  const FoodOfTheDay({Key? key}) : super(key: key);

  @override
  State<FoodOfTheDay> createState() => _FoodOfTheDayState();
}

class _FoodOfTheDayState extends State<FoodOfTheDay> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NutriScamModuleProvider>(context, listen: false)
            .obtenerDatos());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NutriScamModuleProvider>(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
              Icons.close,
            color: colorWhite1,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/logo/logo-app.png', height: 50),
        centerTitle: true,
        backgroundColor: colorPurple,
        actions: [
          IconButton(
            icon: const Icon(
                Icons.refresh,
              color: colorWhite1,
            ),
            onPressed: () => provider.obtenerDatos(),
          )
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
          future: _getTodayFoods(provider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final foods = snapshot.data ?? [];
            if (foods.isEmpty) {
              return const Center(
                child: Text("No hay alimentos registrados hoy."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                final timestamp = (food['timestamp'] as Timestamp).toDate();
                final nutrition = food['detections']?['nutrition'] ??
                    food['result']?['nutrition'] ?? {};
                final rawLabel =
                    food['detections']?['rawLabel'] ??
                        food['result']?['rawLabel'] ??
                        "No hay recomendación disponible.";
                return GestureDetector(
                  onTap: () {
                    final recommendation =
                        food['detections']?['recommendation'] ??
                            food['result']?['recommendation'] ??
                            "No hay recomendación disponible.";
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text(
                            "Recomendación",
                          style: TextStyle(
                            color: colorOrange2,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        content: Text(
                            recommendation,
                          style:const TextStyle(
                            color: colorBlack,
                            fontSize: 14
                          ),
                        ),
                        actions: [
                          Center(
                            child: CustomButton(
                              text: 'Cerrar',
                              backgroundColor: colorPurple,
                              textColor: Colors.white,
                              width: width * 0.6,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                          color: colorBlack,
                          width: 2),
                    ),
                    color: colorYellow,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Fecha y hora
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('EEEE dd', 'es_ES').format(timestamp), // Lunes 21
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorBlack,
                                  ),
                                ),
                                Text(
                                  DateFormat('hh:mm a', 'es_ES').format(timestamp), // 08:30 AM
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Imagen
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (food['imageUrl'] != null && food['imageUrl'].toString().isNotEmpty)
                                ? Image.network(
                              food['imageUrl'],
                              height: 180,
                              width: width * 0.8,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text("Error al cargar imagen", style: TextStyle(color: Colors.grey))),
                            )
                                : (food['image_path'] != null && food['image_path'].toString().isNotEmpty)
                                ? Image.file(
                              File(food['image_path']),
                              height: 180,
                              width: width * 0.8,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              height: 180,
                              width: width * 0.8,
                              alignment: Alignment.center,
                              color: colorGrey,
                              child: const Text("Sin imagen disponible", style: TextStyle(color: Colors.grey)),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${rawLabel}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorBlack),
                                  ),
                                ),
                                Text(
                                  "${nutrition['calories']?.toStringAsFixed(0) ?? '0'} kcal", // Calorías
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: colorBlack),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(10,15, 10, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InfoNutricionalImage(
                                    label: "Calorías",
                                    value: '${nutrition['calories'] ?? ''} kcal',
                                    color: colorGreen2
                                ),
                                InfoNutricionalImage(
                                    label: "Proteínas",
                                    value: '${nutrition['protein'] ?? ''} g',
                                    color: colorOrange2
                                ),
                                InfoNutricionalImage(
                                    label: "Grasas",
                                    value: '${nutrition['fat'] ?? ''} g',
                                    color: colorGreen2
                                ),
                                InfoNutricionalImage(
                                    label: "Carbo.",
                                    value: '${nutrition['carbs'] ?? ''} g',
                                    color: colorBlue2
                                ),
                                InfoNutricionalImage(
                                    label: "Fibra",
                                    value: '${nutrition['fiber'] ?? ''} g',
                                    color: colorPurple
                                ),
                              ],
                            ),
                          ),
                        ],
                      )

                    ),
                  ),
                );

              },
            );
          }),
    );
  }

  //muestra datos de bd
  Future<List<Map<String, dynamic>>> _getTodayFoods(
      NutriScamModuleProvider provider) async {
    final user = provider.firebaseAuth.currentUser;
    if (user == null) return [];

    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('user_food_data')
        .doc(user.uid)
        .collection('foods')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('timestamp', isLessThan: Timestamp.fromDate(fin))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

}
