import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:miapk/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List personas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final data = await ApiService.getPersonas();
    setState(() { personas = data; loading = false; });
  }

  int get total => personas.length;

  double get promedioEdad {
    if (personas.isEmpty) return 0;
    final suma = personas.fold(0, (acc, p) => acc + (p['edad'] as int));
    return suma / total;
  }

  Map? get masJoven {
    if (personas.isEmpty) return null;
    return personas.reduce((a, b) => (a['edad'] as int) < (b['edad'] as int) ? a : b);
  }

  Map? get masViejo {
    if (personas.isEmpty) return null;
    return personas.reduce((a, b) => (a['edad'] as int) > (b['edad'] as int) ? a : b);
  }

  Map<String, int> get distribucionEdades {
    final Map<String, int> grupos = {
      '0-18': 0,
      '19-30': 0,
      '31-45': 0,
      '46-60': 0,
      '60+': 0,
    };
    for (final p in personas) {
      final edad = p['edad'] as int;
      if (edad <= 18) grupos['0-18'] = grupos['0-18']! + 1;
      else if (edad <= 30) grupos['19-30'] = grupos['19-30']! + 1;
      else if (edad <= 45) grupos['31-45'] = grupos['31-45']! + 1;
      else if (edad <= 60) grupos['46-60'] = grupos['46-60']! + 1;
      else grupos['60+'] = grupos['60+']! + 1;
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : personas.isEmpty
              ? const Center(child: Text('No hay datos aún'))
              : RefreshIndicator(
                  onRefresh: cargarDatos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarjetas de resumen
                        Row(children: [
                          _statCard('Total', '$total', Icons.people, Colors.purple),
                          const SizedBox(width: 12),
                          _statCard('Promedio edad', '${promedioEdad.toStringAsFixed(1)}', Icons.analytics, Colors.blue),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          _statCard('Más joven', masJoven != null ? '${masJoven!['nombre']} (${masJoven!['edad']})' : '-', Icons.child_care, Colors.green),
                          const SizedBox(width: 12),
                          _statCard('Mayor', masViejo != null ? '${masViejo!['nombre']} (${masViejo!['edad']})' : '-', Icons.elderly, Colors.orange),
                        ]),
                        const SizedBox(height: 24),

                        // Gráfica de barras
                        const Text('Distribución por edades',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (distribucionEdades.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final keys = distribucionEdades.keys.toList();
                                      if (value.toInt() < keys.length) {
                                        return Text(keys[value.toInt()], style: const TextStyle(fontSize: 10));
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              barGroups: distribucionEdades.entries.toList().asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.value.toDouble(),
                                      color: const Color(0xFF6C63FF),
                                      width: 22,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Lista resumen
                        const Text('Todas las personas',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...personas.map((p) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6C63FF),
                            child: Text(p['nombre'][0], style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text('${p['nombre']} ${p['apellido']}'),
                          trailing: Text('${p['edad']} años', style: const TextStyle(color: Colors.grey)),
                        )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}