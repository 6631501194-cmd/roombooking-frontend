import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 

// 1. A model to hold the pending booking data
class PendingRequest {
  final int bookingId;
  final String roomName;
  final String roomType;
  final String time;
  final String requesterName;
  final String imageUrl;

  PendingRequest({
    required this.bookingId,
    required this.roomName,
    required this.roomType,
    required this.time,
    required this.requesterName,
    required this.imageUrl,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      bookingId: json['bookingId'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      time: json['time'],
      requesterName: json['requesterName'],
      imageUrl: json['imageUrl'],
    );
  }
}

// 2. This is the correct CheckRequestPage widget
class CheckRequestPage extends StatefulWidget {
  // 3. It needs the lecturer's ID to approve/reject
  final int userId;
  const CheckRequestPage({super.key, required this.userId});

  @override
  State<CheckRequestPage> createState() => _CheckRequestPageState();
}

class _CheckRequestPageState extends State<CheckRequestPage> {
  // 4. Removed static list, added state variables
  List<PendingRequest> _pendingRequests = [];
  bool _isLoading = true;
  String? _error;
  final _storage = const FlutterSecureStorage();
  String? _token; 

  // 5. Added URL getter
  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000'; 
  }

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  // 6. Function to load token
  Future<void> _loadTokenAndFetch() async {
    final token = await _storage.read(key: 'jwt_token');
    if (mounted) {
      setState(() { _token = token; });
    }
    _fetchPendingRequests(token);
  }
  
  // 7. Function to get all pending requests
  Future<void> _fetchPendingRequests(String? token) async {
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = "Error: Not logged in.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/lecturer/bookings/pending');
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (mounted) {
          setState(() {
            _pendingRequests =
                data.map((json) => PendingRequest.fromJson(json)).toList();
          });
        }
      } else {
         if (mounted) {
          setState(() => _error = "Failed to load requests: ${resp.body}");
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

  // 8. Function to approve a booking
  Future<void> _approveBooking(int bookingId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/approve');
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception("Token is missing");
      
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' 
        },
      );

      if (resp.statusCode == 200) {
        _fetchPendingRequests(token); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Booking approved!'),
                backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception(resp.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error approving: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // 9. Function to reject a booking
  Future<void> _rejectBooking(int bookingId, String reason) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/reject');
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception("Token is missing");

      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' 
        },
        body: json.encode({
          'reason': reason,
        }),
      );

      if (resp.statusCode == 200) {
        _fetchPendingRequests(token);
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Booking rejected.'), backgroundColor: Colors.orange),
          );
         }
      } else {
        throw Exception(resp.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error rejecting: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
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
            // ✅✅✅ TITLE FONT/TEXT UPDATED ✅✅✅
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
              child: Text(
                'Pending Requests', // Changed text
                style: TextStyle(
                  fontSize: 34, // Changed from 26
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [ // Added shadow
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Color.fromARGB(30, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),

            // The blue rounded background area
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
                        // White container from the student page
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FF), // White box
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No pending requests found for today',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _pendingRequests.length,
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        final fullImageUrl = '$_baseUrl${request.imageUrl}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8FF), 
              borderRadius: BorderRadius.circular(20),
               boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(25, 0, 0, 0),
                  blurRadius: 8,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    fullImageUrl,
                    headers: {'Authorization': 'Bearer $_token'},
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 90,
                      height: 80,
                      color: Colors.grey.shade200,
                      child:
                          const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅✅✅ FONT/STYLE UPDATED ✅✅✅
                      Text('${request.roomName} (${request.roomType})',
                          style: const TextStyle(
                              fontSize: 22, // Changed from 16
                              color: Colors.black87, // Changed from blue
                              fontWeight: FontWeight.w600, // Added
                              // decoration: TextDecoration.underline (REMOVED)
                              )),
                      const SizedBox(height: 4),
                      // ✅✅✅ FONT/STYLE UPDATED ✅✅✅
                      Text(request.time,
                          style: const TextStyle(
                              fontSize: 20, // Changed from 14
                              color: Colors.black54, // Changed from black87
                              )),
                      const SizedBox(height: 4),
                      Text('By: ${request.requesterName}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _showConfirmDialog(context, request, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10))),
                            child: const Text('Approve'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _showConfirmDialog(context, request, false),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10))),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // This dialog function is unchanged
  void _showConfirmDialog(
      BuildContext context, PendingRequest request, bool isApprove) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD1DCE4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure to ${isApprove ? 'approve' : 'reject'}?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (!isApprove) ...[
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle,
                      color: Colors.green, size: 36),
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (!isApprove && reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter a reason before rejecting.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context); // Close dialog

                    if (isApprove) {
                      _approveBooking(request.bookingId);
                    } else {
                      _rejectBooking(request.bookingId, reason);
                    }
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 36),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}