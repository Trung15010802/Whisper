import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'const/ui_const.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: UIConst.colorSchemeSeed,
        textTheme: GoogleFonts.alataTextTheme(
          TextTheme(
            displayLarge: TextStyle(
              fontSize: UIConst.displayLargeFontSize,
            ),
            bodyLarge: TextStyle(
              fontSize: UIConst.bodyLargeFontSize,
            ),
          ),
        ),
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
