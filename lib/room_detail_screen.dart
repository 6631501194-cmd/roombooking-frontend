import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TimeSlot {
  final int slotId;
  final String time;
  final String status;

  TimeSlot({required this.slotId, required this.time, required this.status});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      slotId: json['slotId'],
      time: json['time'],
      status: json['status'],
    );
  }
}

class StaffRoomDetail extends StatefulWidget {
  final int roomId;
  final String roomName;
  final String roomType;
  final String imagePath; // Full URL
  final String status;

  const StaffRoomDetail({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.imagePath,
    required this.status,
  });

  @override
  State<StaffRoomDetail> createState() => _StaffRoomDetailState();
}

class _StaffRoomDetailState extends State<StaffRoomDetail> {
  List<TimeSlot> _slots = [];
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
    setState(() { _token = token; });
    
    // Only fetch slots if the room is active
    if (widget.status == "Available") {
      _fetchSlots(token);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSlots(String? token) async {
    if (token == null) {
      setState(() { _isLoading = false; _error = "Not logged in"; });
      return;
    }

    try {
      // Using the same API as Lecturer to get slots
      final uri = Uri.parse('$_baseUrl/api/rooms/${widget.roomId}/slots');
      final resp = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (mounted) {
          setState(() {
            _slots = data.map((json) => TimeSlot.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return const Color(0xFF00C896);
      case 'pending':   return const Color(0xFFFFA500);
      case 'reserved':  return const Color(0xFF008CBA);
      case 'expired':   return Colors.grey;
      case 'disabled':  return const Color(0xFFE53935);
      default:          return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = widget.status == "Available";

    Widget displayedImage = (_token == null) 
      ? Container(height: 200, color: Colors.grey[300])
      : Image.network(
          widget.imagePath,
          headers: {'Authorization': 'Bearer $_token'},
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            height: 200, color: Colors.grey[300], 
            child: const Icon(Icons.image_not_supported, size: 50)
          ),
        );

    final roomDetailContent = Expanded(
      child: Container(
        width: double.infinity,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: displayedImage,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.roomName,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Center(
                  child: Text(
                    "(${widget.roomType})",
                    style: const TextStyle(fontSize: 22, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Today's Status",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                
                if (isAvailable) ...[
                   if (_isLoading) 
                      const Center(child: CircularProgressIndicator())
                   else if (_slots.isEmpty)
                      const Padding(padding: EdgeInsets.all(20), child: Text("No slots found."))
                   else
                      Column(
                        children: _slots.map((slot) {
                          String statusTxt = slot.status[0].toUpperCase() + slot.status.substring(1);
                          return _buildSlotItem(slot.time, statusTxt, _getStatusColor(slot.status));
                        }).toList(),
                      ),
                ] else ...[
                  // Fallback visual for Disabled rooms
                  _buildSlotItem("8:00 - 10:00", "Disable", const Color(0xFFE53935)),
                  _buildSlotItem("10:00 - 12:00", "Disable", const Color(0xFFE53935)),
                  _buildSlotItem("13:00 - 15:00", "Disable", const Color(0xFFE53935)),
                  _buildSlotItem("15:00 - 17:00", "Disable", const Color(0xFFE53935)),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    final header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              "Room Details",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: [
                  Shadow(offset: Offset(2, 4), blurRadius: 6, color: Color.fromARGB(40, 0, 0, 0)),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(children: [header, roomDetailContent]),
            
            if (!isAvailable) ...[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB0BEC5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "This room is maintenance.",
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSlotItem(String time, String status, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 130),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}