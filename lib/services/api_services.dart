import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static String? authToken;
  static int? societyId; // Admin's society ID
  static String? societyName; // Admin's society name
  static String? adminName; // Admin's personal name

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    if (authToken != null) "Authorization": "Token $authToken",
  };

  // -------- PUBLIC ENDPOINTS --------

  static Future<List> getSocieties() async {
    final response = await http.get(
      Uri.parse("$baseUrl/societies/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<List> getSocietyEvents(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/society/$id/events/"),
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
    return http.post(Uri.parse("$baseUrl/society/$id/join/"), headers: headers);
  }

  static Future<http.Response> leaveSociety(int id) {
    return http.post(
      Uri.parse("$baseUrl/society/$id/leave/"),
      headers: headers,
    );
  }
}
