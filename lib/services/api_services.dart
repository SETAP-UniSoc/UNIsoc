import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = "http://10.128.4.254:8000/api";

  static Future<List> getSocieties() async {
    final response = await http.get(Uri.parse("$baseUrl/societies/"));
    return jsonDecode(response.body);
  }

  static Future<List> getSocietyEvents(int id) async {
    final response =
        await http.get(Uri.parse("$baseUrl/society/$id/events/"));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getEventCount(int id) async {
    final response =
        await http.get(Uri.parse("$baseUrl/event/$id/count/"));
    return jsonDecode(response.body);
  }
}