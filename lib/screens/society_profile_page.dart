
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:unisoc/services/api_services.dart';
// import 'package:unisoc/screens/admin/admin_bottom_nav.dart';
// import 'package:unisoc/screens/admin/admin_events_page.dart';
// import 'package:unisoc/screens/my_events_page.dart';

// class SocietyProfilePage extends StatefulWidget {
//   final int societyId;
//   final bool isAdmin;
//   final bool isOwnSociety;  // ✅ ADD THIS NEW PARAMETER

//   const SocietyProfilePage({
//     super.key,
//     required this.societyId,
//     required this.isAdmin,
//     this.isOwnSociety = false,  // ✅ Default to false
//   });

//   @override
//   State<SocietyProfilePage> createState() => _SocietyProfilePageState();
// }

// class _SocietyProfilePageState extends State<SocietyProfilePage> {
//   Map societyData = {};
//   List events = [];
//   bool isLoading = true;
//   bool isEditing = false;
//   bool isMember = false;
//   Timer? pollingTimer;
//   final TextEditingController descController = TextEditingController();
  
//   // Track attending status for each event
//   Map<int, bool> attendingStatus = {};

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//     if (!widget.isAdmin) startPolling();
//   }

//   @override
//   void dispose() {
//     pollingTimer?.cancel();
//     descController.dispose();
//     super.dispose();
//   }

//   void startPolling() {
//     pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
//       loadEvents();
//     });
//   }

//   Future<void> loadData() async {
//     await Future.wait([
//       loadSociety(),
//       loadEvents(),
//       if (!widget.isAdmin) checkMembership(),
//     ]);
//     setState(() => isLoading = false);
//   }

//   Future<void> loadSociety() async {
//     final endpoint = widget.isAdmin
//         ? "${ApiService.baseUrl}/societies/${widget.societyId}/admin/"
//         : "${ApiService.baseUrl}/societies/${widget.societyId}/";

//     try {
//       final response = await http.get(
//         Uri.parse(endpoint),
//         headers: ApiService.headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           societyData = data;
//           descController.text = data["description"] ?? "";
//         });
//       }
//     } catch (e) {
//       print("Error loading society: $e");
//     }
//   }

//   Future<void> loadEvents() async {
//     try {
//       final response = await http.get(
//         Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
//         headers: ApiService.headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as List;
//         final now = DateTime.now();
//         final upcoming = data
//             .where((e) => DateTime.parse(e["start_time"]).isAfter(now))
//             .toList();
//         upcoming.sort((a, b) =>
//             DateTime.parse(a["start_time"]).compareTo(DateTime.parse(b["start_time"])));
//         setState(() => events = upcoming);
        
//         // Check attendance status for each event (regular users only)
//         if (!widget.isAdmin) {
//           for (var event in events) {
//             await checkEventAttendance(event["id"]);
//           }
//         }
//         print("Loaded ${events.length} events");
//       }
//     } catch (e) {
//       print("Error loading events: $e");
//     }
//   }

//   Future<void> checkEventAttendance(int eventId) async {
//     try {
//       final response = await http.get(
//         Uri.parse("${ApiService.baseUrl}/events/$eventId/attending/"),
//         headers: ApiService.headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           attendingStatus[eventId] = data["is_attending"] ?? false;
//         });
//       }
//     } catch (e) {
//       print("Error checking attendance for event $eventId: $e");
//     }
//   }

//   Future<void> toggleEventAttendance(int eventId) async {
//     final isAttending = attendingStatus[eventId] ?? false;
//     final endpoint = isAttending
//         ? "/events/$eventId/leave/"
//         : "/events/$eventId/join/";

//     try {
//       final response = await http.post(
//         Uri.parse("${ApiService.baseUrl}$endpoint"),
//         headers: ApiService.headers,
//       );
      
//       if (response.statusCode == 200) {
//         setState(() {
//           attendingStatus[eventId] = !isAttending;
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               isAttending ? "Left event" : "You're attending! ✓",
//             ),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       } else {
//         final data = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data["error"] ?? "Failed to update attendance"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error toggling attendance: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Error updating attendance"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> saveDescription() async {
//     try {
//       if (descController.text != societyData["description"]) {
//         final response = await http.patch(
//           Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/admin/"),
//           headers: ApiService.headers,
//           body: jsonEncode({"description": descController.text}),
//         );
//         if (response.statusCode == 200) {
//           setState(() {
//             isEditing = false;
//             societyData["description"] = descController.text;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Description saved ✓")),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to save: ${response.statusCode}")),
//           );
//         }
//       } else {
//         setState(() => isEditing = false);
//       }
//     } catch (e) {
//       print("Error saving description: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error saving description")),
//       );
//     }
//   }

//   Future<void> checkMembership() async {
//     try {
//       final response = await http.get(
//         Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/check-membership/"),
//         headers: ApiService.headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() => isMember = data["is_member"] ?? false);
//       }
//     } catch (e) {
//       print("Error checking membership: $e");
//     }
//   }

//   Future<void> toggleJoinSociety() async {
//     final endpoint = isMember
//         ? "/society/${widget.societyId}/leave/"
//         : "/society/${widget.societyId}/join/";

//     try {
//       final response = await http.post(
//         Uri.parse("${ApiService.baseUrl}$endpoint"),
//         headers: ApiService.headers,
//       );
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await checkMembership();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data["message"] ?? "Success")),
//         );
//       }
//     } catch (e) {
//       print("Error toggling membership: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         title: Text(
//           societyData["name"] ?? "Society",
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         actions: widget.isOwnSociety  // ✅ CHANGED: from widget.isAdmin to widget.isOwnSociety
//             ? [
//                 // Calendar icon for managing events (only for admin's own society)
//                 IconButton(
//                   icon: const Icon(Icons.calendar_month, color: Colors.white),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AdminEventsPage(societyId: widget.societyId),
//                       ),
//                     );
//                   },
//                   tooltip: "Manage Events",
//                 ),
//               ]
//             : null,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         societyData["image_url"] != null &&
//                                 societyData["image_url"].toString().isNotEmpty
//                             ? CircleAvatar(
//                                 radius: 60,
//                                 backgroundImage:
//                                     NetworkImage(societyData["image_url"]),
//                                 backgroundColor: Colors.grey[200],
//                               )
//                             : Container(
//                                 width: 120,
//                                 height: 120,
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withValues(alpha: 0.1),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Center(
//                                   child: Icon(Icons.business, size: 60, color: Colors.white),
//                                 ),
//                               ),
//                         const SizedBox(height: 12),
//                         if (societyData["category"] != null &&
//                             societyData["category"].toString().isNotEmpty)
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               societyData["category"],
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF8B5CF6),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 32),

//                   // About Section WITH EDIT BUTTON (only for admin's OWN society)
//                   Row(
//                     children: [
//                       const Text(
//                         "About",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1F2937),
//                         ),
//                       ),
//                       if (widget.isOwnSociety) ...[  // ✅ CHANGED: from widget.isAdmin to widget.isOwnSociety
//                         const SizedBox(width: 12),
//                         IconButton(
//                           icon: Icon(
//                             isEditing ? Icons.save : Icons.edit,
//                             color: const Color(0xFF8B5CF6),
//                             size: 20,
//                           ),
//                           onPressed: () {
//                             if (isEditing) {
//                               saveDescription();
//                             } else {
//                               setState(() => isEditing = true);
//                             }
//                           },
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   isEditing && widget.isOwnSociety  // ✅ CHANGED: from widget.isAdmin to widget.isOwnSociety
//                       ? TextField(
//                           controller: descController,
//                           maxLines: 5,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
//                             ),
//                             hintText: "Write a description for your society...",
//                             hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                           ),
//                         )
//                       : Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF3F4F6),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             societyData["description"]?.isNotEmpty == true
//                                 ? societyData["description"]
//                                 : widget.isOwnSociety  // ✅ CHANGED
//                                     ? "No description yet — tap edit to add one."
//                                     : "No description yet.",
//                             style: const TextStyle(
//                                 fontSize: 15, color: Color(0xFF374151), height: 1.6),
//                           ),
//                         ),

//                   const SizedBox(height: 24),

//                   // Join/Leave Society button (only for regular users, not admins)
//                   if (!widget.isAdmin)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: toggleJoinSociety,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isMember
//                               ? const Color(0xFFEF4444)
//                               : const Color(0xFF8B5CF6),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: Text(
//                           isMember ? "Leave Society" : "Join Society",
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),

//                   if (!widget.isAdmin) const SizedBox(height: 24),

//                   // Upcoming Events Section
//                   const Text(
//                     "Upcoming Events",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1F2937)),
//                   ),
//                   const SizedBox(height: 16),

//                   events.isEmpty
//                       ? Container(
//                           padding: const EdgeInsets.all(48),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF3F4F6),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Column(
//                             children: [
//                               const Icon(Icons.event_busy, size: 64, color: Color(0xFF9CA3AF)),
//                               const SizedBox(height: 16),
//                               Text(
//                                 widget.isAdmin
//                                     ? "No upcoming events.\nTap the calendar icon to create one!"
//                                     : "No upcoming events yet",
//                                 style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         )
//                       : SizedBox(
//                           height: 380,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: events.length,
//                             itemBuilder: (context, index) {
//                               final event = events[index];
//                               final startTime =
//                                   DateTime.parse(event["start_time"]).toLocal();
//                               final isAttending = attendingStatus[event["id"]] ?? false;
//                               final isPast = startTime.isBefore(DateTime.now());

//                               return GestureDetector(
//                                 onTap: widget.isAdmin
//                                     ? null
//                                     : () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => const MyEventsPage(),
//                                           ),
//                                         );
//                                       },
//                                 child: Container(
//                                   width: 300,
//                                   margin: const EdgeInsets.only(right: 16),
//                                   child: Card(
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           width: double.infinity,
//                                           padding: const EdgeInsets.all(16),
//                                           decoration: const BoxDecoration(
//                                             gradient: LinearGradient(
//                                               colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
//                                               begin: Alignment.topLeft,
//                                               end: Alignment.bottomRight,
//                                             ),
//                                             borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(16),
//                                               topRight: Radius.circular(16),
//                                             ),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 event["title"],
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Row(
//                                                 children: [
//                                                   const Icon(Icons.calendar_today,
//                                                       size: 14, color: Colors.white70),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     "${startTime.day}/${startTime.month}/${startTime.year}",
//                                                     style: const TextStyle(
//                                                         color: Colors.white70, fontSize: 13),
//                                                   ),
//                                                   const SizedBox(width: 16),
//                                                   const Icon(Icons.access_time,
//                                                       size: 14, color: Colors.white70),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
//                                                     style: const TextStyle(
//                                                         color: Colors.white70, fontSize: 13),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.all(16),
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 event["description"] ?? "No description",
//                                                 style: const TextStyle(
//                                                     fontSize: 14, color: Color(0xFF4B5563)),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               const SizedBox(height: 12),
//                                               Row(
//                                                 children: [
//                                                   const Icon(Icons.location_on,
//                                                       size: 16, color: Color(0xFF9CA3AF)),
//                                                   const SizedBox(width: 6),
//                                                   Expanded(
//                                                     child: Text(
//                                                       event["location"] ?? "No location",
//                                                       style: const TextStyle(
//                                                           fontSize: 13, color: Color(0xFF6B7280)),
//                                                       maxLines: 1,
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               if (event["capacity_limit"] != null) ...[
//                                                 const SizedBox(height: 8),
//                                                 Row(
//                                                   children: [
//                                                     const Icon(Icons.people,
//                                                         size: 16, color: Color(0xFF9CA3AF)),
//                                                     const SizedBox(width: 6),
//                                                     Text(
//                                                       "Capacity: ${event["capacity_limit"]}",
//                                                       style: const TextStyle(
//                                                           fontSize: 13, color: Color(0xFF6B7280)),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
                                              
//                                               const SizedBox(height: 16),
                                              
//                                               // Attend/Leave button (only for regular users, not admin)
//                                               if (!widget.isAdmin && !isPast)
//                                                 SizedBox(
//                                                   width: double.infinity,
//                                                   child: ElevatedButton(
//                                                     onPressed: () => toggleEventAttendance(event["id"]),
//                                                     style: ElevatedButton.styleFrom(
//                                                       backgroundColor: isAttending
//                                                           ? const Color(0xFFEF4444)
//                                                           : const Color(0xFF10B981),
//                                                       padding: const EdgeInsets.symmetric(vertical: 10),
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius: BorderRadius.circular(8),
//                                                       ),
//                                                     ),
//                                                     child: Row(
//                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                       children: [
//                                                         Icon(
//                                                           isAttending ? Icons.close : Icons.check_circle,
//                                                           color: Colors.white,
//                                                           size: 18,
//                                                         ),
//                                                         const SizedBox(width: 8),
//                                                         Text(
//                                                           isAttending ? "Leave Event" : "Attend Event",
//                                                           style: const TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 14,
//                                                             fontWeight: FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               if (!widget.isAdmin && isPast)
//                                                 Container(
//                                                   width: double.infinity,
//                                                   padding: const EdgeInsets.symmetric(vertical: 10),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.grey.shade200,
//                                                     borderRadius: BorderRadius.circular(8),
//                                                   ),
//                                                   child: const Center(
//                                                     child: Text(
//                                                       "Event Passed",
//                                                       style: TextStyle(
//                                                         color: Colors.grey,
//                                                         fontSize: 14,
//                                                         fontWeight: FontWeight.w600,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),

//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//       bottomNavigationBar:
//           widget.isAdmin ? const AdminBottomNav(currentIndex: 0) : null,
//     );
//   }
// }

























import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';
import 'package:unisoc/screens/admin/admin_events_page.dart';
import 'package:unisoc/screens/my_events_page.dart';

class SocietyProfilePage extends StatefulWidget {
  final int societyId;
  final bool isAdmin;
  final bool isOwnSociety;  // Kept for compatibility but not used for edit button

  const SocietyProfilePage({
    super.key,
    required this.societyId,
    required this.isAdmin,
    this.isOwnSociety = false,  // Default to false
  });

  @override
  State<SocietyProfilePage> createState() => _SocietyProfilePageState();
}

class _SocietyProfilePageState extends State<SocietyProfilePage> {
  Map societyData = {};
  List events = [];
  bool isLoading = true;
  bool isEditing = false;
  bool isMember = false;
  Timer? pollingTimer;
  final TextEditingController descController = TextEditingController();
  
  // Track attending status for each event
  Map<int, bool> attendingStatus = {};

  @override
  void initState() {
    super.initState();
    loadData();
    if (!widget.isAdmin) startPolling();
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    descController.dispose();
    super.dispose();
  }

  void startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadEvents();
    });
  }

  Future<void> loadData() async {
    await Future.wait([
      loadSociety(),
      loadEvents(),
      if (!widget.isAdmin) checkMembership(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> loadSociety() async {
    final endpoint = widget.isAdmin
        ? "${ApiService.baseUrl}/societies/${widget.societyId}/admin/"
        : "${ApiService.baseUrl}/societies/${widget.societyId}/";

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          societyData = data;
          descController.text = data["description"] ?? "";
        });
      }
    } catch (e) {
      print("Error loading society: $e");
    }
  }

  Future<void> loadEvents() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        final upcoming = data
            .where((e) => DateTime.parse(e["start_time"]).isAfter(now))
            .toList();
        upcoming.sort((a, b) =>
            DateTime.parse(a["start_time"]).compareTo(DateTime.parse(b["start_time"])));
        setState(() => events = upcoming);
        
        // Check attendance status for each event (regular users only)
        if (!widget.isAdmin) {
          for (var event in events) {
            await checkEventAttendance(event["id"]);
          }
        }
        print("Loaded ${events.length} events");
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  Future<void> checkEventAttendance(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/events/$eventId/attending/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          attendingStatus[eventId] = data["is_attending"] ?? false;
        });
      }
    } catch (e) {
      print("Error checking attendance for event $eventId: $e");
    }
  }

  Future<void> toggleEventAttendance(int eventId) async {
    final isAttending = attendingStatus[eventId] ?? false;
    final endpoint = isAttending
        ? "/events/$eventId/leave/"
        : "/events/$eventId/join/";

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}$endpoint"),
        headers: ApiService.headers,
      );
      
      if (response.statusCode == 200) {
        setState(() {
          attendingStatus[eventId] = !isAttending;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAttending ? "Left event" : "You're attending! ✓",
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["error"] ?? "Failed to update attendance"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error toggling attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating attendance"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveDescription() async {
    try {
      if (descController.text != societyData["description"]) {
        final response = await http.patch(
          Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/admin/"),
          headers: ApiService.headers,
          body: jsonEncode({"description": descController.text}),
        );
        if (response.statusCode == 200) {
          setState(() {
            isEditing = false;
            societyData["description"] = descController.text;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Description saved ✓")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save: ${response.statusCode}")),
          );
        }
      } else {
        setState(() => isEditing = false);
      }
    } catch (e) {
      print("Error saving description: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving description")),
      );
    }
  }

  Future<void> checkMembership() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/check-membership/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isMember = data["is_member"] ?? false);
      }
    } catch (e) {
      print("Error checking membership: $e");
    }
  }

  Future<void> toggleJoinSociety() async {
    final endpoint = isMember
        ? "/society/${widget.societyId}/leave/"
        : "/society/${widget.societyId}/join/";

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}$endpoint"),
        headers: ApiService.headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await checkMembership();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Success")),
        );
      }
    } catch (e) {
      print("Error toggling membership: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper to check if this is the admin's own society
    final bool isOwnSocietyDirect = widget.isAdmin && widget.societyId == ApiService.societyId;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          societyData["name"] ?? "Society",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        // ✅ FIXED: Calendar icon only for admin's OWN society using direct comparison
        actions: isOwnSocietyDirect
            ? [
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminEventsPage(societyId: widget.societyId),
                      ),
                    );
                  },
                  tooltip: "Manage Events",
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        societyData["image_url"] != null &&
                                societyData["image_url"].toString().isNotEmpty
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    NetworkImage(societyData["image_url"]),
                                backgroundColor: Colors.grey[200],
                              )
                            : Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.business, size: 60, color: Colors.white),
                                ),
                              ),
                        const SizedBox(height: 12),
                        if (societyData["category"] != null &&
                            societyData["category"].toString().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              societyData["category"],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8B5CF6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ FIXED: About Section WITH EDIT BUTTON - using direct comparison
                  Row(
                    children: [
                      const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (isOwnSocietyDirect) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            isEditing ? Icons.save : Icons.edit,
                            color: const Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          onPressed: () {
                            if (isEditing) {
                              saveDescription();
                            } else {
                              setState(() => isEditing = true);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ✅ FIXED: TextField condition using direct comparison
                  isEditing && isOwnSocietyDirect
                      ? TextField(
                          controller: descController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                            ),
                            hintText: "Write a description for your society...",
                            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            societyData["description"]?.isNotEmpty == true
                                ? societyData["description"]
                                : isOwnSocietyDirect  // ✅ FIXED: using direct comparison
                                    ? "No description yet — tap edit to add one."
                                    : "No description yet.",
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFF374151), height: 1.6),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // Join/Leave Society button (only for regular users, not admins)
                  if (!widget.isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: toggleJoinSociety,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMember
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isMember ? "Leave Society" : "Join Society",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  if (!widget.isAdmin) const SizedBox(height: 24),

                  // Upcoming Events Section
                  const Text(
                    "Upcoming Events",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),

                  events.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.event_busy, size: 64, color: Color(0xFF9CA3AF)),
                              const SizedBox(height: 16),
                              Text(
                                widget.isAdmin
                                    ? "No upcoming events.\nTap the calendar icon to create one!"
                                    : "No upcoming events yet",
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 380,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final startTime =
                                  DateTime.parse(event["start_time"]).toLocal();
                              final isAttending = attendingStatus[event["id"]] ?? false;
                              final isPast = startTime.isBefore(DateTime.now());

                              return GestureDetector(
                                onTap: widget.isAdmin
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const MyEventsPage(),
                                          ),
                                        );
                                      },
                                child: Container(
                                  width: 300,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event["title"],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today,
                                                      size: 14, color: Colors.white70),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    "${startTime.day}/${startTime.month}/${startTime.year}",
                                                    style: const TextStyle(
                                                        color: Colors.white70, fontSize: 13),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  const Icon(Icons.access_time,
                                                      size: 14, color: Colors.white70),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
                                                    style: const TextStyle(
                                                        color: Colors.white70, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event["description"] ?? "No description",
                                                style: const TextStyle(
                                                    fontSize: 14, color: Color(0xFF4B5563)),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      size: 16, color: Color(0xFF9CA3AF)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event["location"] ?? "No location",
                                                      style: const TextStyle(
                                                          fontSize: 13, color: Color(0xFF6B7280)),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (event["capacity_limit"] != null) ...[
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.people,
                                                        size: 16, color: Color(0xFF9CA3AF)),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "Capacity: ${event["capacity_limit"]}",
                                                      style: const TextStyle(
                                                          fontSize: 13, color: Color(0xFF6B7280)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              
                                              const SizedBox(height: 16),
                                              
                                              // Attend/Leave button (only for regular users, not admin)
                                              if (!widget.isAdmin && !isPast)
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () => toggleEventAttendance(event["id"]),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isAttending
                                                          ? const Color(0xFFEF4444)
                                                          : const Color(0xFF10B981),
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          isAttending ? Icons.close : Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          isAttending ? "Leave Event" : "Attend Event",
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (!widget.isAdmin && isPast)
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Event Passed",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar:
          widget.isAdmin ? const AdminBottomNav(currentIndex: 0) : null,
    );
  }
}













