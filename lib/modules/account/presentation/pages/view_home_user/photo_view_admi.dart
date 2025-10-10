import 'dart:io';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class TakePhotoPage extends StatefulWidget {
  const TakePhotoPage({Key? key}) : super(key: key);

  @override
  _TakePhotoPageState createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Tomar Foto de Comida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            if (foodProvider.detections.isNotEmpty)
              Column(
                children: foodProvider.detections.map((det) {
                  final nutrition =
                      det['nutrition'] as Map<String, dynamic>? ?? {};
                  return ListTile(
                    title: Text(det['rawLabel']),
                    subtitle: Text(
                      "Cal: ${nutrition['calories'] ?? 'N/D'} kcal | "
                          "Prot: ${nutrition['protein'] ?? 'N/D'} g | "
                          "Gras: ${nutrition['fat'] ?? 'N/D'} g | "
                          "Carb: ${nutrition['carbs'] ?? 'N/D'} g",
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _takePhoto(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
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
                      content:
                      Text('Toma una foto antes de guardar'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar en Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
