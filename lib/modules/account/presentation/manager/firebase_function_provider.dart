import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/data/data_sources/content_remote_data_sources_impl.dart';
import 'package:NutriCam/modules/account/data/data_sources/permission/permissions_packages.dart';
import 'package:NutriCam/modules/account/data/models/create_account_model.dart';
import 'package:NutriCam/modules/account/data/models/create_objetive_user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NutriScamModuleProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final AccountRepositoryImpl accountRepositoryImpl = AccountRepositoryImpl();

  bool _loading = false;
  bool get loading => _loading;

  String _messageToast = '';
  String get messageToast => _messageToast;

  bool _success = false;
  bool get success => _success;

  CreateAccountUserModel? _createAccountUserModel;
  CreateAccountUserModel? get createAccountUserModel => _createAccountUserModel;

  /// Registrar usuario
  Future<void> createAccountUser(
      BuildContext context,
      CreateAccountUserModel userModel,
      String password,
      ) async {
    _loading = true;
    notifyListeners();

    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        final newUser = CreateAccountUserModel(
          uid: user.uid,
          nombre: userModel.nombre,
          apellido: userModel.apellido,
          edad: userModel.edad,
          altura: userModel.altura,
          genero: userModel.genero,
          pesoActual: userModel.pesoActual,
          pesoIdeal: userModel.pesoIdeal,
          email: userModel.email,
          emailVerified: false,
        );

        await accountRepositoryImpl.createAccountUserImpl(newUser);
        _messageToast = "Usuario creado correctamente.";
        ToastWidget().toastSuccess(_messageToast);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _messageToast = "La contraseña es muy débil.";
      } else if (e.code == 'email-already-in-use') {
        _messageToast = "El correo ya está en uso.";
      } else if (e.code == 'invalid-email') {
        _messageToast = "El correo no es válido.";
      } else {
        _messageToast = e.message ?? "Error al crear usuario.";
      }
      ToastWidget().toastError(_messageToast);
    } catch (e) {
      _messageToast = "Error inesperado: $e";
      ToastWidget().toastError(_messageToast);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// crear una opcion - uso de la app
  Future<void> saveObjectiveUser(String objetivo, String tipoMeta) async {
    _loading = true;
    _messageToast = '';
    _success = false;
    notifyListeners();

    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");
      final newModel = ObjetiveUserModel(
        uid: user.uid,
        objetivo: objetivo,
        tipoMeta: tipoMeta,
        createdAt: DateTime.now(),
      );

      await accountRepositoryImpl.createObjectiveUserImpl(newModel);
      ToastWidget().toastSuccess('Objetivo guardado');
      _success = true;
    } catch (e) {
      ToastWidget().toastError('Error al guardar objetivo: $e');
      _success = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  ///iniciar sesion
  Future<bool> loginUserAccount(String email, String password) async {
    _loading = true;
    notifyListeners();
    final success = await accountRepositoryImpl.loginUserImpl(email, password);

    _loading = false;
    notifyListeners();
    return success;
  }





  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;
  /// Guardar foto con detecciones
  Future<void> savePhotoWithImageKit2(File image, List<Map<String, dynamic>> detections) async {
    _loading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final bytes = await image.readAsBytes();

      await accountRepositoryImpl.savePhotoWithImageKitImpl(
        bytes: bytes,
        detections: detections,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      ToastWidget().toastSuccess("Foto y datos guardados ✅");
    } catch (e) {
      ToastWidget().toastError("Error al guardar: $e");
    } finally {
      _loading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }
  Future<void> savePhotoWithImageKit(File image, List<Map<String, dynamic>> detections) async {
    _loading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final bytes = await image.readAsBytes();

      await accountRepositoryImpl.savePhotoWithImageKitImpl(
        bytes: bytes,
        detections: detections,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // 🔹 Calcular los totales de la comida recién agregada
      double calorias = 0;
      double proteina = 0;
      double carbs = 0;
      double grasa = 0;
      double fibra = 0;

      for (var det in detections) {
        final nutrition = det['nutrition'] as Map<String, dynamic>;
        calorias += (nutrition['calories'] ?? 0).toDouble();
        proteina += (nutrition['protein'] ?? 0).toDouble();
        carbs += (nutrition['carbs'] ?? 0).toDouble();
        grasa += (nutrition['fat'] ?? 0).toDouble();
        fibra += (nutrition['fiber'] ?? 0).toDouble();
      }

      // 🔹 Actualizar provider sin recargar toda la vista
      actualizarValoresNutricionales(
        calorias: calorias,
        proteina: proteina,
        grasa: grasa,
        carbs: carbs,
        fibra: fibra,
      );

      ToastWidget().toastSuccess("Foto y datos guardados ✅");
    } catch (e) {
      ToastWidget().toastError("Error al guardar: $e");
    } finally {
      _loading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }


  /// ------------------------------------------- ///

  File? image;
  List<Map<String, dynamic>> detections = [];

  /// Analiza una imagen con Roboflow + Nutritionix
  Future<void> analyzeFood(File imageFile) async {
    _loading = true;
    notifyListeners();

    try {
      image = imageFile;
      detections = await accountRepositoryImpl.analyzeFood(imageFile);

      // 🔹 Mostrar resultados en la consola
      for (final det in detections) {
        final label = det['rawLabel'] ?? 'Desconocido';
        final nutrition = det['nutrition'] as Map<String, dynamic>? ?? {};
        final cal = nutrition['calories'] ?? 'N/D';
        final prot = nutrition['protein'] ?? 'N/D';
        final fat = nutrition['fat'] ?? 'N/D';
        final carb = nutrition['carbs'] ?? 'N/D';
        debugPrint("✅ Detectado: "
            "$label | " "Cal: $cal kcal | Prot: $prot g | Gras: $fat g | Carb: $carb g"
        ); }

    } catch (e) {
      debugPrint("❌ Error en análisis: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    image = null;
    detections = [];
    notifyListeners();
  }



///------------------------------
///

  ///
///
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool cargando = true;

  double caloriasTotalesHoy = 0;
  double caloriasObjetivo = 0;
  double totalProteina = 0;
  double totalCarbs = 0;
  double totalGrasa = 0;
  double totalFibra = 0;
  double peso = 0;

  ///  Cargar datos de Firestore + cálculos de TDEE
  Future<void> obtenerDatos() async {
    cargando = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final genero = prefs.getString('genero') ?? 'Femenino';
    final edad = int.tryParse(prefs.getString('edad') ?? '25') ?? 25;
    peso = double.tryParse(prefs.getString('pesoActual') ?? '60') ?? 60;
    final alturaStr = prefs.getString('altura') ?? '165';
    final tipoMeta = prefs.getString('tipoMeta') ?? 'mantener';

    double altura = double.tryParse(alturaStr.replaceAll(',', '.')) ?? 165;
    if (altura < 10) altura *= 100;

    // 🔹 Calcular TDEE
    double tdee = (genero == 'Masculino')
        ? 10 * peso + 6.25 * altura - 5 * edad + 5
        : 10 * peso + 6.25 * altura - 5 * edad - 161;

    if (tipoMeta == 'bajar') tdee *= 0.8;
    if (tipoMeta == 'subir') tdee *= 1.15;

    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('user_food_data')
        .doc(user.uid)
        .collection('foods')
        .where('timestamp', isGreaterThanOrEqualTo: inicioDia)
        .where('timestamp', isLessThan: finDia)
        .get();

    double totalCal = 0;
    double prot = 0;
    double carb = 0;
    double fat = 0;
    double fibra = 0;

    for (var doc in snapshot.docs) {
      final detections = doc['detections'] as List<dynamic>;
      for (var det in detections) {
        final nutrition = det['nutrition'] as Map<String, dynamic>;
        totalCal += (nutrition['calories'] ?? 0).toDouble();
        prot += (nutrition['protein'] ?? 0).toDouble();
        carb += (nutrition['carbs'] ?? 0).toDouble();
        fat += (nutrition['fat'] ?? 0).toDouble();
        fibra += (nutrition['fiber'] ?? 0).toDouble();
      }
    }

    caloriasTotalesHoy = totalCal;
    caloriasObjetivo = tdee;
    totalProteina = prot;
    totalCarbs = carb;
    totalGrasa = fat;
    totalFibra = fibra;

    _verificarNotificaciones();
    cargando = false;
    notifyListeners();
  }
//
  ///  Nuevo método incremental (sin recargar toda la vista)

///
///
  // En tu provider NutriScamModuleProvider
  bool _notificacion50 = false;
  bool _notificacion75 = false;
  bool _notificacion100 = false;

  void actualizarValoresNutricionales({
    required double calorias,
    required double proteina,
    required double grasa,
    required double carbs,
    required double fibra,
  }) {
    caloriasTotalesHoy += calorias;
    totalProteina += proteina;
    totalGrasa += grasa;
    totalCarbs += carbs;
    totalFibra += fibra;

    _verificarNotificaciones();
    notifyListeners(); // 🔄 Actualiza las barras al instante
  }

  void _verificarNotificaciones() {
    if (caloriasObjetivo <= 0) return;

    final progreso = (caloriasTotalesHoy / caloriasObjetivo).clamp(0.0, 1.0);

    if (progreso >= 0.5 && !_notificacion50) {
      AccountRepositoryImpl.show("¡Buen trabajo!", "Llevas el 50% de tus calorías");
      log('50%');
      _notificacion50 = true;
    }
    if (progreso >= 0.75 && !_notificacion75) {
      AccountRepositoryImpl.show("¡Sigue así!", "Ya alcanzaste el 75% del objetivo");
      log('70%');
      _notificacion75 = true;
    }
    if (progreso >= 1 && !_notificacion100) {
      AccountRepositoryImpl.show("¡Meta alcanzada!", "Completaste tu objetivo de hoy");
      log('100%');
      _notificacion100 = true;
    }
  }
///
///
}

