import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = "http://10.128.4.160:8000/login/";

  group('Login API Tests', () {

//valid login
    test('Valid login returns 200', () async {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "up_number": "1234567",
          "password": "correctPass"
        }),
      );

      expect(response.statusCode, 200);
    });
//UP number not found
    test('UP number not found returns 404', () async {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "up_number": "9999999",
          "password": "password"
        }),
      );

      expect(response.statusCode, 404);
    });

    //incorrect passoword

    test('Incorrect password returns 401', () async {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "up_number": "1234567",
          "password": "wrongpass"
        }),
      );

      expect(response.statusCode, 401);
    });

    //empty fields

    test('Empty fields returns 400', () async {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "up_number": "",
          "password": ""
        }),
      );

      expect(response.statusCode, 400);
    });

  });
}