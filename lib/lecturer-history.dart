import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Lecturer history: use the same Staff two-column card UI but show only
// "Requested by" (requesterName) and the lecturer's decision (Approved/Rejected).
// No "Approved by" shown because the lecturer is the approver.

class LecturerBookingHistory {
  final int bookingId;
  final String roomName;
  final String roomType;
  final String time;
  final String date;
  final String requesterName;
  final String imageUrl;
  final String status;
  final String? rejectReason;

  LecturerBookingHistory({
    required this.bookingId,
    required this.roomName,
    required this.roomType,
    required this.time,
    required this.date,
    required this.requesterName,
    required this.imageUrl,
    required this.status,
    this.rejectReason,
  });

  factory LecturerBookingHistory.fromJson(Map<String, dynamic> json) {
    return LecturerBookingHistory(
      bookingId: json['bookingId'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      time: json['time'],
      date: json['bookingDate'] ?? json['date'],
      requesterName: json['requesterName'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'],
      rejectReason: json['rejectReason'],
    );
  }
}

class HistoryPage extends StatefulWidget {
  final int userId;
  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<LecturerBookingHistory> _historyItems = [];
  bool _isLoading = true;
  String? _error;
  final _storage = const FlutterSecureStorage();
  String? _token;

  static const borderGrey = Color.fromARGB(255, 168, 183, 194);
  static const textDark = Color(0xFF0F1621);
  static const approvedGreen = Color(0xFF18A05B);
  static const rejectedRed = Color(0xFFD9534F);

  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final token = await _storage.read(key: 'jwt_token');
    if (mounted) setState(() => _token = token);
    await _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (widget.userId == 0) {
      setState(() {
        _isLoading = false;
        _error = "Error: No user ID was provided.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/lecturer/history');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _historyItems = data.map((json) => LecturerBookingHistory.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _isLoading = false; _error = "Failed to load: ${response.statusCode} ${response.body}"; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = "Error: $e"; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _isLoading = true; _error = null; });
    await _fetchHistory();
  }

  // Build booking card using the exact staff layout but without "Approved by" text
  Widget _buildBookingCard(LecturerBookingHistory item) {
    final isApproved = item.status.toLowerCase() == 'reserved';
    final fullImageUrl = item.imageUrl.isNotEmpty ? '$_baseUrl${item.imageUrl}' : '';
    final statusColor = isApproved ? approvedGreen : rejectedRed;
    final statusText = isApproved ? "Approved" : "Rejected";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (same size as staff)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: fullImageUrl.isEmpty
                  ? Container(
                      width: 80, height: 80, color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    )
                  : Image.network(
                      fullImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      // only pass header if token exists
                      headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                      errorBuilder: (c, e, s) => Container(
                        width: 80, height: 80, color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Main Details (room, time, requester, status)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.roomName} (${item.roomType})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.time,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  // Requester Name (Student)
                  Row(
                    children: [
                      const Text(
                        "Requested by: ",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      Text(
                        item.requesterName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status row (icon + text) and badge (no approver name)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isApproved ? Icons.verified_user : Icons.block,
                        size: 18,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isApproved ? "Approved" : "Rejected",
                          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor, width: 0.5),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Rejection Reason (if rejected)
                  if (!isApproved && item.rejectReason != null && item.rejectReason!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Reason: ${item.rejectReason}",
                        style: TextStyle(fontSize: 14, color: Colors.black, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    if (_historyItems.isEmpty) {
      return const Center(child: Text("You have not processed any bookings yet.", style: TextStyle(fontSize: 16, color: Colors.black54)));
    }

    // Group by date
    final Map<String, List<LecturerBookingHistory>> grouped = {};
    for (var item in _historyItems) {
      final key = item.date;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final List<MapEntry<String, List<LecturerBookingHistory>>> sortedGroups = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: sortedGroups.length,
        itemBuilder: (context, index) {
          final group = sortedGroups[index];
          final dateStr = group.key;
          final bookings = group.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: textDark,
                    fontSize: 20,
                  ),
                ),
              ),

              // Container holding all bookings for this day (same styling as staff)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: List.generate(bookings.length, (i) {
                    final item = bookings[i];
                    return Column(
                      children: [
                        _buildBookingCard(item),
                        if (i < bookings.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, thickness: 1, color: Colors.black12),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
            ],
          );
        },
      ),
    );
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "History",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
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
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}