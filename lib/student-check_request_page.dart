import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CheckRequestPage extends StatefulWidget {
  const CheckRequestPage({Key? key}) : super(key: key);

  @override
  State<CheckRequestPage> createState() => _CheckRequestPageState();
}

class _CheckRequestPageState extends State<CheckRequestPage> {
  bool isLoading = true;
  bool hasBooking = false;
  List<dynamic> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchPendingBookings();
  }

  Future<void> fetchPendingBookings() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/bookings/today/pending'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          hasBooking = data['hasBooking'];
          bookings = data['bookings'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() {
        isLoading = false;
        hasBooking = false;
      });
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
            // 🔹 Title
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
              child: Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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

            // 🔹 Blue background area
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
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : hasBooking
                          ? ListView.builder(
                              itemCount: bookings.length,
                              itemBuilder: (context, index) {
                                final booking = bookings[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16.0),
                                  child: Container(
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
                                        // Room image (fallback if none)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
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

                                        // 🔹 Room info + status
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${booking['room_name']} (${booking['room_type']})',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${booking['start_time']} - ${booking['end_time']}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 14,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                        booking[
                                                            'booking_status']),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    booking['booking_status']
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'No pending requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange; // pending
    }
  }
}
