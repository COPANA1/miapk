import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.85.242.204:8000/api';
  static String? token;

  static Future<void> saveToken(String t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', t);
    token = t;
  }

  static Future<bool> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    return token != null;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token = null;
  }

  static Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      await saveToken(jsonDecode(response.body)['token']);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await clearToken();
  }

  static Future<List> getPersonas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/personas'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> createPersona(String nombre, String apellido, String email, int edad) async {
    final response = await http.post(
      Uri.parse('$baseUrl/personas'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'nombre': nombre, 'apellido': apellido, 'email': email, 'edad': edad}),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updatePersona(int id, String nombre, String apellido, String email, int edad) async {
    final response = await http.put(
      Uri.parse('$baseUrl/personas/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'nombre': nombre, 'apellido': apellido, 'email': email, 'edad': edad}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletePersona(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/personas/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }
}