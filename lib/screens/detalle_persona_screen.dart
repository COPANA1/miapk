import 'package:flutter/material.dart';
import 'package:miapk/services/api_service.dart';

class DetallePersonaScreen extends StatelessWidget {
  final Map persona;
  final VoidCallback onActualizado;
  final VoidCallback onEditar;

  const DetallePersonaScreen({
    super.key,
    required this.persona,
    required this.onActualizado,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = [Colors.purple, Colors.blue, Colors.teal, Colors.orange, Colors.pink, Colors.indigo];
    final color = colores[persona['nombre'].toString().codeUnitAt(0) % colores.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.1)),
              child: Column(
                children: [
                  Hero(
                    tag: 'avatar_${persona['id']}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: color,
                      child: Text(
                        persona['nombre'][0].toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${persona['nombre']} ${persona['apellido']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(persona['email'], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoCard(Icons.person, 'Nombre', persona['nombre']),
                  const SizedBox(height: 12),
                  _infoCard(Icons.family_restroom, 'Apellido', persona['apellido']),
                  const SizedBox(height: 12),
                  _infoCard(Icons.email, 'Email', persona['email']),
                  const SizedBox(height: 12),
                  _infoCard(Icons.cake, 'Edad', '${persona['edad']} años'),
                  const SizedBox(height: 12),
                  _infoCard(Icons.calendar_today, 'Registrado', persona['created_at'].toString().substring(0, 10)),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEditar();
                          },
                          icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                          label: const Text('Editar', style: TextStyle(color: Color(0xFF6C63FF))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF6C63FF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('¿Eliminar?'),
                                content: Text('¿Eliminar a ${persona['nombre']}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ApiService.deletePersona(persona['id']);
                              Navigator.pop(context);
                              onActualizado();
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}