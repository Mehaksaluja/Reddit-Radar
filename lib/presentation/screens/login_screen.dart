import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _lastAuthError;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final authService = AuthService();
    try {
      final token = await authService.loginWithReddit();
      if (token != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (mounted) {
        setState(() => _lastAuthError = 'Token is null after OAuth callback.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: token is null.')),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        setState(() => _lastAuthError = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: $message")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radar, size: 100, color: Color(0xFFFF4500)),
            const SizedBox(height: 20),
            const Text(
              "Reddit Radar",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Log in to start finding high-intent leads automatically.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 50),
            if (_lastAuthError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _lastAuthError!,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFFFF4500))
              : ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text("CONTINUE WITH REDDIT"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4500),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}