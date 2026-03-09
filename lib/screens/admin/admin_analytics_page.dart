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
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  String selectedPeriod = "year";
  List<String> labels = [];
  List<double> values = [];
  List<double> eventValues = [];
  int liveCount = 0;
  bool isLoading = false;
  Timer? liveTimer;

  @override
  void initState() {
    super.initState();
    fetchTrend(selectedPeriod);
    fetchLiveCount();
    fetchEventAttendance();
    startLiveUpdates();
  }

  @override
  void dispose() {
    liveTimer?.cancel();
    super.dispose();
  }

  void startLiveUpdates() {
    // live member count refreshes every 5 seconds
    liveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchAnalytics(selectedPeriod);
    });
  }

  // single endpoint for all analytics — uses logged in admin's token automatically
  Future<void> fetchAnalytics(String period) async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/my-analytics/?period=$period"),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          labels = List<String>.from(data["labels"] ?? []);
          values = List<dynamic>.from(data["totals"] ?? [])
              .map((e) => (e as num).toDouble())
              .toList();
        });
      }
    } catch (e) {
      print("Analytics error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // export analytics as PDF
  Future<void> exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Society Analytics",
                style: pw.TextStyle(fontSize: 22)),
            pw.SizedBox(height: 10),
            pw.Text("Live Members: $liveCount"),
            pw.SizedBox(height: 20),
            pw.Text("Membership Trend:"),
            ...List.generate(
              labels.length,
              (i) => pw.Text("${labels[i]}: ${values[i]}"),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
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

            // period selector
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

            // current member count
            if (values.isNotEmpty)
              Text(
                values.last.toStringAsFixed(0),
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            // membership trend graph
            SizedBox(
              height: 250,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildChart(values),
            ),

            const SizedBox(height: 20),

            // live member count
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

            // event attendance graph — shows "No data" until events have attendance
            const Text(
              "Event Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: _buildChart(eventValues),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: data.reduce((a, b) => a > b ? a : b) * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
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
                    Colors.purple
                        .withOpacity(0.4),
                    Colors.purple
                        .withOpacity(0.05),
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