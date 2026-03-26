import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/splash_screen.dart'; // Sahi path yahan hai

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const RedditRadarApp());
}

class RedditRadarApp extends StatelessWidget {
  const RedditRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reddit Radar',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030303),
        primaryColor: const Color(0xFFFF4500),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4500),
          surface: Color(0xFF1A1A1B),
        ),
        cardTheme: const CardThemeData( // Added 'const' here
          color: Color(0xFF1A1A1B),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}