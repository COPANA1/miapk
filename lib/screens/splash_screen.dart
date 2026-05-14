import 'package:flutter/material.dart';
import 'package:miapk/services/api_service.dart';
import 'package:miapk/screens/login_screen.dart';
import 'package:miapk/screens/personas_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkSession();
  }

  void _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    bool hasToken = await ApiService.loadToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => hasToken ? PersonasScreen() : LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_rounded, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text('Mi App', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text('Gestión de Personas', style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}