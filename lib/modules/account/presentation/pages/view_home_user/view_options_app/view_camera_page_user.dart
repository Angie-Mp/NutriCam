import 'dart:io';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ViewCameraPageUser extends StatefulWidget {
  const ViewCameraPageUser({Key? key}) : super(key: key);

  @override
  _ViewCameraPageUserState createState() => _ViewCameraPageUserState();
}

class _ViewCameraPageUserState extends State<ViewCameraPageUser> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final file = File(photo.path);
    await context.read<NutriScamModuleProvider>().analyzeFood(file);
  }

  void _clearData(BuildContext context) {
    final provider = context.read<NutriScamModuleProvider>();
    provider.clear();
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<NutriScamModuleProvider>();
    final firebaseProvider = context.watch<NutriScamModuleProvider>();
    const double displayHeight = 360.0;

    // 🔹 Evitar duplicados de alimentos detectados
    final uniqueDetections = <String, Map<String, dynamic>>{};
    for (var det in foodProvider.detections) {
      final label = det['rawLabel']?.toString().toLowerCase() ?? '';
      if (!uniqueDetections.containsKey(label)) {
        uniqueDetections[label] = det;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar Foto de Comida'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/iconos/button_navigator/home.png'),

            if (foodProvider.loading || firebaseProvider.loading)
              const LinearProgressIndicator(),

            const SizedBox(height: 8),

            // 🔹 Imagen con botón de eliminar
            if (foodProvider.image != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(foodProvider.image!, height: displayHeight),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 28),
                    onPressed: () => _clearData(context),
                  ),
                ],
              )
            else
              Container(
                height: displayHeight,
                color: Colors.grey[200],
                child: const Center(child: Text('📷 No hay foto')),
              ),

            const SizedBox(height: 16),

            // 🔹 Mostrar los alimentos detectados sin duplicados
            if (uniqueDetections.isNotEmpty)
              Column(
                children: uniqueDetections.values.map((det) {
                  final nutrition =
                      det['nutrition'] as Map<String, dynamic>? ?? {};
                  final calories = nutrition['calories'] ?? 'N/D';
                  final protein = nutrition['protein'] ?? 'N/D';
                  final fat = nutrition['fat'] ?? 'N/D';
                  final carbs = nutrition['carbs'] ?? 'N/D';
                  final fiber = nutrition['fiber'] ?? 'N/D'; // 👈 agregado

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.green),
                      title: Text(
                        det['rawLabel'] ?? 'Alimento',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Cal: $calories kcal | "
                            "Prot: $protein g | "
                            "Gras: $fat g | "
                            "Carb: $carbs g | "
                            "Fibra: $fiber g", // 👈 agregado
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _takePhoto(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: firebaseProvider.loading
                  ? null
                  : () async {
                if (foodProvider.image != null &&
                    foodProvider.detections.isNotEmpty) {
                  await firebaseProvider.savePhotoWithImageKit(
                    foodProvider.image!,
                    foodProvider.detections,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Toma una foto antes de guardar'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar en Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
