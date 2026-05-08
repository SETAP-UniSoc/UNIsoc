import 'package:flutter/material.dart';

class UserProfileState {
  static final ValueNotifier<String> firstName = ValueNotifier<String>('');

  // Stores the raw UP number entered at login
  static String upNumber = '';

  // Stores the raw password entered at login
  // NOTE: storing passwords in memory like this is only appropriate for simple debugging
  // or demo purposes. For production, do not keep plain-text passwords in memory.
  static String password = '';

  static void setFirstName(String value) {
    firstName.value = value;
  }

  static void setUpNumber(String value) {
    upNumber = value;
  }

  static void setPassword(String value) {
    password = value;
  }
}