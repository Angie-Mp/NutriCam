import 'dart:convert';
import 'dart:io';

import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/data/data_sources/content_remote_data_sources.dart';
import 'package:NutriCam/modules/account/data/data_sources/permission/permissions_packages.dart';
import 'package:NutriCam/modules/account/data/models/create_objetive_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:imagekit_io/imagekit_io.dart';
import '../models/create_account_model.dart';
import 'package:http/http.dart' as http;


class AccountRepositoryImpl implements AccountRepository {
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



  /// Subir foto a ImageKit y guardar en Firestore
  Future<void> savePhotoWithImageKitImpl({
    required Uint8List bytes,
    required List<Map<String, dynamic>> detections,
    required Function(double progress) onProgress,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    // 🔹 Subir a ImageKit
    final response = await ImageKit.io(
      bytes,
      fileName: "food_${DateTime.now().millisecondsSinceEpoch}.jpg",
      privateKey: "private_z4loaV5mSeOO2CD8izHo8rerv5o=", // ⚠️ Mantener secreto
      onUploadProgress: (progress) => onProgress(progress),
    );

    if (response.url == null) {
      throw Exception("No se pudo obtener URL de ImageKit");
    }

    // 🔹 Guardar en Firestore
    await firestore
        .collection('user_food_data')
        .doc(user.uid)
        .collection('foods') // subcolección
        .add({
      'image_url': response.url,
      'detections': detections,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  /// ----------------------------
  final Map<String, Map<String, dynamic>> _nutritionCache = {};

  /// Analiza una imagen y devuelve una lista de resultados nutricionales
  Future<List<Map<String, dynamic>>> analyzeFood(File image) async {
    final uri = Uri.parse(ROBOFLOW_URL);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamedResp = await request.send();
    final responseBody = await streamedResp.stream.bytesToString();
    final parsed = jsonDecode(responseBody);

    if (parsed == null || parsed['predictions'] == null) {
      throw Exception("Respuesta inválida de Roboflow");
    }

    final List preds = parsed['predictions'] as List;
    final futures = preds.map<Future<Map<String, dynamic>>>((item) async {
      final rawLabel = (item['class'] ?? '').toString();
      final label = rawLabel.toLowerCase().trim();

      Map<String, dynamic>? nutrition = _nutritionCache[label];
      if (nutrition == null) {
        nutrition = await _getNutritionFromNutritionix(label);
        _nutritionCache[label] = nutrition;
      }

      return {
        'label': label,
        'rawLabel': rawLabel,
        'nutrition': nutrition,
      };
    }).toList();

    return await Future.wait(futures);
  }

  /// Obtiene la información nutricional desde Nutritionix
  Future<Map<String, dynamic>> _getNutritionFromNutritionix(String label) async {
    try {
      final url = Uri.parse("https://trackapi.nutritionix.com/v2/natural/nutrients");
      final headers = {
        "Content-Type": "application/json",
        "x-app-id": NUTRITIONIX_APP_ID,
        "x-app-key": NUTRITIONIX_APP_KEY,
      };

      final queries = ["1 $label", "1 serving of $label", label];

      for (final q in queries) {
        final resp = await http.post(url, headers: headers, body: jsonEncode({"query": q}));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data['foods'] != null && (data['foods'] as List).isNotEmpty) {
            final food = data['foods'][0];
            return {
              'calories': _safeToDouble(food['nf_calories']),
              'protein': _safeToDouble(food['nf_protein']),
              'fat': _safeToDouble(food['nf_total_fat']),
              'carbs': _safeToDouble(food['nf_total_carbohydrate']),
            };
          }
        }
      }
      return {};
    } catch (e) {
      print("Error Nutritionix: $e");
      return {};
    }
  }

  double? _safeToDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

/// ----------------------------

  static final _noti = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _noti.initialize(initSettings);
  }

  static Future<void> show(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'calories_channel',
      'Progreso Calórico',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _noti.show(0, title, body, details);
  }


}



