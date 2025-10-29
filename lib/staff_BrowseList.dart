import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/toggle_status_dialog.dart';
import 'room_detail_screen.dart';
import 'edit_room_dialog.dart';
import 'add_room_dialog.dart';

class StaffBrowselist extends StatefulWidget {
  const StaffBrowselist({super.key});

  @override
  State<StaffBrowselist> createState() => _StaffBrowselistState();
}

class _StaffBrowselistState extends State<StaffBrowselist> {
  final List<Map<String, String>> rooms = [
    {
      "name": "Room 1",
      "type": "Meeting room",
      "image": "assets/images/studyRoom1.png",
      "status": "Available",
    },
    {
      "name": "Room 2",
      "type": "Meeting room",
      "image": "assets/images/studyRoom2.jpg",
      "status": "Available",
    },
    {
      "name": "Room 3",
      "type": "Seminar room",
      "image": "assets/images/seminarRoom.jpeg",
      "status": "Available",
    },
    {
      "name": "Room 4",
      "type": "Multimedia room",
      "image": "assets/images/multimediaRoom1.jpeg",
      "status": "Available",
    },
  ];

  Future<void> _addRoom() async {
    final newRoom = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddRoomDialog(),
    );

    if (newRoom != null) {
      setState(() {
        rooms.add({
          "name": newRoom["name"],
          "type": newRoom["type"],
          "image": newRoom["image"],
          "status": "Available",
        });
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Room added successfully!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
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
                            color: Color.fromARGB(40, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addRoom,
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF222558),
                        size: 18,
                      ),
                    ),
                    label: const Padding(
                      padding: EdgeInsets.only(left: 4.0, right: 6.0),
                      child: Text(
                        "Add Room",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222558),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      minimumSize: const Size(120, 44),
                    ),
                  ),
                ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: rooms.map((room) {
                              final currentStatus =
                                  room["status"] ?? "Available";
                              final isAvailable =
                                  currentStatus == "Available";

                              return Container(
                                width: 360,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF4FF),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            width: 200,
                                            height: 120,
                                            color: Colors.white,
                                            child: room["image"]!
                                                    .startsWith('assets/')
                                                ? Image.asset(
                                                    room["image"]!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color:
                                                            Colors.grey[300],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.grey,
                                                            size: 40,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Image.file(
                                                    File(room["image"]!),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color:
                                                            Colors.grey[300],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.grey,
                                                            size: 40,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        SizedBox(
                                          width: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StaffRoomDetail(
                                                        roomName:
                                                            room["name"] ??
                                                                "",
                                                        roomType:
                                                            room["type"] ??
                                                                "",
                                                        imagePath:
                                                            room["image"] ??
                                                                "",
                                                        status:
                                                            currentStatus,
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
                                                  " Detail",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(
                                                    0xFF222558,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 12,
                                                  ),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  minimumSize:
                                                      const Size.fromHeight(
                                                          44),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  final editedRoom =
                                                      await showDialog<
                                                          Map<String,
                                                              dynamic>>(
                                                    context: context,
                                                    builder: (context) =>
                                                        EditRoomDialog(
                                                      room: room,
                                                    ),
                                                  );

                                                  if (editedRoom != null) {
                                                    setState(() {
                                                      final index =
                                                          rooms.indexOf(room);
                                                      rooms[index] = {
                                                        "name": editedRoom[
                                                            "name"],
                                                        "type": editedRoom[
                                                            "type"],
                                                        "image": editedRoom[
                                                            "image"],
                                                        "status":
                                                            currentStatus,
                                                      };
                                                    });

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Room updated successfully!",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                label: const Text(
                                                  " Edit",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(
                                                    0xFF222558,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 12,
                                                  ),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  minimumSize:
                                                      const Size.fromHeight(
                                                          44),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  final result =
                                                      await showDialog<
                                                          String>(
                                                    context: context,
                                                    builder: (context) =>
                                                        ToggleStatusDialog(
                                                      roomName:
                                                          room["name"] ??
                                                              "",
                                                      currentStatus:
                                                          currentStatus,
                                                    ),
                                                  );

                                                  if (result != null &&
                                                      result !=
                                                          currentStatus) {
                                                    setState(() {
                                                      room["status"] =
                                                          result;
                                                    });

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Room '${room["name"]}' is now $result",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: Icon(
                                                  isAvailable
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  isAvailable
                                                      ? "Disable"
                                                      : "Enable",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      isAvailable
                                                          ? const Color(
                                                              0xFFE53935)
                                                          : const Color(
                                                              0xFF43A047),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 12,
                                                  ),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  minimumSize:
                                                      const Size.fromHeight(
                                                          44),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          room["name"]!,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "(${room["type"]!})",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
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