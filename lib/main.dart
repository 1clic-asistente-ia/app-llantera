import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:red_llantera_app/screens/login_screen.dart';
import 'package:red_llantera_app/screens/dashboard_screen.dart';
import 'package:red_llantera_app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Llantera Digital',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: _handleAuthState(),
    );
  }
  
  Widget _handleAuthState() {
    final supabase = Supabase.instance.client;
    return supabase.auth.currentUser != null
        ? const DashboardScreen()
        : const LoginScreen();
  }
}