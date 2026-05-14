import 'package:flutter/material.dart';
import 'package:miapk/main.dart';
import 'package:miapk/services/api_service.dart';
import 'package:miapk/screens/login_screen.dart';
import 'package:miapk/screens/detalle_persona_screen.dart';
import 'package:miapk/screens/dashboard_screen.dart';

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key});
  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  List personas = [];
  List filtradas = [];
  bool loading = true;
  final searchCtrl = TextEditingController();
  final colores = [Colors.purple, Colors.blue, Colors.teal, Colors.orange, Colors.pink, Colors.indigo];

  @override
  void initState() {
    super.initState();
    cargarPersonas();
    searchCtrl.addListener(_filtrar);
  }

  void _filtrar() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtradas = personas.where((p) =>
        p['nombre'].toLowerCase().contains(q) ||
        p['apellido'].toLowerCase().contains(q) ||
        p['email'].toLowerCase().contains(q)
      ).toList();
    });
  }

  Future<void> cargarPersonas() async {
    setState(() => loading = true);
    final data = await ApiService.getPersonas();
    setState(() { personas = data; filtradas = data; loading = false; });
  }

  void confirmarEliminar(int id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar persona?'),
        content: Text('¿Estás seguro de eliminar a $nombre?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              bool ok = await ApiService.deletePersona(id);
              if (ok) {
                setState(() {
                  personas.removeWhere((p) => p['id'] == id);
                  filtradas.removeWhere((p) => p['id'] == id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Persona eliminada'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await ApiService.logout();
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => const LoginScreen(),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ));
  }

  void mostrarFormulario({Map? persona}) {
    final nombreCtrl = TextEditingController(text: persona?['nombre'] ?? '');
    final apellidoCtrl = TextEditingController(text: persona?['apellido'] ?? '');
    final emailCtrl = TextEditingController(text: persona?['email'] ?? '');
    final edadCtrl = TextEditingController(text: persona?['edad']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    bool editando = persona != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(editando ? 'Editar Persona' : 'Nueva Persona',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: nombreCtrl,
              decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: apellidoCtrl,
              decoration: InputDecoration(labelText: 'Apellido', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo requerido';
                if (!v.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: edadCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Edad', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo requerido';
                if (int.tryParse(v) == null) return 'Debe ser un número';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final edad = int.parse(edadCtrl.text);
                  bool ok = editando
                      ? await ApiService.updatePersona(persona!['id'], nombreCtrl.text, apellidoCtrl.text, emailCtrl.text, edad)
                      : await ApiService.createPersona(nombreCtrl.text, apellidoCtrl.text, emailCtrl.text, edad);
                  Navigator.pop(context);
                  if (ok) cargarPersonas();
                },
                child: Text(editando ? 'Actualizar' : 'Guardar',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Color _colorAleatorio(String nombre) {
    final index = nombre.codeUnitAt(0) % colores.length;
    return colores[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personas'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
            tooltip: 'Dashboard',
          ),
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: () => MyApp.of(context)?.toggleTheme(), tooltip: 'Tema'),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout, tooltip: 'Cerrar sesión'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarFormulario(),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva persona', style: TextStyle(color: Colors.white)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar persona...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () { searchCtrl.clear(); _filtrar(); })
                  : null,
            ),
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : filtradas.isEmpty
                  ? const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No se encontraron personas', style: TextStyle(color: Colors.grey)),
                      ],
                    ))
                  : RefreshIndicator(
                      onRefresh: cargarPersonas,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtradas.length,
                        itemBuilder: (_, i) {
                          final p = filtradas[i];
                          final color = _colorAleatorio(p['nombre']);
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 300 + (i * 80)),
                            builder: (_, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 400),
                                    pageBuilder: (_, __, ___) => DetallePersonaScreen(
                                      persona: p,
                                      onActualizado: cargarPersonas,
                                      onEditar: () => mostrarFormulario(persona: p),
                                    ),
                                    transitionsBuilder: (_, animation, __, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.1),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leading: Hero(
                                  tag: 'avatar_${p['id']}',
                                  child: CircleAvatar(
                                    backgroundColor: color,
                                    child: Text(
                                      p['nombre'][0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                title: Text('${p['nombre']} ${p['apellido']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${p['email']} • ${p['edad']} años'),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                                    onPressed: () => mostrarFormulario(persona: p),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => confirmarEliminar(p['id'], p['nombre']),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}