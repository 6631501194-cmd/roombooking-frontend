import 'package:flutter/material.dart';

class CheckRequestPage extends StatelessWidget {
  // Default to true so the page shows the sample pending result by default (like the provided image).
  // Change to false when integrating with real data.
  final bool hasBooking;

  const CheckRequestPage({Key? key, this.hasBooking = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title (white area)
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
              child: Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  // small shadow like in the screenshot
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Color.fromARGB(30, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),

            // The blue rounded background area
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Large rounded inner panel (as shown in the image)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(50, 0, 0, 0),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // The card showing the pending request (only when hasBooking is true)
                              if (hasBooking)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F8FF),
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(25, 0, 0, 0),
                                        blurRadius: 8,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      
                                      // Room image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          'assets/images/studyRoom1.png',
                                          width: 120,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 120,
                                                  height: 90,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Room info + status
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Room title
                                            const Text(
                                              'Room 1  (Meeting room)',
                                              style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            // Time
                                            const Text(
                                              '10:00-12:00',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black54,
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            // Pending pill aligned to left of the right column (similar to example)
                                            // 🔹 Status pill
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                        30,
                                                        0,
                                                        0,
                                                        0,
                                                      ),
                                                      blurRadius: 6,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: const Text(
                                                  'Pending',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            // 🔹 Reason for booking section
                                          
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // If no booking, show friendly "no pending requests" message in this panel
                              if (!hasBooking)
                                SizedBox(
                                  height: 160,
                                  child: Center(
                                    child: Text(
                                      'No pending requests',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // space so the scrollbar looks similar to your screenshot
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
