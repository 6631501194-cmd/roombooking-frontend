import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

class StaffRoomDetail extends StatelessWidget {
  final String roomName;
  final String roomType;
  final String imagePath;
  final String status;

  const StaffRoomDetail({
    super.key,
    required this.roomName,
    required this.roomType,
    required this.imagePath,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = status == "Available";
    final List<Map<String, dynamic>> timeSlots;
    const Color redColor = Color(0xFFE53935);

    if (isAvailable) {
      timeSlots = [
        {
          'time': '8:00 - 10:00',
          'status': 'Available',
          'color': const Color(0xFF00C896),
        },
        {
          'time': '10:00 - 12:00',
          'status': 'Pending',
          'color': const Color(0xFFFFA500),
        },
        {
          'time': '13:00 - 15:00',
          'status': 'Reserved',
          'color': const Color(0xFF008CBA),
        },
        {
          'time': '15:00 - 17:00',
          'status': 'Reserved',
          'color': const Color(0xFF008CBA),
        },
      ];
    } else {
      timeSlots = [
        {'time': '8:00 - 10:00', 'status': 'Disable', 'color': redColor},
        {'time': '10:00 - 12:00', 'status': 'Disable', 'color': redColor},
        {'time': '13:00 - 15:00', 'status': 'Disable', 'color': redColor},
        {'time': '15:00 - 17:00', 'status': 'Disable', 'color': redColor},
      ];
    }

    Widget displayedImage;
    if (imagePath.startsWith('assets/')) {
      displayedImage = Image.asset(
        imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      displayedImage = Image.file(
        File(imagePath),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    }

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
                    roomName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "($roomType)",
                    style: const TextStyle(fontSize: 22, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Available Time",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: timeSlots.map((slot) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 130),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C4DFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                slot['time'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 120),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: slot['color'] as Color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                slot['status'] as String,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
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
            if (status == "Disabled")
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),

            if (status == "Disabled")
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
}
