//admin analytcs temporary page for now but will change it to admin analytics page later
import 'package:flutter/material.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

//add title to the page called My anlytics 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Analytics"),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("Yes"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Maybe"),
          ),
        ],
      ),
    );
  }
}

