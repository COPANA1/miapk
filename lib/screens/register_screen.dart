import 'package:flutter/material.dart';
import 'package:miapk/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool obscure = true;

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    bool ok = await ApiService.register(nameCtrl.text, emailCtrl.text, passCtrl.text);
    setState(() => loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registrado correctamente!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Icon(Icons.person_add_rounded, size: 70, color: Color(0xFF6C63FF)),
              const SizedBox(height: 30),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 16),
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
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Registrarse', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}