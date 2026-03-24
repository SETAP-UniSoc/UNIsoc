import 'package:flutter/material.dart';

class Event {
  final String title;
  final String date;
  final String location;
  final Color color;

  const Event({
    required this.title,
    required this.date,
    required this.location,
    required this.color,
  });
}

const List<Event> featuredEvents = [
  Event(
    title: 'Freshers Fair',
    date: 'Mon 23 Sep',
    location: 'Main Hall',
    color: Colors.deepPurple,
  ),
  Event(
    title: 'Gaming Night',
    date: 'Wed 25 Sep',
    location: 'Student Union',
    color: Colors.indigo,
  ),
  Event(
    title: 'Open Mic',
    date: 'Fri 27 Sep',
    location: 'Campus Bar',
    color: Colors.pinkAccent,
  ),
  Event(
    title: 'Tech Talk',
    date: 'Tue 1 Oct',
    location: 'Room B201',
    color: Colors.teal,
  ),
];
