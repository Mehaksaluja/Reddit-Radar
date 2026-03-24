import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Ye import zaroori hai
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  // Separate function for logic to keep it clean
  Future<void> _navigateToNext() async {
    // 3 second wait for branding
    await Future.delayed(const Duration(seconds: 3));
    
    // 2. Getting instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // 3. Removed 'const' because 'token' is a variable
          builder: (context) => token != null ? const DashboardScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF030303),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar, size: 80, color: Color(0xFFFF4500)),
            SizedBox(height: 20),
            Text(
              "REDDIT RADAR",
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(color: Color(0xFFFF4500)),
          ],
        ),
      ),
    );
  }
}