import 'dart:convert';
// We don't need 'dart:io' since we are just using localhost
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login-signup.dart';
import 'package:http/http.dart' as http;

// Use lowercase to match your file system if that's the case
import 'student_BrowseList.dart'; 
import 'lecturer_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ✅ CORRECT for iOS Simulator
  static const String backendBase = 'http://localhost:3000';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color background = Colors.red}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background, duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _tryLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$backendBase/api/login');
      final resp = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'email': email, 'password': password}))
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        // ✅ FIXED: Decode and read all user data
        final Map<String, dynamic> data = json.decode(resp.body);

        final role = data['role']?.toString();
        final int? userId = data['uid'] as int?;
        final String? username = data['username']?.toString();


        if (role == 'staff') {
          // Staff -> use named route in main.dart which shows staff navigation
          Navigator.pushReplacementNamed(context, '/staffMain');
        } else if (role == 'lecturer') {
  // ✅ PASS THE USER'S ID AND USERNAME
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => LectureDashboard(
        userId: userId ?? 0, // Pass the ID
        username: username,     // Pass the name
      ),
    ),
  );
        } else {
          // student or unknown -> student browse list
          
          // Safety check
          if (userId == null) {
            _showMessage('Login error: User ID was missing from response.');
            setState(() => _isLoading = false); // Stop loading
            return;
          }

          // ✅ FIXED: Pass the user's ID and username to the next screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentBrowseList(
                currentUserId: userId,
                username: username ?? 'User',
              ),
            ),
          );
        }
      } else if (resp.statusCode == 401) {
        _showMessage('Invalid email or password.', background: Colors.orange);
      } else {
        final msg = resp.body.isNotEmpty ? resp.body : 'Login failed: ${resp.statusCode}';
        _showMessage(msg);
      }
    } catch (e) {
      _showMessage('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/first.jpg',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(height: screenHeight * 0.38, color: Colors.grey.shade200);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.62,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFB9D6FF),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(50)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Login', style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.black)),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1D1F5E), width: 2), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF1D1F5E)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  const Text('Good to see you back!', style: TextStyle(fontSize: 20, color: Colors.black87)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _tryLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D1F5E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Next', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontSize: 20)))),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginSignup())),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                          children: [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(text: 'Register Now!', style: TextStyle(color: Color(0xFF1D1F5E), decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}