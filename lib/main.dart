import 'package:NutriCam/modules/account/presentation/pages/view_home_user/home_page_admi.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'loading_page.dart';
import 'modules/account/presentation/manager/firebase_function_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: true, // Cambia a false en producción
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutriScamModuleProvider()),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que decide qué pantalla mostrar según el estado del usuario
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se conecta a Firebase, mostramos loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }

        // Usuario logueado → HomePage
        if (snapshot.hasData) {
          // Inicializamos los datos del provider si es necesario
          final provider = Provider.of<NutriScamModuleProvider>(context, listen: false);
          provider.initUserData();

          return const HomePageAdmi();
        }

        // Usuario no logueado → LoginPage
        return const LoadingPage();
      },
    );
  }
}
