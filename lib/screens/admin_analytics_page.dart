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
    fetchTrend(selectedPeriod);
  }

  Future<void> fetchTrend(String week) async {
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
          "Authorization":
              "Token 67a80ebb9c0f939fe04164f66ed5165f65d3e66",
        },
      );

      if (response.statusCode != 200) {
        setState(() {
          labels = [];
          values = [];
          statusMessage = "Server error ${response.statusCode}";
        });
      } else {
        final data = jsonDecode(response.body);

        final rawLabels = data["labels"] ?? [];
        final rawValues = data["totals"] ?? data["data"] ?? [];

        setState(() {
          labels = List<String>.from(rawLabels);
          values = List<dynamic>.from(rawValues)
              .map((e) => (e as num).toDouble())
              .toList();
          statusMessage = values.isEmpty ? "No data available" : "";
        });
      }
    } catch (e) {
      setState(() {
        labels = [];
        values = [];
        statusMessage = "Failed to load analytics";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "My Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Trading-style period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPeriodButton("week", "1W"),
              _buildPeriodButton("month", "1M"),
              _buildPeriodButton("6months", "6M"),
              _buildPeriodButton("year", "1Y"),
            ],
          ),

          const SizedBox(height: 20),

          // Large current value display
          if (values.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                values.last.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : values.isEmpty
                    ? Center(
                        child: Text(
                          statusMessage,
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: (values.length - 1).toDouble(),
                            minY: 0,
                            maxY: values.reduce((a, b) =>
                                    a > b ? a : b) *
                                1.2,

                            gridData:
                                const FlGridData(show: false),
                            borderData:
                                FlBorderData(show: false),

                            titlesData:
                                const FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                            ),

                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                curveSmoothness: 0.2,
                                spots: List.generate(
                                  values.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    values[index],
                                  ),
                                ),
                                barWidth: 3,
                                color: Colors.purple,
                                dotData:
                                    const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin:
                                        Alignment.topCenter,
                                    end: Alignment
                                        .bottomCenter,
                                    colors: [
                                      Colors.purple
                                          .withOpacity(0.4),
                                      Colors.purple
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Trading-style text buttons
  Widget _buildPeriodButton(String value, String label) {
    final bool isSelected = selectedPeriod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = value;
        });
        fetchTrend(value);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? Colors.purple : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 30,
            color: isSelected
                ? Colors.purple
                : Colors.transparent,
          ),
        ],
      ),
    );
  }
}