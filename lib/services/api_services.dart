import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.128.5.248:8000/api";

  static String? authToken;
  static int? societyId; // Admin's society ID
  static String? societyName; // Admin's society name
  static String? adminName; // Admin's personal name
  static Set<int> joinedSocieties = {};

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    if (authToken != null) "Authorization": "Token $authToken",
  };

  /// Checks if the given society ID belongs to the logged-in admin.
/// Returns false if the admin has no society assigned (societyId is null).

   static bool isAdminOfSociety(int societyIdToCheck) {
    
    return societyId != null && societyId == societyIdToCheck;
  }

  // -------- PUBLIC ENDPOINTS --------

static Future<List> getSocieties() async {
  final response = await http.get(
    Uri.parse("$baseUrl/societies/"),
    headers: headers,
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("API Error: ${response.statusCode}");
  }
}

  static Future<List> getMySocieties() async {
    final response = await http.get(
      Uri.parse("$baseUrl/my-societies/"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }

    throw Exception(
      "Failed to load my societies: ${response.statusCode} ${response.body}",
    );
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


