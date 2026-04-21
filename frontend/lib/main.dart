import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'services/auth_service.dart';
import 'data/plant_translations.dart';

void main() {
  runApp(const MyApp());
  print('Number of translated plants: ${PlantTranslations.getPlantCount()}');
  print('Number of valid plants: ${PlantTranslations.getValidPlantCount()}');
  print(
      'Number of high confidence tamazight: ${PlantTranslations.countHighConfidenceTamazight()}');
  print(
      'Number of plants with both translations: ${PlantTranslations.countWithBothTranslations()}');
  print(
      'Number of plants with amazigh translation: ${PlantTranslations.countWithAmazighTranslation()}');
  print(
      'Number of plants with darija translation: ${PlantTranslations.countWithDarijaTranslation()}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFE Biodiversité',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/camera': (context) => const CameraScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == true) {
          return const CameraScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
