import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login-signin.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({super.key});

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  // Change this to match your backend address for the platform you're running on:
  // - Android emulator (AVD): 'http://10.0.2.2:3000'
  // - iOS simulator / desktop: 'http://localhost:3000'
  // - Physical device: 'http://192.168.x.y:3000'
  static const String backendBase = 'http://localhost:3000';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Keep default role as 'student' (sent to backend) but do not expose role selector here.
  String _role = 'student';
  // Confirm password field controller
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color background = Colors.red}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onCreateAccountPressed() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      _showMessage('Please complete all fields.');
      return;
    }

    // ✅ FIXED: ADDED EMAIL VALIDATION CHECK
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
    if (!emailRegex.hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    // ✅ END OF FIX

    if (password != confirm) {
      _showMessage('Password and confirm password do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$backendBase/api/register');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'username': username,
              'password': password,
              'role': _role,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // success: show a confirmation dialog and go back to login
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Registration successful'),
              content: const Text(
                'Your account has been created. Please login.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        final msg = resp.body.isNotEmpty
            ? resp.body
            : 'Registration failed: ${resp.statusCode}';
        _showMessage(msg);
      }
    } catch (e) {
      _showMessage('Registration failed: $e');
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
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.72,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFB9D6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF1D1F5E),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1D1F5E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create a new account',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Confirm password field (keeps UI simple — role remains default 'student')
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onCreateAccountPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D1F5E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}