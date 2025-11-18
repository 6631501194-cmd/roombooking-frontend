import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart'; // Ensure this imports your WelcomeScreen

// 1. Model for the API stats
class DashboardStats {
  final int availableCount;
  final int disabledCount;
  final int pendingCount;
  final int reservedCount;

  DashboardStats({
    this.availableCount = 0,
    this.disabledCount = 0,
    this.pendingCount = 0,
    this.reservedCount = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      availableCount: json['availableCount'] ?? 0,
      disabledCount: json['disabledCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      reservedCount: json['reservedCount'] ?? 0,
    );
  }
}

class StaffDashboard extends StatefulWidget {
  final String? username;

  const StaffDashboard({super.key, this.username});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  // 2. State Variables
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;
  final _storage = const FlutterSecureStorage();

  // 3. Base URL Helper
  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // 4. Fetch Data from API
  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      // Reusing the existing dashboard stats API
      final uri = Uri.parse('$_baseUrl/api/dashboard/stats');
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (mounted) {
          setState(() {
            _stats = DashboardStats.fromJson(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _error = "Failed to load stats: ${resp.body}");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Error: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: const Color(0xFFDCE6F7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF3A7AFE), width: 3),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Are you sure to Logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Clear token on logout
                        await _storage.delete(key: 'jwt_token');
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WelcomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 28),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${widget.username ?? 'Staff'}",
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 4),
                                blurRadius: 6,
                                color: Color.fromARGB(40, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          "Welcome to Room Reservation",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9D6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Color.fromARGB(255, 4, 57, 147),
                          ),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Logout",
                        style: TextStyle(
                          color: Color.fromARGB(255, 21, 97, 228),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFB9D6FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 4),
                                    blurRadius: 6,
                                    color: Color.fromARGB(40, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.calendar_month,
                                color: Colors.black, size: 30),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // 5. Display API Data
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.availableCount.toString() ?? "0"),
                          "Available Slots",
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.reservedCount.toString() ?? "0"),
                          "Reserved Slots",
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.pendingCount.toString() ?? "0"),
                          "Pending Slots",
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.disabledCount.toString() ?? "0"),
                          "Disabled Slots",
                        ),
                        
                        const SizedBox(height: 20),

                        // Error Message display
                        if (_error != null)
                          Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}