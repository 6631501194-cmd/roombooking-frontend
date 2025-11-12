import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 1. IMPORT

import 'student_detail.dart';
import 'student-check_request_page.dart';
import 'student_history.dart';

class StudentBrowseList extends StatefulWidget {
  final int? currentUserId;
  final String? username;

  const StudentBrowseList({
    super.key, 
    this.currentUserId,
    this.username,
  });

  @override
  State<StudentBrowseList> createState() => _StudentBrowseListState();
}

class Room {
  final int id;
  final String name;
  final String type;
  final String status;
  final String imageUrl;

  Room({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.imageUrl,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['room_id'] is int
          ? json['room_id'] as int
          : int.tryParse('${json['room_id']}') ?? 0,
      name: json['room_name']?.toString() ?? 'Unknown',
      type: json['room_type']?.toString() ?? '',
      status: json['room_status']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

class _StudentBrowseListState extends State<StudentBrowseList> {
  // 2. ✅ ADDED STORAGE AND TOKEN STATE
  final _storage = const FlutterSecureStorage();
  String? _token;
  
  List<Room> rooms = [];
  List<Room> filteredRooms = [];
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();


  String get _backendBase {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    // 3. ✅ MODIFIED: Load token first, then fetch
    _loadTokenAndFetchRooms();
    _searchController.addListener(() {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // 4. ✅ ADDED: New function to load token
  Future<void> _loadTokenAndFetchRooms() async {
    final token = await _storage.read(key: 'jwt_token');
    if (mounted) {
      setState(() { _token = token; });
    }
    _fetchRooms(token);
  }

  // 5. ✅ MODIFIED: Function now accepts and sends token
  Future<void> _fetchRooms(String? token) async {
    if (token == null) {
      if (mounted) {
        setState(() {
          _error = "Error: Not logged in. Please restart the app.";
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_backendBase/api/rooms');
      final resp = await http.get(
        uri,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' 
        },
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        if(mounted) {
          setState(() {
            rooms = data
                .map((e) => Room.fromJson(e as Map<String, dynamic>))
                .toList();
            filteredRooms = List.from(rooms);
          });
        }
      } else {
        _error = resp.body.isNotEmpty
            ? "Error: ${resp.body}"
            : 'Server error: ${resp.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to load rooms: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterRooms(String query) {
    final String lowerQuery = query.toLowerCase();
    setState(() {
      if (lowerQuery.isEmpty) {
        filteredRooms = List.from(rooms);
      } else {
        filteredRooms = rooms.where((room) {
          final String roomNameLower = room.name.toLowerCase();
          final String roomTypeLower = room.type.toLowerCase();
          return roomNameLower.contains(lowerQuery) ||
                 roomTypeLower.contains(lowerQuery);
        }).toList();
      }
    });
  }

  // 6. ✅ MODIFIED: Image widget now sends token
  Widget _roomImage(Room room) {
    final img = room.imageUrl;
    final src = img.startsWith('http') ? img : '$_backendBase$img';

    if (_token == null) { // Show loader if token isn't ready
      return Container(
        width: 200, height: 110, color: const Color(0xFFE5EBFC),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Image.network(
      src,
      headers: {'Authorization': 'Bearer $_token'}, // <-- Add header
      width: 200,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 110,
          color: const Color(0xFFE5EBFC),
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 40,
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: 200,
          height: 110,
          color: const Color(0xFFE5EBFC),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  // 7. ✅ MODIFIED: Logout now deletes the token
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
                      onTap: () async { // <-- Make async
                        await _storage.delete(key: 'jwt_token'); // <-- Add delete
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
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
                  child: TextField( 
                    controller: _searchController,
                    onChanged: _filterRooms,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by room name or type...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterRooms('');
                              },
                            )
                          : null,
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
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _loadTokenAndFetchRooms(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (filteredRooms.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No rooms found matching your search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                else
                  Column(
                    children: filteredRooms.map((room) {
                      final fullImageUrl = room.imageUrl.startsWith('http')
                          ? room.imageUrl
                          : '$_backendBase${room.imageUrl}';

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
                                  child: _roomImage(room),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (widget.currentUserId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Error: You must be logged in to view details.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return; 
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RoomDetailScreen(
                                          roomId: room.id,
                                          userId: widget.currentUserId!,
                                          roomName: room.name,
                                          roomType: room.type,
                                          imageUrl: fullImageUrl,
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
    final int safeUserId = widget.currentUserId ?? 0;
    
    switch (_selectedIndex) {
      case 0:
        return _buildBrowsePage();
      case 1:
        return Expanded(child: CheckRequestPage(userId: safeUserId));
      case 2:
        return Expanded(child: HistoryPage(userId: safeUserId));
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
                        children: [
                          Text(
                            "Hello, ${widget.username ?? 'User'}",
                            style: const TextStyle( 
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
                          const Text( 
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