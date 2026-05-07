import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

class AdminAnalyticsPage extends StatefulWidget {
  final http.Client? httpClient;
  const AdminAnalyticsPage({super.key, this.httpClient});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  String selectedPeriod = "year";
  List<String> labels = [];
  List<double> values = [];
  List<double> eventValues = [];
  List<String> eventNames = [];
  int liveCount = 0;
  bool isLoading = false;
  Timer? liveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAnalytics(selectedPeriod);
    });
    
    startLiveUpdates();
  }

  @override
  void dispose() {
    liveTimer?.cancel();
    super.dispose();
  }

  void startLiveUpdates() {
    liveTimer = Timer.periodic(const Duration(seconds: 50), (_) {
      fetchAnalytics(selectedPeriod);
    });
  }

  Future<void> fetchAnalytics(String period) async {
    setState(() => isLoading = true);

    try {
      final client = widget.httpClient ?? http.Client();

final response = await client.get(
  Uri.parse("${ApiService.baseUrl}/my-analytics/?period=$period"),
  headers: ApiService.headers,
);

      print("📡 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          labels = List<String>.from(data["labels"] ?? []);
          values = List<dynamic>.from(data["totals"] ?? [])
              .map((e) => (e as num).toDouble())
              .toList();
          liveCount = data["live_count"] ?? 0;

          final eventsStats = data["events_stats"] ?? [];
          
          eventValues = eventsStats.map<double>((e) => (e["attendee_count"] as num).toDouble()).toList();
          eventNames = eventsStats.map<String>((e) => e["title"].toString()).toList();
          
          print("✅ eventValues (${eventValues.length}): $eventValues");
          print("✅ eventNames (${eventNames.length}): $eventNames");
          
          if (values.isNotEmpty) {
            values[values.length - 1] = liveCount.toDouble();
          }
        });
      }
    } catch (e) {
      print("❌ Analytics error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> exportPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Society Analytics", style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 10),
              pw.Text("Live Members: $liveCount"),
              pw.SizedBox(height: 20),
              pw.Text("Membership Trend:"),
              ...List.generate(
                labels.length,
                (i) => pw.Text("${labels[i]}: ${values[i]}"),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Event Attendance:"),
              ...List.generate(
                eventNames.length,
                (i) => pw.Text("${eventNames[i]}: ${eventValues[i].toInt()} attendees"),
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
      
      print("✅ PDF exported successfully");
    } catch (e) {
      print("❌ PDF export error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF export failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "My Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton("week", "1W"),
                _buildPeriodButton("month", "1M"),
                _buildPeriodButton("6months", "6M"),
                _buildPeriodButton("year", "1Y"),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              values.isNotEmpty
                  ? values.last.toStringAsFixed(0)
                  : liveCount.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 250,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildChart(values),
            ),

            const SizedBox(height: 20),

            Text(
              "Live Members: $liveCount",
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: exportPdf,
              child: const Text("Export as PDF"),
            ),

            const SizedBox(height: 40),

            const Text(
              "Event Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Number of attendees per event",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 300,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEventList(eventValues, eventNames),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _buildChart(List<double> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No data yet"));
    }

    double maxY = data.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.4),
                    Colors.purple.withOpacity(0.05),
                  ],
                ),
              ),
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<double> data, List<String> names) {
    if (data.isEmpty || names.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text("No event attendance data yet", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text("When users attend events, their attendance will appear here",
                 style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final maxBarHeight = 150.0;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final attendeeCount = data[index].toInt();
          final barHeight = maxValue > 0 
              ? (attendeeCount / maxValue) * maxBarHeight 
              : 10.0;
          
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$attendeeCount",
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: barHeight.clamp(10.0, maxBarHeight),
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  names[index],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodButton(String value, String label) {
    final bool isSelected = selectedPeriod == value;

    return GestureDetector(
      onTap: () {
        setState(() => selectedPeriod = value);
        fetchAnalytics(value);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.purple : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 30,
            color: isSelected ? Colors.purple : Colors.transparent,
          ),
        ],
      ),
    );
  }
}