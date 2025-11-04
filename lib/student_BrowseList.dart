import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_detail.dart';
import 'student-check_request_page.dart';
import 'student_history.dart';

class StudentBrowseList extends StatefulWidget {
  const StudentBrowseList({super.key});

  @override
  State<StudentBrowseList> createState() => _StudentBrowseListState();
}

class Room {
  final int id;
  final String name;
  final String type;
  final String status;
  final String image; // can be URL, asset path, or base64 data URI

  Room({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.image,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['room_id'] is int
          ? json['room_id']
          : int.tryParse('${json['room_id']}') ?? 0,
      name: json['room_name']?.toString() ?? 'Unknown',
      type: json['room_type']?.toString() ?? '',
      status: json['room_status']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}

class _StudentBrowseListState extends State<StudentBrowseList> {
  List<Room> rooms = [];
  bool _isLoading = true;
  String? _error;

  // Backend base URL. If you run on Android emulator use 10.0.2.2:3000
  static const String backendBase = 'http://localhost:3000';

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$backendBase/rooms');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        rooms = data
            .map((e) => Room.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = 'Server error: ${resp.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to load rooms: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRoomImage(Room room) {
    final img = room.image;
    if (img.isEmpty) {
      return Container(
        color: const Color(0xFFE5EBFC),
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 40,
        ),
      );
    }

    if (img.startsWith('http')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          color: const Color(0xFFE5EBFC),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    if (img.startsWith('data:image')) {
      try {
        final base64Str = img.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(
          color: const Color(0xFFE5EBFC),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    }

    // Fallback: treat as asset path
    return Image.asset(
      img,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        color: const Color(0xFFE5EBFC),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: const Color(0xFFDCE6F7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF3A7AFE), width: 3),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Are you sure to Logout ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrowsePage() {
    return Expanded(
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
                      hintText: 'Room',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchRooms,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: rooms.map((room) {
                      return Container(
                        width: 350,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 200,
                                    height: 110,
                                    child: _buildRoomImage(room),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RoomDetailScreen(
                                          roomName: room.name,
                                          roomType: room.type,
                                          imagePath: room.image,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF222558),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              room.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "(${room.type})",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
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
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildBrowsePage();
      case 1:
        return const Expanded(child: CheckRequestPage());
      case 2:
        return const Expanded(child: HistoryPage());
      default:
        return _buildBrowsePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showHeader = _selectedIndex == 0;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Browse List",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Check Requests",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hello, Oscar",
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
                          Text(
                            "Welcome to Room Reservation",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB9D6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: Color.fromARGB(255, 4, 57, 147),
                            ),
                            onPressed: _showLogoutDialog,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Logout",
                          style: TextStyle(
                            color: Color.fromARGB(255, 21, 97, 228),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            _buildBody(),
          ],
        ),
      ),
    );
  }
}
