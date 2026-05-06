import 'package:flutter_test/flutter_test.dart';

void main() {


  // Empty fields
  test("Please fill in all fields", () {
    String firstName = "";
    String lastName = "";
    expect(firstName.isEmpty || lastName.isEmpty, true);
  });

  
  //UP number not 7 digits
  test("UP number must be exactly 7 digits", () {
    String up = "123456";
    expect(RegExp(r'^\d{7}$').hasMatch(up), false);
  });


  //UP number correct
 
  test("Valid UP number", () {
    String up = "1234567";
    expect(RegExp(r'^\d{7}$').hasMatch(up), true);
  });

 
  //Email format
 
  test("Enter a valid email address", () {
    String email = "samsmith.com";
    expect(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email), false);
  });

 
  //Email correct

  test("Valid email", () {
    String email = "samsmith@gmail.com";
    expect(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email), true);
  });

 
  //Passwords do not match
 
  test("Passwords do not match", () {
    String p1 = "Sams123*";
    String p2 = "Different123*";
    expect(p1 != p2, true);
  });

 
  //Password too short
  
  test("Password must be at least 8 characters", () {
    String password = "Sams12*";
    expect(password.length < 8, true);
  });

 
  //Password too long

  test("Password must not exceed 20 characters", () {
    String password = "Samsmith123456789****";
    expect(password.length > 20, true);
  });

 
  //No uppercase
  test("Password must contain one uppercase letter", () {
    String password = "sams123*";
    expect(RegExp(r'[A-Z]').hasMatch(password), false);
  });

  
  //No number
 
  test("Password must contain one number", () {
    String password = "Samsmith*";
    expect(RegExp(r'\d').hasMatch(password), false);
  });

 
  // No special character

  test("Password must contain one special character", () {
    String password = "Sams1234";
    expect(RegExp(r'[^\w\s]').hasMatch(password), false);
  });

 
  //Password correct

  test("Valid password", () {
    String password = "Sams123*";
    bool valid = password.length >= 8 &&
        password.length <= 20 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^\w\s]').hasMatch(password);

    expect(valid, true);
  });

}