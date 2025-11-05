import 'package:flutter/material.dart';
//import 'browse_list.dart'; // ✅ เพิ่ม import หน้านี้ (จะอยู่แยกไฟล์) ********
 
// -----------------------------
// Dashboard Placeholder
// -----------------------------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD3E6FF),
      body: Center(
        child: Text(
          'Dashboard Page (เพื่อนกำลังทำ)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// -----------------------------
// History Page
// -----------------------------
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD3E6FF),
      body: Center(
        child: Text(
          'History Page (เพิ่มเนื้อหาที่นี่)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// -----------------------------
// Lecture Request (Main Navigation Screen)
// -----------------------------
class LectureRequestScreen extends StatefulWidget {
  const LectureRequestScreen({Key? key}) : super(key: key);

  @override
  State<LectureRequestScreen> createState() => _LectureRequestScreenState();
}

class _LectureRequestScreenState extends State<LectureRequestScreen> {
  int _currentIndex = 2; // เริ่มที่ Check Request

  final List<Map<String, String>> bookedRooms = [
    {'name': 'Room 1', 'type': 'Meeting room', 'time': '08:00 - 10:00'},
    {'name': 'Room 2', 'type': 'Study room', 'time': '10:00 - 12:00'},
    {'name': 'Room 3', 'type': 'Conference room', 'time': '13:00 - 15:00'},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardScreen(),
     // const BrowseListPage(), // ✅ ไปหน้า Browse ******
      _buildCheckRequestPage(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Browse List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.checklist), label: 'Check Request'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // -----------------------------
  // Check Request Page
  // -----------------------------
  Widget _buildCheckRequestPage() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
            child: Text(
              'All Requests',
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
                child: bookedRooms.isEmpty
                    ? const Center(
                        child: Text(
                          'No requests found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: bookedRooms.length,
                        itemBuilder: (context, index) {
                          final room = bookedRooms[index];
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
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/room1.jpg',
                                        width: 100,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${room['name']} (${room['type']})',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            room['time'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _showConfirmDialog(
                                                        context, index, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: const Text('Approve'),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _showConfirmDialog(
                                                        context, index, false),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
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
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // Popup ยืนยันการ Approve/Reject
  // -----------------------------
  void _showConfirmDialog(BuildContext context, int index, bool isApprove) {
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
              'Are you sure to ${isApprove ? 'approve' : 'reject'} ?',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle,
                      color: Colors.green, size: 36),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      bookedRooms.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isApprove
                              ? 'Request approved (moved to history)'
                              : 'Request rejected (moved to history)',
                        ),
                        backgroundColor:
                            isApprove ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.cancel,
                      color: Colors.red, size: 36),
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
