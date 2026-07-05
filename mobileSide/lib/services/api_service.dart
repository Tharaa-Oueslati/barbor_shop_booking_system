import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/appointment.dart';
import '../models/barber.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator localhost
  // For iOS simulator, use: http://localhost:8080/api
  // For real device, use your machine's IP: http://192.168.x.x:8080/api

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String?> _getToken() async {
    final prefs = await _prefs;
    return prefs.getString('token');
  }

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Store token and user
      final prefs = await _prefs;
      await prefs.setString('token', authResponse.token);
      await prefs.setString('user', jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else if (response.statusCode == 401) {
      throw Exception('Wrong password');
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Appointments
  Future<List<Appointment>> getAllAppointments() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<List<Appointment>> getBarberAppointments(int barberId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/barbers/$barberId/appointments'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load barber appointments');
    }
  }

  Future<void> confirmAppointment(int appointmentId) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/confirm'),
      headers: _headers(token: token),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to confirm appointment');
    }
  }

  Future<void> cancelAppointment(int appointmentId) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/cancel'),
      headers: _headers(token: token),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to cancel appointment');
    }
  }

  // Barbers
  Future<List<Barber>> getAllBarbers() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/barbers'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Barber.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load barbers');
    }
  }

  Future<List<Barber>> getActiveBarbers() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/barbers/active'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Barber.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active barbers');
    }
  }

  Future<String> getBarberName(int barberId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/barbers/$barberId/name'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      return response.body.replaceAll('"', '');
    } else {
      throw Exception('Failed to load barber name');
    }
  }
}
