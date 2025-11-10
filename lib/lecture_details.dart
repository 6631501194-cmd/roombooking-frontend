import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class LectureDetails extends StatefulWidget {
  final int roomId;
  final String roomName;
  final String roomType;
  final String imagePath; // This is the full URL
  final String status;

  const LectureDetails({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.imagePath,
    required this.status,
  });

  @override
  State<LectureDetails> createState() => _LectureDetailsState();
}

class _LectureDetailsState extends State<LectureDetails> {
  bool _isLoading = true;
  String? _errorMsg;
  List<TimeSlot> _slots = [];

  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    if (widget.status == "Available") {
      _fetchTimeSlots();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTimeSlots() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/rooms/${widget.roomId}/slots'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<TimeSlot> parsedSlots =
            data.map((json) => TimeSlot.fromJson(json)).toList();
        
        if (mounted) {
          setState(() {
            _slots = parsedSlots;
            _isLoading = false;
          });
        }
      } else {
         if (mounted) {
          setState(() {
            _errorMsg = 'Failed to load slots: ${response.body}';
            _isLoading = false;
          });
         }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error connecting to server: $e';
          _isLoading = false;
        });
      }
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
    final bool isAvailable = widget.status == "Available";
    
    Widget displayedImage = Image.network(
      widget.imagePath,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
      ),
       loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
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
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                
                isAvailable
                  ? _buildSlotList()
                  : _buildDisabledList(), // Show disabled list if room is disabled

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
                  Shadow(
                    offset: Offset(2, 4),
                    blurRadius: 6,
                    color: Color.fromARGB(40, 0, 0, 0),
                  ),
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
            if (!isAvailable)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),
            if (!isAvailable)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB0BEC5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "This room is maintenance.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
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
        return buildTimeSlotReadOnly(slot);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
  }

  // ✅✅✅ THIS WIDGET IS FIXED ✅✅✅
  Widget buildTimeSlotReadOnly(TimeSlot slot) {
    final statusColor = _getColorForStatus(slot.status);
    final String statusText =
        slot.status[0].toUpperCase() + slot.status.substring(1);

    // 1. Wrap the Container in a Row with MainAxisAlignment.center
    //    This makes the white box shrink to fit its content.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 2)),
            ],
          ),
          child: Row(
            // 2. This inner Row just groups the Time and Status
            children: [
              // Time
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
              
              // 3. This SizedBox adds the separation
              const SizedBox(width: 20), 

              // Status
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
            ],
          ),
        ),
      ],
    );
  }
  // ✅✅✅ END OF FIX ✅✅✅


  // A helper to show a static 'Disabled' list
  Widget _buildDisabledList() {
    const Color redColor = Color(0xFFE53935);
    final List<Map<String, dynamic>> timeSlots = [
      {'time': '8:00 - 10:00', 'status': 'Disabled', 'color': redColor},
      {'time': '10:00 - 12:00', 'status': 'Disabled', 'color': redColor},
      {'time': '13:00 - 15:00', 'status': 'Disabled', 'color': redColor},
      {'time': '15:00 - 17:00', 'status': 'Disabled', 'color': redColor},
    ];

    return Column(
      children: timeSlots.map((slot) {
        // ✅ APPLIED THE SAME CENTERED LAYOUT FIX HERE
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slot['time'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                    decoration: BoxDecoration(
                      color: slot['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      slot['status'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}