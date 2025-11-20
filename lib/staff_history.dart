import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 1. Data Model
class StaffBookingHistory {
  final int bookingId;
  final String roomName;
  final String roomType;
  final String time;
  final String date;
  final String requesterName; 
  final String approverName;  
  final String imageUrl;
  final String status; 
  final String? rejectReason;

  StaffBookingHistory({
    required this.bookingId,
    required this.roomName,
    required this.roomType,
    required this.time,
    required this.date,
    required this.requesterName,
    required this.approverName,
    required this.imageUrl,
    required this.status,
    this.rejectReason,
  });

  factory StaffBookingHistory.fromJson(Map<String, dynamic> json) {
    return StaffBookingHistory(
      bookingId: json['bookingId'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      time: json['time'],
      date: json['bookingDate'] ?? json['date'],
      requesterName: json['requesterName'] ?? 'Unknown',
      approverName: json['approverName'] ?? 'N/A',
      imageUrl: json['imageUrl'],
      status: json['status'],
      rejectReason: json['rejectReason'],
    );
  }
}

class StaffHistoryPage extends StatefulWidget {
  const StaffHistoryPage({super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  List<StaffBookingHistory> _historyItems = [];
  bool _isLoading = true;
  String? _error;
  final _storage = const FlutterSecureStorage();
  String? _token;

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
    if (mounted) {
      setState(() { _token = token; });
    }
    _fetchHistory(token);
  }

  Future<void> _fetchHistory(String? token) async {
    if (token == null) {
      setState(() { _isLoading = false; _error = "Error: Not logged in"; });
      return;
    }

    try {
      final uri = Uri.parse('$_baseUrl/api/staff/history');
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (mounted) {
          setState(() {
            _historyItems = data.map((json) => StaffBookingHistory.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _isLoading = false; _error = "Failed to load: ${resp.body}"; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = "Error: $e"; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _isLoading = true; _error = null; });
    await _fetchHistory(_token);
  }

  // Helper to build the individual booking card UI (reused for grouped list)
  Widget _buildBookingCard(StaffBookingHistory item) {
    const textDark = Color(0xFF0F1621);
    final isApproved = item.status.toLowerCase() == 'reserved';
    final fullImageUrl = item.imageUrl.isNotEmpty ? '$_baseUrl${item.imageUrl}' : ''; 
    
    final statusColor = isApproved ? const Color(0xFF18A05B) : const Color(0xFFD9534F);
    final statusText = isApproved ? "Approved" : "Rejected";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                fullImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                headers: {'Authorization': 'Bearer $_token'}, 
                errorBuilder: (c, e, s) => Container(
                  width: 80, height: 80, color: Colors.grey[300], 
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Main Details
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
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                      children: [
                        const TextSpan(text: "Requested by: "),
                        TextSpan(text: item.requesterName, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Approver Name & Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isApproved ? Icons.verified_user : Icons.block,
                        size: 18,
                        color: statusColor
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 15),
                            children: [
                              TextSpan(text: isApproved ? "Approved by: " : "Rejected by: "),
                              TextSpan(text: item.approverName, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                            ],
                          ),
                        ),
                      ),
                      
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor, width: 0.5)
                        ),
                        child: Text(
                          statusText, 
                          style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)
                        ),
                      )
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
                      ]
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0F1621);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Staff History",
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

  // 4. Content builder with Grouping Logic
  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    if (_historyItems.isEmpty) {
      return const Center(child: Text("No booking history found", style: TextStyle(fontSize: 16, color: Colors.black54)));
    }

    // --- Grouping Logic ---
    final Map<String, List<StaffBookingHistory>> grouped = {};
    for (var item in _historyItems) {
      final key = item.date; // Group by the date string
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    
    // Convert map entries to a list and sort by date descending (newest first)
    final List<MapEntry<String, List<StaffBookingHistory>>> sortedGroups = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    const textDark = Color(0xFF0F1621);
    
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
              
              // Single Container holding all bookings for this day
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
                        // Add a Divider between items, but not after the last one
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
}