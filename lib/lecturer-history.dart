import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Model for the history data from the API
class BookingHistory {
  final int bookingId;
  final String status;
  final String? rejectReason;
  final String date;
  final String roomName;
  final String roomType;
  final String time;
  final String approverName;
  final String requesterName;

  BookingHistory({
    required this.bookingId,
    required this.status,
    this.rejectReason,
    required this.date,
    required this.roomName,
    required this.roomType,
    required this.time,
    required this.approverName,
    required this.requesterName,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: some API fields may be null or use slightly
    // different names depending on the backend SQL aliases. Normalize
    // and provide safe defaults to avoid runtime type errors.
    final bookingId = json['bookingId'] is int
        ? json['bookingId'] as int
        : int.tryParse('${json['bookingId']}') ?? 0;

    final status = (json['status'] ?? json['booking_status'])?.toString() ?? '';
    final rejectReason = json['rejectReason']?.toString();
    final date = (json['date'] ?? json['bookingDate'])?.toString() ?? '';
    final roomName = (json['roomName'] ?? json['room_name'])?.toString() ?? '';
    final roomType = (json['roomType'] ?? json['room_type'])?.toString() ?? '';
    final time = (json['time'] ?? ((json['startTime'] ?? '') is String ? '${json['startTime']}-${json['endTime']}' : ''))?.toString() ?? '';
    final approverName = (json['approverName'] ?? json['approver_name'])?.toString() ?? 'N/A';
    final requesterName = (json['requesterName'] ?? json['requester_name'] ?? json['username'])?.toString() ?? 'Unknown';

    return BookingHistory(
      bookingId: bookingId,
      status: status,
      rejectReason: rejectReason,
      date: date,
      roomName: roomName,
      roomType: roomType,
      time: time,
      approverName: approverName,
      requesterName: requesterName,
    );
  }
}

// 2. Converted to StatefulWidget
class HistoryPage extends StatefulWidget {
  // 3. This is the logged-in lecturer's ID
  final int userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // 4. State variables for loading, data, and errors
  bool _isLoading = true;
  List<BookingHistory> _historyItems = [];
  String? _errorMsg;

  // Colors
  static const borderGrey = Color.fromARGB(255, 168, 183, 194);
  static const textDark = Color(0xFF0F1621);
  static const approvedGreen = Color(0xFF18A05B);
  static const rejectedRed = Color(0xFFD9534F);

  // 5. Dynamic base URL
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    // 6. Fetch data on page load
    _fetchHistory();
  }

  // 7. Updated function to call the NEW lecturer history API
  Future<void> _fetchHistory() async {
    // Safety check
    if (widget.userId == 0) {
      setState(() {
         _isLoading = false;
        _errorMsg = "Error: No user ID was provided.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // ✅ This is the correct API route for a lecturer's history
      final uri = Uri.parse('$_baseUrl/api/lecturer/${widget.userId}/history');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _historyItems =
                data.map((json) => BookingHistory.fromJson(json)).toList();
          });
        }
      } else {
         if (mounted) {
          setState(() {
            _errorMsg = 'Failed to load history: ${response.body}';
          });
         }
      }
    } catch (e) {
       if (mounted) {
        setState(() {
          _errorMsg = 'Error connecting to server: ${e.toString()}';
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

  // 8. Helper to build the main content
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMsg!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_historyItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'You have not processed any bookings yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    // 9. Use the dynamic list from the state
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _historyItems.length,
      itemBuilder: (context, i) {
        final item = _historyItems[i];
        final bool isApproved = item.status == 'reserved';
        final statusColor = isApproved ? approvedGreen : rejectedRed;
        final statusText = isApproved ? 'Approved' : 'Rejected';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                item.date, // Use data from API
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: textDark,
                  fontSize: 20,
                ),
              ),
            ),

            // Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // ✅✅✅ --- CORRECTED LAYOUT --- ✅✅✅
                    // Left Column (Room Info + Requester)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.roomName, // Room Name
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '(${item.roomType})', // Room Type
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.time, // Time
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Show "Requested by"
                          Text(
                            'Requested by',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            item.requesterName, // Requester Name
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    const VerticalDivider(
                      width: 28,
                      thickness: 1.4,
                      color: Colors.black,
                    ),

                    // Right Column (Status)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor, // Dynamic color
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText, // Dynamic text
                              style: const TextStyle(
                                color: Colors.black, 
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Show "Processed by"
                          Text(
                            isApproved ? 'Approved by' : 'Rejected by',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          Text(
                            "You", // The API only returns items processed by this user
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          
                          // Conditionally show reject reason
                          if (!isApproved &&
                              item.rejectReason != null &&
                              item.rejectReason!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6E6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF8BB4FF), width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(30, 0, 0, 0),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Reason: ${item.rejectReason}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ✅✅✅ --- END OF LAYOUT FIX --- ✅✅✅
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
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
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'History',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Color.fromARGB(30, 0, 0, 0)),
                    ],
                  ),
                ),
              ),
            ),
            // Blue background
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
                // 11. Call the dynamic content builder
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}