import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const borderGrey = Color.fromARGB(255, 168, 183, 194);
    const textDark = Color(0xFF0F1621);
    const approvedGreen = Color(0xFF18A05B);
    const rejectedRed = Color(0xFFD9534F);

    final items = <_Booking>[
      _Booking(date: DateTime(2025, 11, 22), start: '10:00', end: '12:00', room: 'Room 1', requester: 'David Lee', approved: true),
      _Booking(date: DateTime(2025, 11, 22), start: '13:00', end: '15:00', room: 'Room 2', requester: 'Anna Kim', approved: true),
      _Booking(date: DateTime(2025, 11, 23), start: '08:00', end: '10:00', room: 'Room 3', requester: 'John Smith', approved: true),
      _Booking(date: DateTime(2025, 11, 25), start: '09:00', end: '11:00', room: 'Room 4', requester: 'Mike Chan', approved: false),
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
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFB9D6FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final statusColor = it.approved ? approvedGreen : rejectedRed;
                    final statusText = it.approved ? 'Approved' : 'Rejected';

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
                              fontSize: 20,
                            ),
                          ),
                        ),

                        // Card
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderGrey),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        it.room,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        '(Meeting room)',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${it.start}-${it.end}',
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Requested by ${it.requester}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // ✅ Always show reason box below "Requested by"
                                      
                                    ],
                                  ),
                                ),

                                // Divider
                                const VerticalDivider(
                                  width: 28,
                                  thickness: 1.4,
                                  color: Colors.black,
                                ),

                                // Right Column (centered)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // ✅ Status pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // ✅ Dynamic text: Approved by / Rejected by
                                      Text(
                                        it.approved ? 'Approved by' : 'Rejected by',
                                        style: const TextStyle(
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

                                      // 🔹 Extra Reason Box for Rejected
                                      if (!it.approved) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD6E6FF),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Color(0xFF8BB4FF), width: 1.2),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color.fromARGB(30, 0, 0, 0),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'Reason: The room will be renovated soon.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
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
