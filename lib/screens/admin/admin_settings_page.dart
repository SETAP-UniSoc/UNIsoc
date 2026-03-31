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
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  String _userName = "";
  String _userEmail = "";
  String _errorMessage = "";
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationSettings();
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
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/user/profile/"),
        headers: ApiService.headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String nameValue = "Admin";
        String emailValue = "";
        
        if (data["name"] != null && data["name"].toString().isNotEmpty) {
          nameValue = data["name"].toString();
        } else if (data["first_name"] != null && data["first_name"].toString().isNotEmpty) {
          nameValue = data["first_name"].toString();
        }
        
        if (data["email"] != null && data["email"].toString().isNotEmpty) {
          emailValue = data["email"].toString();
        }
        
        setState(() {
          _userName = nameValue;
          _userEmail = emailValue;
          _nameController.text = _userName;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load profile: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error: Unable to load profile";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadNotificationSettings() async {
  try {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/notifications/"),
      headers: ApiService.headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("📊 Notification data: $data");
      
      if (data.isNotEmpty) {
        setState(() {
          // Use the correct field name from backend
          _notificationsEnabled = data[0]["notify_new_events"] ?? true;
        });
      }
    }
  } catch (e) {
    print("Error loading notification settings: ${e.toString()}");
  }
}

Future<void> _updateNotificationSettings(bool enabled) async {
  setState(() => _isLoading = true);
  
  try {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/notifications/"),
      headers: ApiService.headers,
      body: jsonEncode({
        "society_id": ApiService.societyId,  // Use dynamic society ID, not hardcoded 1
        "event_notifications": enabled,      // Your backend expects this field name
      }),
    );
    
    print("📊 Update notification response: ${response.statusCode}");
    print("📊 Response body: ${response.body}");
    
    if (response.statusCode == 200) {
      setState(() {
        _notificationsEnabled = enabled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? "Notifications enabled" : "Notifications disabled"
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update notification settings")),
      );
    }
  } catch (e) {
    print("❌ Error updating notification: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error updating notification settings")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
  
  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/user/profile/"),
        headers: ApiService.headers,
        body: jsonEncode({"name": newName}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String updatedName = newName;
        if (data["name"] != null && data["name"].toString().isNotEmpty) {
          updatedName = data["name"].toString();
        } else if (data["first_name"] != null && data["first_name"].toString().isNotEmpty) {
          updatedName = data["first_name"].toString();
        }
        
        setState(() {
          _userName = updatedName;
          _isEditingName = false;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating name")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateEmail() async {
    final currentEmail = _currentEmailController.text.trim();
    final newEmail = _newEmailController.text.trim();
    
    if (currentEmail.isEmpty || newEmail.isEmpty) {
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
          "current_email": currentEmail,
          "new_email": newEmail,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String updatedEmail = newEmail;
        if (data["email"] != null && data["email"].toString().isNotEmpty) {
          updatedEmail = data["email"].toString();
        }
        
        setState(() {
          _userEmail = updatedEmail;
          _currentEmailController.clear();
          _newEmailController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email updated successfully")),
        );
      } else {
        String errorMessage = "Failed to update email";
        try {
          final error = jsonDecode(response.body);
          if (error["error"] != null) {
            errorMessage = error["error"].toString();
          }
        } catch (e) {
          // Ignore parsing error
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating email")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both password fields")),
      );
      return;
    }
    
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }
    
    if (newPassword != confirmPassword) {
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
          "old_password": currentPassword,
          "new_password": newPassword,
        }),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully")),
        );
      } else {
        String errorMessage = "Failed to change password";
        try {
          final error = jsonDecode(response.body);
          if (error["error"] != null) {
            errorMessage = error["error"].toString();
          }
        } catch (e) {
          // Ignore parsing error
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
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
                  // Error message display
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
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
                                  _userName.isNotEmpty ? _userName : "No name set",
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
                    obscureText: _obscureCurrentPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter current password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
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
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter new password (min. 8 characters)",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password
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
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Confirm new password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Enable Notifications",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Receive updates about your society and events",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          activeColor: const Color(0xFF8B5CF6),
                          onChanged: (value) {
                            _updateNotificationSettings(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}