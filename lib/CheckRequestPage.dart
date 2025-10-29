import 'package:flutter/material.dart';
import 'package:flutter_application_1/history.dart';
import 'lecturer_dashboard.dart';
import 'lecture_BrowseList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2; 
  final List<Widget> _pages = const [
    LectureDashboard(),
    LectureBrowseList(),
    CheckRequestPage(),
    HistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Browse List"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Check Request"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}

class CheckRequestPage extends StatefulWidget {
  const CheckRequestPage({super.key});

  @override
  State<CheckRequestPage> createState() => _CheckRequestPageState();
}

class _CheckRequestPageState extends State<CheckRequestPage> {
  final List<Map<String, String>> bookedRooms = [
    {'name': 'Room 1', 'type': 'Meeting room', 'time': '08:00 - 10:00'},
    {'name': 'Room 2', 'type': 'Study room', 'time': '10:00 - 12:00'},
    {'name': 'Room 3', 'type': 'Conference room', 'time': '13:00 - 15:00'},
  ];

  @override
  Widget build(BuildContext context) {
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
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/studyRoom1.png',
        width: 90,
        height: 80,
        fit: BoxFit.cover,
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${room['name']} (${room['type']})',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline)),
          const SizedBox(height: 4),
          Text(room['time'] ?? '',
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => _showConfirmDialog(context, index, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Approve'),
              ),
              ElevatedButton(
                onPressed: () => _showConfirmDialog(context, index, false),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 36),
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
                        backgroundColor: isApprove ? Colors.green : Colors.red,
                      ),
                    );
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
