import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unisoc/services/api_services.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isEditingName = false;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  
  String _userName = "";
  String _userEmail = "";
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/user/profile/"),
        headers: ApiService.headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data["name"] ?? "Admin";
          _userEmail = data["email"] ?? "";
          _nameController.text = _userName;
        });
      } else {
        // Fallback to stored data
        setState(() {
          _userName = ApiService.societyName ?? "Admin";
          _nameController.text = _userName;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _userName = ApiService.societyName ?? "Admin";
        _nameController.text = _userName;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.patch(
        Uri.parse("${ApiService.baseUrl}/user/profile/"),
        headers: ApiService.headers,
        body: jsonEncode({"name": _nameController.text.trim()}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data["name"];
          _isEditingName = false;
          ApiService.societyName = _userName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Name updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update name: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error updating name: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating name")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateEmail() async {
    if (_currentEmailController.text.trim().isEmpty || 
        _newEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both email fields")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/change-email/"),
        headers: ApiService.headers,
        body: jsonEncode({
          "current_email": _currentEmailController.text.trim(),
          "new_email": _newEmailController.text.trim(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userEmail = data["email"];
          _currentEmailController.clear();
          _newEmailController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email updated successfully")),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error["error"] ?? "Failed to update email")),
        );
      }
    } catch (e) {
      print("Error updating email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating email")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both password fields")),
      );
      return;
    }
    
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords don't match")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/change-password/"),
        headers: ApiService.headers,
        body: jsonEncode({
          "old_password": _currentPasswordController.text,
          "new_password": _newPasswordController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully ✅")),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error["error"] ?? "Failed to change password")),
        );
      }
    } catch (e) {
      print("Error changing password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error changing password")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "My Account",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Details Section
                  const Text(
                    "My Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Name Field
                  const Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _isEditingName
                            ? TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _userName,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isEditingName ? Icons.save : Icons.edit,
                          color: const Color(0xFF8B5CF6),
                        ),
                        onPressed: () {
                          if (_isEditingName) {
                            _updateName();
                          } else {
                            setState(() => _isEditingName = true);
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Field (Read-only)
                  const Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Text(
                      _userEmail.isNotEmpty ? _userEmail : "No email set",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Change Email Section
                  const Text(
                    "Change Email",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Current Email
                  const Text(
                    "Current Email",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentEmailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter current email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // New Email
                  const Text(
                    "New Email",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newEmailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter new email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Update Email",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Change Password Section
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Current Password
                  const Text(
                    "Current Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter current password",
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // New Password
                  const Text(
                    "New Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter new password (min. 8 characters)",
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm New Password
                  const Text(
                    "Confirm New Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Confirm new password",
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Notifications Section
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Enable Notifications",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text(
                        "Receive updates about your society and events",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _notificationsEnabled,
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Coming soon!")),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}