
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:unisoc/services/api_services.dart';

// class MyEventsPage extends StatefulWidget {
//   final int? societyId; // Make it optional
  
//   const MyEventsPage({super.key, this.societyId});

//   @override
//   State<MyEventsPage> createState() => _MyEventsPageState();
// }

// class _MyEventsPageState extends State<MyEventsPage> {
//   List<Map<String, dynamic>> _myEvents = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadMyAttendingEvents();
//   }

//   Future<void> _loadMyAttendingEvents() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // If societyId is provided, only get events from that society
//       if (widget.societyId != null) {
//         final eventsResponse = await http.get(
//           Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
//           headers: ApiService.headers,
//         );

//         if (eventsResponse.statusCode == 200) {
//           final List<dynamic> events = jsonDecode(eventsResponse.body);
//           List<Map<String, dynamic>> attendingEvents = [];

//           for (var event in events) {
//             final eventId = event["id"];
//             final attendanceResponse = await http.get(
//               Uri.parse("${ApiService.baseUrl}/events/$eventId/attending/"),
//               headers: ApiService.headers,
//             );

//             if (attendanceResponse.statusCode == 200) {
//               final attendanceData = jsonDecode(attendanceResponse.body);
//               if (attendanceData["is_attending"] == true) {
//                 attendingEvents.add({
//                   "id": eventId,
//                   "title": event["title"] ?? "Untitled Event",
//                   "description": event["description"] ?? "No description",
//                   "location": event["location"] ?? "No location",
//                   "start_time": event["start_time"],
//                   "end_time": event["end_time"],
//                   "capacity_limit": event["capacity_limit"],
//                 });
//               }
//             }
//           }

//           setState(() {
//             _myEvents = attendingEvents;
//             _isLoading = false;
//           });
//         } else {
//           setState(() {
//             _errorMessage = "Failed to load events";
//             _isLoading = false;
//           });
//         }
//       } else {
//         // Load all attending events from all societies (original logic)
//         final societiesResponse = await http.get(
//           Uri.parse("${ApiService.baseUrl}/societies/"),
//           headers: ApiService.headers,
//         );

//         if (societiesResponse.statusCode != 200) {
//           throw Exception("Failed to load societies");
//         }

//         final List<dynamic> societies = jsonDecode(societiesResponse.body);
//         List<Map<String, dynamic>> attendingEvents = [];

//         for (var society in societies) {
//           final societyId = society["id"];
//           final societyName = society["name"];
          
//           final eventsResponse = await http.get(
//             Uri.parse("${ApiService.baseUrl}/societies/$societyId/events/"),
//             headers: ApiService.headers,
//           );

//           if (eventsResponse.statusCode == 200) {
//             final List<dynamic> events = jsonDecode(eventsResponse.body);
            
//             for (var event in events) {
//               final eventId = event["id"];
//               final attendanceResponse = await http.get(
//                 Uri.parse("${ApiService.baseUrl}/events/$eventId/attending/"),
//                 headers: ApiService.headers,
//               );
              
//               if (attendanceResponse.statusCode == 200) {
//                 final attendanceData = jsonDecode(attendanceResponse.body);
//                 if (attendanceData["is_attending"] == true) {
//                   attendingEvents.add({
//                     "id": eventId,
//                     "title": event["title"] ?? "Untitled Event",
//                     "description": event["description"] ?? "No description",
//                     "location": event["location"] ?? "No location",
//                     "start_time": event["start_time"],
//                     "end_time": event["end_time"],
//                     "society_id": societyId,
//                     "society_name": societyName,
//                     "capacity_limit": event["capacity_limit"],
//                   });
//                 }
//               }
//             }
//           }
//         }

//         attendingEvents.sort((a, b) {
//           final aTime = DateTime.parse(a["start_time"]);
//           final bTime = DateTime.parse(b["start_time"]);
//           return aTime.compareTo(bTime);
//         });

//         setState(() {
//           _myEvents = attendingEvents;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       print("Error loading attending events: $e");
//     }
//   }

//   Future<void> _leaveEvent(int eventId) async {
//     try {
//       final response = await http.post(
//         Uri.parse("${ApiService.baseUrl}/events/$eventId/leave/"),
//         headers: ApiService.headers,
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _myEvents.removeWhere((event) => event["id"] == eventId);
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("You have left the event"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         final error = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(error["error"] ?? "Failed to leave event"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Error leaving event"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   String _formatDate(String dateTimeString) {
//     final dateTime = DateTime.parse(dateTimeString).toLocal();
//     final day = dateTime.day;
//     final month = _getMonthAbbreviation(dateTime.month);
//     final year = dateTime.year;
//     final hour = dateTime.hour.toString().padLeft(2, '0');
//     final minute = dateTime.minute.toString().padLeft(2, '0');
    
//     return "$day $month $year at $hour:$minute";
//   }
  
//   String _getMonthAbbreviation(int month) {
//     const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//     return months[month - 1];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         title: const Text(
//           "My Events",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline, size: 64, color: Colors.grey),
//                       const SizedBox(height: 16),
//                       Text(
//                         _errorMessage!,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadMyAttendingEvents,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF8B5CF6),
//                         ),
//                         child: const Text("Try Again"),
//                       ),
//                     ],
//                   ),
//                 )
//               : _myEvents.isEmpty
//                   ? const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.event_busy, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text(
//                             "You're not attending any events yet",
//                             style: TextStyle(color: Colors.grey, fontSize: 16),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             "Go to a society page and tap 'Attend Event'",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: _myEvents.length,
//                       itemBuilder: (context, index) {
//                         final event = _myEvents[index];
//                         final startTime = DateTime.parse(event["start_time"]);
//                         final isPast = startTime.isBefore(DateTime.now());
                        
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withValues(alpha: 0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                             border: Border.all(color: Colors.grey.shade200),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Society Header (if showing from all societies)
//                               if (event.containsKey("society_name"))
//                                 Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(16),
//                                       topRight: Radius.circular(16),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           gradient: const LinearGradient(
//                                             colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
//                                           ),
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                         child: const Icon(Icons.business, color: Colors.white, size: 20),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               event["society_name"],
//                                               style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Color(0xFF1F2937),
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               _formatDate(event["start_time"]),
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.grey.shade600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       if (isPast)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey.shade200,
//                                             borderRadius: BorderRadius.circular(20),
//                                           ),
//                                           child: const Text(
//                                             "Past",
//                                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
                              
//                               // Event Details
//                               Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       event["title"],
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF1F2937),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
                                    
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.calendar_today, size: 16, color: Color(0xFF8B5CF6)),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           _formatDate(event["start_time"]),
//                                           style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
                                    
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.location_on, size: 16, color: Color(0xFF8B5CF6)),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: Text(
//                                             event["location"],
//                                             style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
                                    
//                                     if (event["description"] != null && event["description"].isNotEmpty) ...[
//                                       const SizedBox(height: 12),
//                                       const Divider(height: 1),
//                                       const SizedBox(height: 12),
//                                       Text(
//                                         event["description"],
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade700,
//                                           height: 1.5,
//                                         ),
//                                       ),
//                                     ],
                                    
//                                     if (event["capacity_limit"] != null) ...[
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         children: [
//                                           const Icon(Icons.people, size: 16, color: Color(0xFF8B5CF6)),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             "Capacity: ${event["capacity_limit"]}",
//                                             style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
                                    
//                                     const SizedBox(height: 20),
                                    
//                                     SizedBox(
//                                       width: double.infinity,
//                                       child: ElevatedButton.icon(
//                                         onPressed: isPast ? null : () => _leaveEvent(event["id"]),
//                                         icon: Icon(
//                                           Icons.exit_to_app,
//                                           color: isPast ? Colors.grey : Colors.red,
//                                           size: 18,
//                                         ),
//                                         label: Text(
//                                           isPast ? "Event Passed" : "Leave Event",
//                                           style: TextStyle(
//                                             color: isPast ? Colors.grey : Colors.red,
//                                           ),
//                                         ),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: isPast ? Colors.grey.shade100 : Colors.red.shade50,
//                                           padding: const EdgeInsets.symmetric(vertical: 12),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                             side: BorderSide(
//                                               color: isPast ? Colors.grey.shade300 : Colors.red.shade200,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }









































import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';

class MyEventsPage extends StatefulWidget {
  final int? societyId; // Make it optional
  
  const MyEventsPage({super.key, this.societyId});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<Map<String, dynamic>> _myEvents = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isMounted = true;  // ✅ ADDED: Track if widget is mounted

  @override
  void initState() {
    super.initState();
    _loadMyAttendingEvents();
  }

  @override
  void dispose() {
    _isMounted = false;  // ✅ ADDED: Set to false when disposed
    super.dispose();
  }

  Future<void> _loadMyAttendingEvents() async {
    // ✅ ADDED: Check if widget is still mounted
    if (!_isMounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // If societyId is provided, only get events from that society
      if (widget.societyId != null) {
        final eventsResponse = await http.get(
          Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
          headers: ApiService.headers,
        );

        // ✅ ADDED: Check if widget is still mounted
        if (!_isMounted) return;

        if (eventsResponse.statusCode == 200) {
          final List<dynamic> events = jsonDecode(eventsResponse.body);
          List<Map<String, dynamic>> attendingEvents = [];

          for (var event in events) {
            final eventId = event["id"];
            final attendanceResponse = await http.get(
              Uri.parse("${ApiService.baseUrl}/events/$eventId/attending/"),
              headers: ApiService.headers,
            );

            // ✅ ADDED: Check if widget is still mounted
            if (!_isMounted) return;

            if (attendanceResponse.statusCode == 200) {
              final attendanceData = jsonDecode(attendanceResponse.body);
              if (attendanceData["is_attending"] == true) {
                attendingEvents.add({
                  "id": eventId,
                  "title": event["title"] ?? "Untitled Event",
                  "description": event["description"] ?? "No description",
                  "location": event["location"] ?? "No location",
                  "start_time": event["start_time"],
                  "end_time": event["end_time"],
                  "capacity_limit": event["capacity_limit"],
                });
              }
            }
          }

          // ✅ ADDED: Check if widget is still mounted
          if (!_isMounted) return;

          setState(() {
            _myEvents = attendingEvents;
            _isLoading = false;
          });
        } else {
          // ✅ ADDED: Check if widget is still mounted
          if (!_isMounted) return;
          
          setState(() {
            _errorMessage = "Failed to load events";
            _isLoading = false;
          });
        }
      } else {
        // Load all attending events from all societies (original logic)
        final societiesResponse = await http.get(
          Uri.parse("${ApiService.baseUrl}/societies/"),
          headers: ApiService.headers,
        );

        // ✅ ADDED: Check if widget is still mounted
        if (!_isMounted) return;

        if (societiesResponse.statusCode != 200) {
          throw Exception("Failed to load societies");
        }

        final List<dynamic> societies = jsonDecode(societiesResponse.body);
        List<Map<String, dynamic>> attendingEvents = [];

        for (var society in societies) {
          final societyId = society["id"];
          final societyName = society["name"];
          
          final eventsResponse = await http.get(
            Uri.parse("${ApiService.baseUrl}/societies/$societyId/events/"),
            headers: ApiService.headers,
          );

          // ✅ ADDED: Check if widget is still mounted
          if (!_isMounted) return;

          if (eventsResponse.statusCode == 200) {
            final List<dynamic> events = jsonDecode(eventsResponse.body);
            
            for (var event in events) {
              final eventId = event["id"];
              final attendanceResponse = await http.get(
                Uri.parse("${ApiService.baseUrl}/events/$eventId/attending/"),
                headers: ApiService.headers,
              );
              
              // ✅ ADDED: Check if widget is still mounted
              if (!_isMounted) return;
              
              if (attendanceResponse.statusCode == 200) {
                final attendanceData = jsonDecode(attendanceResponse.body);
                if (attendanceData["is_attending"] == true) {
                  attendingEvents.add({
                    "id": eventId,
                    "title": event["title"] ?? "Untitled Event",
                    "description": event["description"] ?? "No description",
                    "location": event["location"] ?? "No location",
                    "start_time": event["start_time"],
                    "end_time": event["end_time"],
                    "society_id": societyId,
                    "society_name": societyName,
                    "capacity_limit": event["capacity_limit"],
                  });
                }
              }
            }
          }
        }

        attendingEvents.sort((a, b) {
          final aTime = DateTime.parse(a["start_time"]);
          final bTime = DateTime.parse(b["start_time"]);
          return aTime.compareTo(bTime);
        });

        // ✅ ADDED: Check if widget is still mounted
        if (!_isMounted) return;

        setState(() {
          _myEvents = attendingEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      // ✅ ADDED: Check if widget is still mounted
      if (!_isMounted) return;
      
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print("Error loading attending events: $e");
    }
  }

  Future<void> _leaveEvent(int eventId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/events/$eventId/leave/"),
        headers: ApiService.headers,
      );

      // ✅ ADDED: Check if widget is still mounted
      if (!_isMounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _myEvents.removeWhere((event) => event["id"] == eventId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You have left the event"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        // ✅ ADDED: Check if widget is still mounted
        if (!_isMounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error["error"] ?? "Failed to leave event"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ✅ ADDED: Check if widget is still mounted
      if (!_isMounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error leaving event"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    final day = dateTime.day;
    final month = _getMonthAbbreviation(dateTime.month);
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return "$day $month $year at $hour:$minute";
  }
  
  String _getMonthAbbreviation(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "My Events",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMyAttendingEvents,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                        ),
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
              : _myEvents.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "You're not attending any events yet",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Go to a society page and tap 'Attend Event'",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _myEvents.length,
                      itemBuilder: (context, index) {
                        final event = _myEvents[index];
                        final startTime = DateTime.parse(event["start_time"]);
                        final isPast = startTime.isBefore(DateTime.now());
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Society Header (if showing from all societies)
                              if (event.containsKey("society_name"))
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.business, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event["society_name"],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(event["start_time"]),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isPast)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "Past",
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              
                              // Event Details
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event["title"],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF8B5CF6)),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(event["start_time"]),
                                          style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Color(0xFF8B5CF6)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            event["location"],
                                            style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    if (event["description"] != null && event["description"].isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Text(
                                        event["description"],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                    
                                    if (event["capacity_limit"] != null) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.people, size: 16, color: Color(0xFF8B5CF6)),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Capacity: ${event["capacity_limit"]}",
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                          ),
                                        ],
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 20),
                                    
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: isPast ? null : () => _leaveEvent(event["id"]),
                                        icon: Icon(
                                          Icons.exit_to_app,
                                          color: isPast ? Colors.grey : Colors.red,
                                          size: 18,
                                        ),
                                        label: Text(
                                          isPast ? "Event Passed" : "Leave Event",
                                          style: TextStyle(
                                            color: isPast ? Colors.grey : Colors.red,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPast ? Colors.grey.shade100 : Colors.red.shade50,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: isPast ? Colors.grey.shade300 : Colors.red.shade200,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}