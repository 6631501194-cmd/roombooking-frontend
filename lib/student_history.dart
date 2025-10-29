import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors
    const bgBlue = Color.fromRGBO(207, 224, 255, 1);
    const cardGrey = Color.fromARGB(255, 176, 189, 197);
    const borderGrey = Color.fromARGB(255, 168, 183, 194);
    const textDark = Color(0xFF0F1621);
    const approvedGreen = Color(0xFF18A05B);
    const rejectedRed = Color(0xFFD9534F); // ป้าย Rejected
    const blueSelected = Color(0xFF1E5CD9);

    final items = <_Booking>[
      _Booking(date: DateTime(2025, 11, 22), start: '10:00', end: '12:00', room: 'Room 1', requester: 'David Lee', approved: true),
      _Booking(date: DateTime(2025, 11, 22), start: '10:00', end: '12:00', room: 'Room 1', requester: 'David Lee', approved: false), 
      _Booking(date: DateTime(2025, 11, 22), start: '10:00', end: '12:00', room: 'Room 1', requester: 'David Lee', approved: true),
      _Booking(date: DateTime(2025, 11, 22), start: '10:00', end: '12:00', room: 'Room 1', requester: 'David Lee', approved: true),
    ];

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
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),

            // BG
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: bgBlue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(48),
                    topLeft: Radius.circular(48),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final statusColor = it.approved ? approvedGreen : rejectedRed;
                    final statusText  = it.approved ? 'Approved' : 'Rejected';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            _fmtDate(it.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: textDark,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        // Card
                        Container(
                          decoration: BoxDecoration(
                            color: cardGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderGrey),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left 
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        it.room,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        '(Meeting room)',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${it.start}-${it.end}',
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Center Divider
                                const VerticalDivider(
                                  width: 28,
                                  thickness: 1.4,
                                  color: Colors.black,
                                ),

                                // Right 
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Approved by',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        'Aj. John',
                                        style: TextStyle(
                                          color: textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: blueSelected,
        unselectedItemColor: const Color.fromARGB(150, 18, 26, 141),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_sharp), label: 'Check Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'History'),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _Booking {
  final DateTime date;
  final String start;
  final String end;
  final String room;
  final String requester;
  final bool approved;
  _Booking({
    required this.date,
    required this.start,
    required this.end,
    required this.room,
    required this.requester,
    required this.approved,
  });
}
