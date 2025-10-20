import 'dart:io';
import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';

class ViewCameraPageUser extends StatefulWidget {
  const ViewCameraPageUser({Key? key}) : super(key: key);

  @override
  State<ViewCameraPageUser> createState() => _ViewCameraPageUserState();
}

class _ViewCameraPageUserState extends State<ViewCameraPageUser> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final file = File(photo.path);
    final provider = context.read<NutriScamModuleProvider>();

    ToastWidget().toastSuccess("Analizando imagen con Gemini..");
    await provider.analyzeFoodWithGemini(file);
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<NutriScamModuleProvider>();
    final bool loading = foodProvider.loading;
    final detections = foodProvider.detections;
    const double displayHeight = 360;

    return Scaffold(
      body: SingleChildScrollView(
       // padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 35, 0, 0),
              color: colorGrey,
            ),
            if (loading) const LinearProgressIndicator(),

            const SizedBox(height: 12),

            // 📷 Imagen o placeholder
            if (foodProvider.image != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(foodProvider.image!, height: displayHeight),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 28),
                    onPressed: () => foodProvider.clear(),
                  ),
                ],
              )
            else
              Container(
                height: displayHeight,
                color: Colors.grey[200],
                child: const Center(child: Text("📸 Toma una foto para analizar")),
              ),

            const SizedBox(height: 16),

            // 🧠 Resultados de Gemini
            if (detections.isNotEmpty)
              _buildResultCard(detections.first)
            else if (!loading)
              const Text(
                "Aún no hay resultados",
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 24),

            // 📸 Botón de cámara
            ElevatedButton.icon(
              onPressed: loading ? null : () => _takePhoto(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar Foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta con los resultados procesados por Gemini
  Widget _buildResultCard(Map<String, dynamic> det) {
    final rawLabel = det['rawLabel'] ?? 'Alimento no identificado';
    final nutrition = det['nutrition'] ?? {};
    final rec = det['recommendation'] ?? 'Sin recomendación disponible';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fastfood, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rawLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "🍽️ Información nutricional aproximada:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("• Calorías: ${nutrition['calories'] ?? 'N/D'} kcal"),
            Text("• Proteínas: ${nutrition['protein'] ?? 'N/D'} g"),
            Text("• Grasas: ${nutrition['fat'] ?? 'N/D'} g"),
            Text("• Carbohidratos: ${nutrition['carbs'] ?? 'N/D'} g"),
            Text("• Fibra: ${nutrition['fiber'] ?? 'N/D'} g"),
            const SizedBox(height: 12),
            Text(
              "💡 Recomendación:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(rec),
          ],
        ),
      ),
    );
  }
}
