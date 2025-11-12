import 'dart:convert';
import 'dart:io';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:ui';
import 'lecture_BrowseList.dart';
import 'lecturer-CheckRequestPage.dart';
import 'lecturer-history.dart';
import 'main.dart'; // to access WelcomeScreen

// ✅ 1. UPDATED THE MODEL (removed totalCount)
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

class LectureDashboard extends StatefulWidget {
  final int userId;
  final String? username;

  const LectureDashboard({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<LectureDashboard> createState() => _LectureDashboardState();
}

class _LectureDashboardState extends State<LectureDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      LecturerHomePage(username: widget.username, userId: widget.userId),
      const LectureBrowseList(),
      CheckRequestPage(userId: widget.userId), 
      HistoryPage(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Browse List"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Check Request"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}

// This is the main "Home" tab of the lecturer dashboard
class LecturerHomePage extends StatefulWidget {
  final String? username;
  final int userId;
  const LecturerHomePage({super.key, this.username, required this.userId});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000'; // For iOS Simulator
  }

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // This function is unchanged, it still calls the same route
  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/dashboard/stats');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));

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
        setState(() => _error = "Error connecting to server: ${e.toString()}");
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
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
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
                          "Hello, ${widget.username ?? 'Lecturer'}",
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
                        
                        // ✅✅✅ THIS IS THE FIX ✅✅✅
                        // "Total" card is removed and labels are updated.
                        
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.availableCount.toString() ?? "0"),
                          "Available Slots (Today)",
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.reservedCount.toString() ?? "0"),
                          "Reserved Slots (Today)",
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.pendingCount.toString() ?? "0"),
                          "Pending Slots (Today)",
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          _isLoading
                              ? "..."
                              : (_stats?.disabledCount.toString() ?? "0"),
                          "Disabled Slots (Total)",
                        ),
                        const SizedBox(height: 16), 

                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Center(
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 16),
                              ),
                            ),
                          )
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
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 4),
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
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}