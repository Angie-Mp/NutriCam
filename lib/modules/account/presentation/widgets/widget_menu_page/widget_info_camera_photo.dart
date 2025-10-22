import 'dart:io';
import 'package:NutriCam/modules/account/presentation/widgets/widget_menu_page/widget_inof_nutritional_img.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:NutriCam/core/values/colors.dart';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/presentation/manager/firebase_function_provider.dart';

class WidgetInfoCameraPhoto extends StatefulWidget {
  const WidgetInfoCameraPhoto({Key? key}) : super(key: key);

  @override
  State<WidgetInfoCameraPhoto> createState() => _WidgetInfoCameraPhotoState();
}

class _WidgetInfoCameraPhotoState extends State<WidgetInfoCameraPhoto> {
  final ImagePicker _picker = ImagePicker();

  //funcion para tomar foto
  Future<void> _takePhoto(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
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
    const double displayHeight = 260;

    return Column(
      children: [
        const SizedBox(height: 12),
        if (foodProvider.image != null)
          Stack(
            children: [
              Image.file(
                  foodProvider.image!,
                  height: displayHeight
              ),
              IconButton(
                icon: const Icon(
                    Icons.close,
                    color: colorRed1,
                    size: 28
                ),
                onPressed: () => foodProvider.clear(),
              ),
              if (loading) const LinearProgressIndicator(
                color: colorGreen1,
              ),
            ],
          )
        else
          GestureDetector(
            onTap: loading ? null : () => _takePhoto(context),
            child: Container(
              height: displayHeight,
              color: Colors.grey[200],
              child: const Center(
                child: Text("Toma una foto para analizar"),
              ),
            ),
          ),
        const SizedBox(height: 20),
        if (detections.isNotEmpty)
          cardResultImage(detections.first)
        else if (!loading)
           Container()
      ],
    );
  }

  //resultados nutricionales
  Widget cardResultImage(Map<String, dynamic> det) {
    final rawLabel = det['rawLabel'] ?? 'Alimento no identificado';
    final nutrition = det['nutrition'] ?? {};
    final rec = det['recommendation'] ?? 'Sin recomendación disponible';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorWhite1,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colorYellow,
              width: 3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(
                      Icons.fastfood,
                      color: colorBlack
                  ),
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
              const Text(
                "- Información nutricional -",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
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
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorWhite1,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colorYellow,
              width: 3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Recomendación:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(rec),
            ],
          ),
        )
      ],
    );
  }


}
