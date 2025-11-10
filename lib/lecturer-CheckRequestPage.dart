import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // 5. Added URL getter
  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000'; // For iOS Simulator
  }

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  // 6. Function to get all pending requests
  Future<void> _fetchPendingRequests() async {
    // Safety check: if userId is 0, it means it wasn't passed correctly.
    if (widget.userId == 0) {
      setState(() {
        _isLoading = false;
        _error = "Error: No user ID was provided to this page.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/bookings/pending');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));

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
        setState(() => _error = "Error connecting to server: ${e.toString()}");
       }
    } finally {
       if (mounted) {
        setState(() => _isLoading = false);
       }
    }
  }

  // 7. Function to approve a booking
  Future<void> _approveBooking(int bookingId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/approve');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'approverId': widget.userId}), // Pass lecturer's ID
      );

      if (resp.statusCode == 200) {
        _fetchPendingRequests(); // Refresh the list
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

  // 8. Function to reject a booking
  Future<void> _rejectBooking(int bookingId, String reason) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/reject');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'approverId': widget.userId, // Pass lecturer's ID
          'reason': reason,
        }),
      );

      if (resp.statusCode == 200) {
        _fetchPendingRequests(); // Refresh the list
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
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
            child: Text(
              'All Pending Requests',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFD3E6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                // 9. Added dynamic content widget
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 10. Helper widget to show loading, error, or list
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
        child: Text(
          'No pending requests found for today',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        final fullImageUrl = '$_baseUrl${request.imageUrl}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // 11. Use Image.network
                    child: Image.network(
                      fullImageUrl,
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
                        // 12. Use dynamic data
                        Text('${request.roomName} (${request.roomType})',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline)),
                        const SizedBox(height: 4),
                        Text(request.time,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 4),
                        // 13. Added requester name
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
                              // 14. Call API function
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
                              // 15. Call API function
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
          ),
        );
      },
    );
  }

  // 16. Updated dialog to call the API
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

                    // 17. Call the correct API function
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