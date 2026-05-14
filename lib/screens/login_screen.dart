import 'package:flutter/material.dart';
import 'package:miapk/main.dart';
import 'package:miapk/services/api_service.dart';
import 'package:miapk/screens/personas_screen.dart';
import 'package:miapk/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool obscure = true;

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    bool ok = await ApiService.login(emailCtrl.text, passCtrl.text);
    setState(() => loading = false);
    if (ok) {
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PersonasScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Icon(Icons.lock_rounded, size: 80, color: Color(0xFF6C63FF)),
              const SizedBox(height: 20),
              const Text('Bienvenido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Inicia sesión para continuar', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu email';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu password';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ingresar', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('¿No tienes cuenta? Regístrate', style: TextStyle(color: Color(0xFF6C63FF))),
              ),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () => MyApp.of(context)?.toggleTheme(),
                tooltip: 'Cambiar tema',
              ),
            ]),
          ),
        ),
      ),
    );
  }
}