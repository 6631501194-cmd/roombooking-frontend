import 'dart:ui';
import 'package:flutter/material.dart';
import 'student_request.dart'; // ✅ นำเข้าหน้า StudentRequestScreen

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool hasBooking = false; // ✅ เพิ่มสถานะการจอง

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // ✅ เมื่อกด "Check Requests"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentRequestScreen(hasBooking: hasBooking),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Check Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 แถวบนสุด
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 เนื้อหา
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/room1.jpg', height: 180, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 10),
                      const Text('Room 1',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('(Meeting room)',
                          style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Available Time',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),

                      // 🔸 Time Slots
                      _buildTimeSlot('8:00-10:00', 'Available', Colors.green, true, context, onBooked),
                      const SizedBox(height: 8),
                      _buildTimeSlot('10:00-12:00', 'Pending', Colors.orange, false, context, null),
                      const SizedBox(height: 8),
                      _buildTimeSlot('13:00-15:00', 'Reserved', Colors.teal, false, context, null),
                      const SizedBox(height: 8),
                      _buildTimeSlot('15:00-17:00', 'Maintenance', Colors.grey, false, context, null),
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

  // ✅ เมื่อจองสำเร็จ
  void onBooked() {
    setState(() {
      hasBooking = true;
    });
  }

  static Widget _buildTimeSlot(
    String time,
    String status,
    Color statusColor,
    bool canBook,
    BuildContext context,
    VoidCallback? onBooked,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // เวลา
          Container(
            decoration: BoxDecoration(
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(time,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          // สถานะ
          Container(
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Text(status,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          // ปุ่ม Book
          ElevatedButton(
            onPressed: () {
              if (canBook) {
                _showDialog(context,
                    title: 'Are you sure to book this room ?',
                    confirm: true,
                    onBooked: onBooked);
              } else {
                _showDialog(context,
                    title: 'This room is maintenance.\nCan’t book it', confirm: false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canBook ? Colors.blueGrey.shade900 : Colors.grey.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  // 🔹 Popup dialog
  static void _showDialog(BuildContext context,
      {required String title, required bool confirm, VoidCallback? onBooked}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      pageBuilder: (context, _, __) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Dialog(
              backgroundColor: const Color(0xFFE6F0FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 20),
                    confirm
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green, size: 40),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Room booked successfully!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  if (onBooked != null) onBooked();
                                },
                              ),
                              const SizedBox(width: 40),
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.red, size: 40),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
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
            ),
          ),
        );
      },
    );
  }
}
