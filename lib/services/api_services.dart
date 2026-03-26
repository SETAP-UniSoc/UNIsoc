import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.128.4.122:8000/api";

  static String? authToken;
  static int? societyId; // Admin's society ID
  static String? societyName; // Admin's society name

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    if (authToken != null) "Authorization": "Token $authToken",
  };

  // Save login data after admin login
  static void saveAdminLogin(String token, int id, String name) {
    societyName = name;
  }

  // Clear login data on logout
  static void clearAdminLogin() {
    authToken = null;
    societyId = null;
    societyName = null;
  }

  // -------- PUBLIC ENDPOINTS --------

  static Future<List> getSocieties() async {
      Uri.parse("$baseUrl/societies/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Get events for a specific society
  static Future<List> getSocietyEvents(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/societies/$id/events/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getEventCount(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/event/$id/count/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // -------- JOIN / LEAVE --------

  static Future<http.Response> joinSociety(int id) {
    return http.post(
      Uri.parse("$baseUrl/societies/$id/join/"),
      headers: headers,
    );
  }

  static Future<http.Response> leaveSociety(int id) {
    return http.post(
      Uri.parse("$baseUrl/societies/$id/leave/"),
      headers: headers,
    );
  }

  // -------- SOCIETY DETAILS --------

  static Future<Map<String, dynamic>> getSocietyDetails(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/societies/$id/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<http.Response> updateSocietyDescription(int id, String description) async {
    return await http.patch(
      Uri.parse("$baseUrl/societies/$id/"),
      headers: headers,
      body: jsonEncode({"description": description}),
    );
  }
}
