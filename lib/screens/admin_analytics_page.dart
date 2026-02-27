// admin analytics temporary page for now
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  String selectedPeriod = "year";
  String statusMessage = "Loading analytics...";

  List<String> labels = [];
  List<double> values = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTrend(selectedPeriod); // Default period is "year"
  }

Future<void> fetchTrend( String week) async {
  setState(() {
    isLoading = true;
    statusMessage = "Loading analytics...";
  });

  final url = Uri.parse(
    "http://10.128.5.47:8000/api/my-analytics/society/?period=$week",
  );

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token 67a80ebb9c0f939fe04164f66ed5165f65d3e66", // Add your token here
        // Add your token here
        // "Authorization": "Token YOUR_TOKEN",
      },
    );

    if (response.statusCode != 200) {
      print("Server error: ${response.statusCode}");
      if (!mounted) return;
      setState(() {
        labels = [];
        values = [];
        statusMessage = "Server error ${response.statusCode}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error ${response.statusCode}")),
      );
    } else {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final dynamic rawLabels = data["labels"] ?? [];
        final dynamic rawValues = data["totals"] ?? data["data"] ?? [];

        setState(() {
          labels = List<String>.from(rawLabels);
          values = List<dynamic>.from(rawValues)
              .map((e) => (e as num).toDouble())
              .toList();
          statusMessage = values.isEmpty ? "No data available" : "";
        });
      } else {
        setState(() {
          labels = [];
          values = [];
          statusMessage = "Invalid server response";
        });
      }
    }
  } catch (e) {
    print("Error fetching trend: $e");
    if (!mounted) return;
    setState(() {
      labels = [];
      values = [];
      statusMessage = "Failed to load analytics";
    });
  } finally {
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("My Analytics"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPeriodButton("year", "1 Year"),
              _buildPeriodButton("6months", "6 Months"),
              _buildPeriodButton("month", "1 Month"),
              _buildPeriodButton("week", "1 Week"),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: labels.isNotEmpty ? (labels.length - 1).toDouble() : 3,
                            minY: 0,
                            maxY: values.isNotEmpty
                                ? values.reduce((a, b) => a > b ? a : b) + 1
                                : 10,
                            borderData: FlBorderData(show: true),
                            gridData: const FlGridData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: values.isNotEmpty
                                    ? List.generate(
                                        values.length,
                                        (index) => FlSpot(index.toDouble(), values[index]),
                                      )
                                    : const [
                                        FlSpot(0, 0),
                                        FlSpot(1, 0),
                                        FlSpot(2, 0),
                                        FlSpot(3, 0),
                                      ],
                                barWidth: 4,
                                color: values.isNotEmpty ? Colors.purple : Colors.grey,
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < labels.length) {
                                      return Text(labels[index]);
                                    }
                                    return const Text("");
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (values.isEmpty)
                          Center(
                            child: Text(
                              statusMessage,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildPeriodButton(String value, String label) {
    final bool isSelected = selectedPeriod == value;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.purple : Colors.grey.shade300,
        foregroundColor:
            isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          selectedPeriod = value;
        });
        fetchTrend(selectedPeriod); // Fetch new data for the selected period
      },
      child: Text(label),
    );
  }
}