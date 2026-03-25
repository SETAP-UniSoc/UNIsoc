import 'package:flutter/material.dart';

class UserProfileState {
  static final ValueNotifier<String> firstName = ValueNotifier<String>('');

  static void setFirstName(String value) {
    firstName.value = value;
  }
}