import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {

  const String baseUrl = "http://10.128.4.160:8000/api/user/register/";


  //Signup successful

  test("Signup successful → 201", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "Sam",
        "last_name": "Smith",
        "up_number": "UP1234567",
        "email": "test${DateTime.now().millisecondsSinceEpoch}@gmail.com",
        "password": "Sams123*",
        "confirm_password": "Sams123*",
      }),
    );

    expect(response.statusCode == 200 || response.statusCode == 201, true);
  });

 
  // Empty fields
 
  test("Please fill in all fields → 400", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "",
        "last_name": "",
        "up_number": "",
        "email": "",
        "password": "",
        "confirm_password": "",
      }),
    );

    expect(response.statusCode, 400);
  });


  //UP number invalid

  test("UP number must be exactly 7 digits → 400", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "Sam",
        "last_name": "Smith",
        "up_number": "UP123",
        "email": "sam1@gmail.com",
        "password": "Sams123*",
        "confirm_password": "Sams123*",
      }),
    );

    expect(response.statusCode, 400);
  });

 
  // Email format

  test("Enter a valid email address → 400", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "Sam",
        "last_name": "Smith",
        "up_number": "UP1234567",
        "email": "invalidemail",
        "password": "Sams123*",
        "confirm_password": "Sams123*",
      }),
    );

    expect(response.statusCode, 400);
  });


  //Passwords do not match

  test("Passwords do not match → 400", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "Sam",
        "last_name": "Smith",
        "up_number": "UP1234567",
        "email": "sam2@gmail.com",
        "password": "Sams123*",
        "confirm_password": "Different123*",
      }),
    );

    expect(response.statusCode, 400);
  });

 
  //Password too short
 
  test("Password must be at least 8 characters → 400", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "Sam",
        "last_name": "Smith",
        "up_number": "UP1234567",
        "email": "sam3@gmail.com",
        "password": "short",
        "confirm_password": "short",
      }),
    );

    expect(response.statusCode, 400);
  });

  
  //Network error

  test("Network error", () async {
    try {
      await http.post(Uri.parse("http://invalid-url"));
    } catch (e) {
      expect(e.toString().contains("Exception"), true);
    }
  });


  //Server error

  test("Signup failed (500)", () async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": "Error",
        "last_name": "Test",
        "up_number": "UP1234567",
        "email": "error@test.com",
        "password": "Sams123*",
        "confirm_password": "Sams123*",
      }),
    );

    expect(response.statusCode, anyOf(400, 500));
  });

}