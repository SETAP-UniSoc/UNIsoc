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

  List<String> labels = [];
  List<double> values = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTrend(1, selectedPeriod); // Default society ID is 1
  }

Future<void> fetchTrend(int societyId, String period) async {
  setState(() {
    isLoading = true;
  });

  final url = Uri.parse(
    "http://10.128.5.47:8000/api/analytics/society/$societyId/?period=$period",
  );

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "67a80ebb9c0f939fe04164f66ed5165f65d3e66", // Add your token here
        // Add your token here
        // "Authorization": "Token YOUR_TOKEN",
      },
    );

    if (response.statusCode != 200) {
      print("Server error: ${response.statusCode}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error ${response.statusCode}")),
      );
    } else {
      final data = jsonDecode(response.body);

      setState(() {
        labels = List<String>.from(data["labels"] ?? []);
        values = List<dynamic>.from(data["totals"] ?? [])
            .map((e) => (e as num).toDouble())
            .toList();
      });
    }
  } catch (e) {
    print("Error fetching trend: $e");
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
        title: const Text("My Analytics"),
        centerTitle: true,
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
                : values.isEmpty
                    ? const Center(child: Text("No data available"))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: List.generate(
                              values.length,
                              (index) => FlSpot(index.toDouble(), values[index]),
                            ),
                            barWidth: 4,
                            color: Colors.purple,
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
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
        fetchTrend(1, value); // Fetch new data for the selected period
      },
      child: Text(label),
    );
  }
}