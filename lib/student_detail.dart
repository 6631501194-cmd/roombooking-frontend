import 'dart:convert';
import 'dart:io'; // 1. IMPORT 'dart:io'
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// A simple class to model the API response for a time slot
class TimeSlot {
  final int slotId;
  final String time;
  final String status;
  final bool canBook;

  TimeSlot({
    required this.slotId,
    required this.time,
    required this.status,
    required this.canBook,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      slotId: json['slotId'],
      time: json['time'],
      status: json['status'],
      canBook: json['canBook'],
    );
  }
}

class RoomDetailScreen extends StatefulWidget {
  final int roomId;
  final int userId; // Assuming userId is passed after login
  final String roomName;
  final String roomType;
  final String imageUrl; // Changed from imagePath to imageUrl

  const RoomDetailScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.roomName,
    required this.roomType,
    required this.imageUrl,
  });

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _isLoading = true;
  String? _errorMsg;
  List<TimeSlot> _slots = [];

  // 2. REPLACED hardcoded string with a dynamic getter
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    // iOS Simulator and web/desktop use localhost
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  Future<void> _fetchTimeSlots() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // It will now use the correct URL for iOS
      final response = await http
          .get(Uri.parse('$_baseUrl/api/rooms/${widget.roomId}/slots'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<TimeSlot> parsedSlots =
            data.map((json) => TimeSlot.fromJson(json)).toList();
        
        setState(() {
          _slots = parsedSlots;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Failed to load slots: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error connecting to server: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _bookSlot(int slotId) async {
    try {
      final response = await http.post(
        // It will also use the correct URL for iOS here
        Uri.parse('$_baseUrl/api/rooms/${widget.roomId}/slots/$slotId/book'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'userId': widget.userId}),
      );

      if (response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created! Please wait for approval.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _fetchTimeSlots(); // Refresh the list after booking
      } else {
        // Handle API errors (409, 400, etc.)
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String message = errorData['message'] ?? 'Failed to book slot.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        _fetchTimeSlots(); // Refresh list even on error (e.g., "slot taken")
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF00C896);
      case 'pending':
        return const Color(0xFFFFA500);
      case 'reserved':
        return const Color(0xFF008CBA);
      case 'expired':
        return Colors.grey.shade600;
      case 'disabled':
        return Colors.red.shade400;
      default:
        return Colors.grey;
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
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Room Details',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Body
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFB9D6FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.roomName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "(${widget.roomType})",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Available Time",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Dynamic Time Slot List
                      _buildSlotList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotList() {
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

    if (_slots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No time slots available for this room.',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _slots.length,
      itemBuilder: (context, index) {
        final slot = _slots[index];
        return buildTimeSlot(slot);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
  }

  Widget buildTimeSlot(TimeSlot slot) {
    final statusColor = _getColorForStatus(slot.status);
    final String statusText =
        slot.status[0].toUpperCase() + slot.status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              slot.time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (slot.canBook) {
                showBookingDialog(
                  'Are you sure to book this room?',
                  true,
                  () => _bookSlot(slot.slotId),
                );
              } else {
                String message = "This room is not available.\nPlease try another slot.";
                if (slot.status == 'disabled') {
                  message = "This room is under maintenance.\nCan’t book it";
                } else if (slot.status == 'expired') {
                   message = "This time slot has already passed.";
                } else if (slot.status == 'pending' || slot.status == 'reserved') {
                  message = "This time slot is already ${slot.status}.";
                }
                
                showBookingDialog(
                  message,
                  false,
                  null,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  slot.canBook ? const Color(0xFF222558) : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            ),
            child: const Text(
              "Book",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBookingDialog(String title, bool confirm, VoidCallback? onBooked) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFE6F0FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 22),
                confirm
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green, size: 45),
                            onPressed: () {
                              Navigator.pop(context);
                              if (onBooked != null) {
                                onBooked();
                              }
                            },
                          ),
                          const SizedBox(width: 50),
                          IconButton(
                            icon: const Icon(Icons.cancel,
                                color: Colors.red, size: 42),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87, size: 36),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}