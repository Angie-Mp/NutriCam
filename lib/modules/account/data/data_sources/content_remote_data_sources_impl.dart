import 'dart:convert';
import 'dart:io';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/data/data_sources/content_remote_data_sources.dart';
import 'package:NutriCam/modules/account/data/models/create_account_model.dart';
import 'package:NutriCam/modules/account/data/models/create_objetive_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class AccountRepositoryImpl implements AccountRepository {
  static final notifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  AccountRepositoryImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  ///crear cuenta
  @override
  Future<void> createAccountUserImpl(CreateAccountUserModel user) async {
    await firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  ///iniciar sesion
  @override
  Future<bool> loginUserImpl( String email, String password) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null && user.emailVerified) {
        ToastWidget().toastSuccess("Sesión iniciada correctamente");
        return true;
      } else {
        await firebaseAuth.signOut();
        ToastWidget().toastError("Por favor verifica tu correo");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No existe un usuario con ese correo";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta";
      } else if (e.code == 'invalid-email') {
        message = "Correo inválido";
      } else {
        message = "Error al iniciar sesión";
      }
      ToastWidget().toastError(message);
      return false;
    } catch (e) {
      ToastWidget().toastError("Error inesperado: $e");
      return false;
    }
  }

  ///cerrar sesion
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

 /// crear una opcion - uso de la app
  Future<void> createObjectiveUserImpl(ObjetiveUserModel model) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    await firestore
        .collection('objetivosUsuario')
        .doc(user.uid)
        .set(model.toMap());
  }

  ///mostrar notifiaciones
  static Future<void> show(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'calories_channel',
      'Progreso Calórico',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await notifications.show(0, title, body, details);
  }

  ///analiza img + gemini
  Future<Map<String, dynamic>> analyzeFoodWithGeminiImpl(File image) async {
    try {
      print("analizando img");

      //convierte img a base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      //obtiene usuario logueado
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      //lee datos logueado
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final genero = userData['genero'] ?? 'Femenino';
      final edad = userData['edad'] ?? 25;
      final peso = userData['pesoActual'] ?? 60;
      final pesoMeta = userData['pesoIdeal'] ?? 55;
      final altura = userData['altura'] ?? 165;
      final tipoMeta = userData['tipoMeta'] ?? 'mantener';

      print("datos del usuario:");
      print("  Genero: $genero - Edad: $edad - Peso: $peso - Meta: $pesoMeta - Altura: $altura - TipoMeta: $tipoMeta");

      //prompt para usar gemnini
      final prompt = """
Eres un nutricionista profesional. El usuario te enviará una imagen de su comida.
Usa la foto y los datos del usuario para dar un análisis realista.

Datos del usuario:
- Género: $genero
- Edad: $edad años
- Peso actual: $peso kg
- Peso meta: $pesoMeta kg
- Altura: $altura cm
- Objetivo: $tipoMeta

1 Identifica el alimento en la imagen.
2 Estima su valor nutricional aproximado (calorías, proteínas, grasas, carbohidratos, fibra).
3 Da una recomendación personalizada según su objetivo ("$tipoMeta").
Responde en formato JSON así:
{
  "rawLabel": "Nombre del alimento",
  "nutrition": {
    "calories": number,
    "protein": number,
    "fat": number,
    "carbs": number,
    "fiber": number
  },
  "recommendation": "Texto breve con la sugerencia según su objetivo."
}
""";

      //conecta al api de gemini
      const apiKey = "AIzaSyApiSZYdi5NRMzwYIyZhpLJ3G1OhgtF640";
      const model = "gemini-2.0-flash";
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {"inline_data": {"mime_type": "image/jpeg", "data": base64Image}}
              ]
            }
          ]
        }),
      );

      print("respuesta HTTP: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception("Error de Gemini: ${response.body}");
      }
      final data = jsonDecode(response.body);
      final textResponse = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (textResponse == null) throw Exception("Sin respuesta válida de Gemini");

      //extrae la repsuesta en formato json
      final jsonStart = textResponse.indexOf('{');
      final jsonEnd = textResponse.lastIndexOf('}');
      final jsonString = textResponse.substring(jsonStart, jsonEnd + 1);
      final result = jsonDecode(jsonString);
      print("resultado procesado: $result");

      //guarda el analicis "user_food_data"
      await firestore
          .collection('user_food_data')
          .doc(user.uid)
          .collection('foods')
          .add({
        'image_path': image.path,
        'detections': result,
        'timestamp': FieldValue.serverTimestamp(),
      });

      //guarda recomendaciones "recomendaciones"
      await firestore
          .collection('recomendaciones')
          .doc(user.uid)
          .collection('items')
          .add({
        'rawLabel': result['rawLabel'] ?? 'Desconocido',
        'recommendation': result['recommendation'] ?? 'Sin recomendación',
        'nutrition': result['nutrition'] ?? {},
        'objetivoUsuario': tipoMeta,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("guardado correctamente");
      return result;
    } catch (e, stack) {
      print("error: $e");
      print(stack);
      rethrow;
    }
  }

  ///calcula calorias diarias del usuario
  static double calcularCaloriasDiarias({
    required String genero,
    required double peso,
    required double altura,
    required int edad,
    required String objetivo,
  }) {
    double tdee = (genero.toLowerCase() == 'masculino')
    //masculino
        ? 10 * peso + 6.25 * altura - 5 * edad + 5
    //femenino
        : 10 * peso + 6.25 * altura - 5 * edad - 161;
    if (objetivo.toLowerCase() == 'bajar') tdee *= 0.8;
    if (objetivo.toLowerCase() == 'subir') tdee *= 1.15;
    return tdee;
  }

  /// Calcula metas de macronutrientes segun TDEE y peso
  static Map<String, double> calcularMetasMacros({
    required double peso,
    required double calorias,
  }) {
    //se divide segun el peso la cantidad que deben consumir (gr)
    final proteina = peso * 1.8;
    final grasa = peso * 0.8;
    final carbs = (calorias - ((proteina * 4) + (grasa * 9))) / 4;
    final fibra = peso * 0.3;
    return {
      "calorias": calorias,
      "proteina": proteina,
      "grasa": grasa,
      "carbs": carbs,
      "fibra": fibra,
    };
  }
}



