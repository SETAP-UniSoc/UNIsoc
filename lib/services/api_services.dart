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
      Uri.parse("$baseUrl/societies/$id/events/"),
      headers: headers,
    );

    print("STATUS: ${response.statusCode}"); // helpful for debugging
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception(
        "Failed to load events: ${response.statusCode} ${response.body}",
      );
    }
  }

  static Future<List> getEventsForJoinedSocieties() async {
    try {
      // Fetch the societies the user has joined
      final societiesResponse = await http.get(
        Uri.parse("$baseUrl/my-societies/"),
        headers: headers,
      );

      if (societiesResponse.statusCode != 200) {
        throw Exception("Failed to fetch societies: ${societiesResponse.body}");
      }

      final societies = jsonDecode(societiesResponse.body) as List;

      // Fetch events for each society
      List events = [];
      for (var society in societies) {
        final societyId = society['id'];
        final eventsResponse = await http.get(
          Uri.parse("$baseUrl/societies/$societyId/events/"),
          headers: headers,
        );

        if (eventsResponse.statusCode == 200) {
          final societyEvents = jsonDecode(eventsResponse.body) as List;
          final tagged = societyEvents
              .map(
                (e) => {
                  ...e,
                  'society_id': societyId,
                  'society_name': society['name'],
                },
              )
              .toList();
          events.addAll(tagged);
        }
      }

      // Filter upcoming events
      final now = DateTime.now();
      final upcomingEvents = events.where((event) {
        final eventDate = DateTime.parse(event['start_time']);
        return eventDate.isAfter(now);
      }).toList();

      return upcomingEvents;
    } catch (e) {
      throw Exception("Error fetching events: $e");
    }
  }

  //add debugging

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
