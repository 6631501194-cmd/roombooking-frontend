import 'package:flutter/material.dart';
import 'package:flutter_application_1/lecture_details.dart';

class LectureBrowseList extends StatelessWidget {
  const LectureBrowseList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> rooms = [
      {
        "name": "Room 1",
        "type": "Meeting room",
        "image": "assets/images/studyRoom1.png",
      },
      {
        "name": "Room 2",
        "type": "Meeting room",
        "image": "assets/images/studyRoom2.jpg",
      },
      {
        "name": "Room 3",
        "type": "Seminar room",
        "image": "assets/images/seminarRoom.jpeg",
      },
      {
        "name": "Room 4",
        "type": "Multimedia room",
        "image": "assets/images/multimediaRoom1.jpeg",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Browse List",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 4),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
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
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search room name',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: rooms.map((room) {
                            return Container(
                              width: 360,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Color(0xFFE5EBFC),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              // Make the main Column left-aligned so title/type are left
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 200,
                                          height: 120,
                                          color: Colors.white,
                                          child: Image.asset(
                                            room["image"]!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LectureDetails(
          roomName: room["name"]!,
          roomType: room["type"]!,
          imagePath: room["image"]!,
          status: "Available", // or "Disabled" if you want to test disabled mode
        ),
      ),
    );
  },
  icon: const Icon(
    Icons.info_outline,
    size: 20,
    color: Colors.white,
  ),
  label: const Text(
    "Detail",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF222558),
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    minimumSize: const Size(110, 44),
  ),
)

                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Force the title/type block to use the full card width and be left-aligned
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room["name"]!,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "(${room["type"]!})",
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
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