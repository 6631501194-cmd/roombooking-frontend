import 'package:flutter/material.dart';
import 'login-signin.dart'; // imports LoginPage for navigation

class LoginSignup extends StatefulWidget {
  const LoginSignup({super.key});

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String text, {Color bg = Colors.red}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: bg, duration: const Duration(seconds: 2)),
    );
  }

  bool _validateInputs() {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (username.isEmpty) {
      _showMessage('Please enter a username.');
      return false;
    }
    if (email.isEmpty) {
      _showMessage('Please enter an email.');
      return false;
    }
    // very simple email check
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid email address.');
      return false;
    }
    if (password.isEmpty) {
      _showMessage('Please enter a password.');
      return false;
    }
    if (confirm.isEmpty) {
      _showMessage('Please confirm your password.');
      return false;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match.');
      return false;
    }
    return true;
  }

  Future<void> _onCreateAccountPressed() async {
    if (!_validateInputs()) return;

    // Show success dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFE6F0FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 14),
                const Text(
                  'Registration completed!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account has been created successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    // navigate to login page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D1F5E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: const Text('Go to Login', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Optionally clear form fields
    _usernameCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _confirmCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final topImageHeight = 260.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // background form container
          Positioned.fill(
            top: topImageHeight - 30,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFB9D6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create\nAccount',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1F5E),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Go back to previous screen (Welcome)
                            Navigator.pop(context);
                          },
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
                    const SizedBox(height: 30),

                    // Username
                    _buildTextFieldController('Username', controller: _usernameCtrl),
                    const SizedBox(height: 10),

                    // Email
                    _buildTextFieldController('Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),

                    // Password
                    _buildTextFieldController(
                      'Password',
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Confirm Password
                    _buildTextFieldController(
                      'Confirm Password',
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _onCreateAccountPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D1F5E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),

                    // Login Text
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: 'Login !!!',
                                style: TextStyle(
                                  color: Color(0xFF1D1F5E),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // top image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
              child: Image.asset(
                'assets/images/second1.jpg',
                width: double.infinity,
                height: topImageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return Container(
                    height: topImageHeight,
                    color: Colors.grey.shade200,
                  );
                },
              ),
            ),
          ),

          // SafeArea spacer (top)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldController(
    String hint, {
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}