import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 1. IMPORT

class PendingBooking {
  final int bookingId;
  final String roomName;
  final String roomType;
  final String time;
  final String status;
  final String imageUrl;

  PendingBooking({
    required this.bookingId,
    required this.roomName,
    required this.roomType,
    required this.time,
    required this.status,
    required this.imageUrl,
  });

  factory PendingBooking.fromJson(Map<String, dynamic> json) {
    return PendingBooking(
      bookingId: json['bookingId'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      time: json['time'],
      status: json['status'],
      imageUrl: json['imageUrl'],
    );
  }
}

class CheckRequestPage extends StatefulWidget {
  final int userId;
  const CheckRequestPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CheckRequestPage> createState() => _CheckRequestPageState();
}

class _CheckRequestPageState extends State<CheckRequestPage> {
  // 2. ✅ ADDED STORAGE AND TOKEN
  final _storage = const FlutterSecureStorage();
  String? _token;

  bool _isLoading = true;
  PendingBooking? _booking;
  String? _errorMsg;

  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    // 3. ✅ MODIFIED: Load token first, then fetch
    _loadTokenAndFetch();
  }

  // 4. ✅ ADDED: New function
  Future<void> _loadTokenAndFetch() async {
    final token = await _storage.read(key: 'jwt_token');
    if (mounted) {
      setState(() { _token = token; });
    }
    _fetchPendingBooking(token);
  }
  
  // 5. ✅ MODIFIED: Function now accepts and sends token
  Future<void> _fetchPendingBooking(String? token) async {
    if (token == null) {
      if (mounted) {
        setState(() {
          _errorMsg = "Error: Not logged in.";
          _isLoading = false;
        });
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final response = await http.get(
        // ✅ UPDATED: Use new user-specific route (no ID in URL)
        Uri.parse('$_baseUrl/api/user/pending-booking'),
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' 
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty && response.body != 'null') {
          final data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _booking = PendingBooking.fromJson(data);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _booking = null;
            });
          }
        }
      } else {
        if(mounted) {
          setState(() {
            _errorMsg = 'Failed to load booking: ${response.body}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error connecting to server: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
              child: Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Color.fromARGB(30, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFB9D6FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(50, 0, 0, 0),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _buildContent(),
                        ),
                        const SizedBox(height: 40),
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

  // 6. ✅ MODIFIED: Image widget now sends token
  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMsg != null) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            _errorMsg!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_booking == null) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No pending requests',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }
    
    // Show loader if token isn't ready for the image
    if (_token == null) {
       return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final String fullImageUrl = '$_baseUrl${_booking!.imageUrl}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8FF),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fullImageUrl,
              headers: {'Authorization': 'Bearer $_token'}, // <-- Add header
              width: 120,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_booking!.roomName} (${_booking!.roomType})',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _booking!.time,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(30, 0, 0, 0),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _booking!.status[0].toUpperCase() +
                          _booking!.status.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}