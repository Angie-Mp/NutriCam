import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:NutriCam/core/widget/toast_widget.dart';
import 'package:NutriCam/modules/account/data/data_sources/content_remote_data_sources_impl.dart';
import 'package:NutriCam/modules/account/data/models/create_account_model.dart';
import 'package:NutriCam/modules/account/data/models/create_objetive_user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutriScamModuleProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final AccountRepositoryImpl accountRepositoryImpl = AccountRepositoryImpl();

  bool _loading = false;
  bool get loading => _loading;

  String _messageToast = '';
  String get messageToast => _messageToast;

  bool _success = false;
  bool get success => _success;

  CreateAccountUserModel? _createAccountUserModel;
  CreateAccountUserModel? get createAccountUserModel => _createAccountUserModel;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  File? image;
  List<Map<String, dynamic>> detections = [];

  bool cargando = true;
  double caloriasTotalesHoy = 0;
  double caloriasObjetivo = 0;
  double totalProteina = 0;
  double totalCarbs = 0;
  double totalGrasa = 0;
  double totalFibra = 0;
  double peso = 0;

  double altura = 0;
  int edad = 0;
  String sexo = '';
  String objetivo = '';
  //barras nutricionales


  //Metas diarias (calculadas con Gemini)
  double metasCalorias = 0;
  double metasProteina = 0;
  double metasGrasa = 0;
  double metasCarbs = 0;
  double metasFibra = 0;

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

  ///limpiar img + datos
  void clear() {
    image = null;
    detections = [];
    notifyListeners();
  }

  ///analiza la img + gemni
  Future<void> analyzeFoodWithGemini(File imageFile) async {
    _loading = true;
    _uploadProgress = 0.0;
    image = imageFile;
    notifyListeners();

    try {
      final result = await accountRepositoryImpl.analyzeFoodWithGeminiImpl(imageFile);
      detections = [result];
      ToastWidget().toastSuccess("analisis completado con Gemini");
      print("Resultado Gemini: $result");

    } catch (e) {
      ToastWidget().toastError("Error: $e");
      debugPrint("error $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  ///reinicia la barra + carga datos
  Future<void> initUserData() async {
    await reiniciarBarrasSiNuevoDia();
    await cargarDatosUsuarioYCalcularMetas(firebaseAuth.currentUser!.uid);
  }

  ///Cargar datos de Firestore + cálculos de TDEE
  Future<void> obtenerDatos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      //Definir rango del día de hoy
      final hoy = DateTime.now();
      final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final finDia = inicioDia.add(Duration(days: 1));

      //Traer solo los datos del día de hoy
      final snapshot = await FirebaseFirestore.instance
          .collection('user_food_data')
          .doc(user.uid)
          .collection('foods')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('timestamp', isLessThan: Timestamp.fromDate(finDia))
          .get();

      double totalCal = 0;
      double prot = 0;
      double carb = 0;
      double fat = 0;
      double fibra = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['detections'] != null && data['detections'] is Map<String, dynamic>) {
          final detections = data['detections'] as Map<String, dynamic>;
          final nutrition = detections['nutrition'] as Map<String, dynamic>;

          totalCal += (nutrition['calories'] ?? 0).toDouble();
          prot += (nutrition['protein'] ?? 0).toDouble();
          carb += (nutrition['carbs'] ?? 0).toDouble();
          fat += (nutrition['fat'] ?? 0).toDouble();
          fibra += (nutrition['fiber'] ?? 0).toDouble();
        } else if (data['result'] != null && data['result'] is Map<String, dynamic>) {
          final result = data['result'] as Map<String, dynamic>;
          final nutrition = result['nutrition'] as Map<String, dynamic>;

          totalCal += (nutrition['calories'] ?? 0).toDouble();
          prot += (nutrition['protein'] ?? 0).toDouble();
          carb += (nutrition['carbs'] ?? 0).toDouble();
          fat += (nutrition['fat'] ?? 0).toDouble();
          fibra += (nutrition['fiber'] ?? 0).toDouble();
        }
      }

      caloriasTotalesHoy = totalCal;
      totalProteina = prot;
      totalCarbs = carb;
      totalGrasa = fat;
      totalFibra = fibra;
      notifyListeners();

      print('Datos obtenidos correctamente $totalCal kcal del día de hoy');
    } catch (e) {
      print("Error en obtenerDatos: $e");
    }
  }

  /// Calcular metas diarias (TDEE + macros) y ajustar por consumo actual
  Future<void> cargarDatosUsuarioYCalcularMetas(String uid) async {
    _loading = true;
    notifyListeners();

    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");
      final userDoc = await firebaseFirestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        debugPrint("No se encontró el usuario en Firestore");
        return;
      }

      final data = userDoc.data()!;
      debugPrint("Datos Firestore: $data");

      //conversion datos de bd (string a int)
      sexo = data['genero']?.toString() ?? 'Femenino';
      objetivo = data['tipoMeta']?.toString() ?? 'mantener';
      peso = double.tryParse((data['pesoActual'] ?? '0').toString().replaceAll(',', '.')) ?? 0;
      altura = double.tryParse((data['altura'] ?? '0').toString().replaceAll(',', '.')) ?? 0;
      edad = int.tryParse((data['edad'] ?? '0').toString()) ?? 0;
      debugPrint("Datos usuario cargados: sexo=$sexo, edad=$edad, peso=$peso, altura=$altura, objetivo=$objetivo");

      // calcula metas diarias
      await calcularMetasDiarias();
    } catch (e) {
      print("Error al cargar y calcular metas: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Calcular metas diaria
  Future<void> calcularMetasDiarias() async {
    _loading = true;
    notifyListeners();

    try {
      //obtiene datos firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = userDoc.data() ?? {};

      sexo = data['genero']?.toString() ?? 'Femenino';
      objetivo = data['tipoMeta']?.toString() ?? 'mantener';
      peso = double.tryParse((data['pesoActual'] ?? '0').toString().replaceAll(',', '.')) ?? 0;
      altura = double.tryParse((data['altura'] ?? '0').toString().replaceAll(',', '.')) ?? 0;
      edad = int.tryParse((data['edad'] ?? '0').toString()) ?? 0;

      //calcula a mr(cm) si es mennor a 3m
      if (altura < 3) altura *= 100;

      debugPrint("Calculando metas con estos datos:");
      debugPrint("Sexo: $sexo");
      debugPrint("Edad: $edad");
      debugPrint("Peso: $peso kg");
      debugPrint("Altura: $altura cm");
      debugPrint("Objetivo: $objetivo");

      //Calcular TDEE
      double tdee = (sexo.toLowerCase() == 'masculino')
          ? 10 * peso + 6.25 * altura - 5 * edad + 5
          : 10 * peso + 6.25 * altura - 5 * edad - 161;

      if (objetivo.toLowerCase() == 'bajar') tdee *= 0.8;
      if (objetivo.toLowerCase() == 'subir') tdee *= 1.15;

      //Macros
      metasCalorias = tdee;
      metasProteina = peso * 1.8;
      metasGrasa = peso * 0.8;
      metasCarbs = (tdee - ((metasProteina * 4) + (metasGrasa * 9))) / 4;
      metasFibra = peso * 0.3;

      debugPrint("Metas calculadas:");
      debugPrint("Calorías: ${metasCalorias.toStringAsFixed(1)} kcal");
      debugPrint("Proteína: ${metasProteina.toStringAsFixed(1)} g");
      debugPrint("Grasa: ${metasGrasa.toStringAsFixed(1)} g");
      debugPrint("Carbohidratos: ${metasCarbs.toStringAsFixed(1)} g");
      debugPrint("Fibra: ${metasFibra.toStringAsFixed(1)} g");

    } catch (e) {
      debugPrint("Error calculando metas diarias: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  ///reinicia barras - diariamente
  Future<void> reiniciarBarrasSiNuevoDia() async {
    final prefs = await SharedPreferences.getInstance();

    final hoy = DateTime.now();
    final fechaUltimoRegistroStr = prefs.getString('fechaUltimoRegistro') ?? '';
    DateTime? fechaUltimoRegistro;

    if (fechaUltimoRegistroStr.isNotEmpty) {
      fechaUltimoRegistro = DateTime.tryParse(fechaUltimoRegistroStr);
    }

    if (fechaUltimoRegistro == null ||
        fechaUltimoRegistro.day != hoy.day ||
        fechaUltimoRegistro.month != hoy.month ||
        fechaUltimoRegistro.year != hoy.year) {

      //reiniciar barras diarias
      caloriasTotalesHoy = 0;
      totalProteina = 0;
      totalGrasa = 0;
      totalCarbs = 0;
      totalFibra = 0;

      await prefs.setString('fechaUltimoRegistro', hoy.toIso8601String());
      notifyListeners();
      debugPrint("Nuevo día detectado: barras reiniciadas a 0");
    }
  }

  ///muestra las notificaciones
  bool _notificacion50 = false;
  bool _notificacion75 = false;
  bool _notificacion100 = false;

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


  // --------------------------------------






}

