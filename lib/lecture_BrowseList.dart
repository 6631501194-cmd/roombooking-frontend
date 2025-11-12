import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/lecture_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 1. ADDED ROOM MODEL
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
      status: json['room_status']?.toString() ?? 'disable',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

// 2. CONVERTED TO STATEFULWIDGET
class LectureBrowseList extends StatefulWidget {
  const LectureBrowseList({super.key});

  @override
  State<LectureBrowseList> createState() => _LectureBrowseListState();
}

class _LectureBrowseListState extends State<LectureBrowseList> {
  // 3. ADDED STATE VARIABLES
  List<Room> rooms = []; // Master list
  List<Room> filteredRooms = []; // Display list
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  String? _token; // To hold the token for image requests
  final _storage = const FlutterSecureStorage();

  // 4. ADDED URL GETTER
  String get _backendBase {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000'; // For iOS Simulator
  }

  @override
  void initState() {
    super.initState();
    // 5. Load token first, then fetch rooms
    _loadTokenAndFetchRooms();
    _searchController.addListener(() {
      setState(() {}); // For the 'clear' button
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // 6. NEW FUNCTION TO LOAD TOKEN
  Future<void> _loadTokenAndFetchRooms() async {
    final token = await _storage.read(key: 'jwt_token');
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
    _fetchRooms(token);
  }


  // 7. UPDATED FETCH FUNCTION TO USE TOKEN
  Future<void> _fetchRooms(String? token) async {
    if (token == null) {
      if (mounted) {
        setState(() {
          _error = "Error: Not logged in. Token is missing.";
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
        if (mounted) {
          setState(() {
            rooms = data
                .map((e) => Room.fromJson(e as Map<String, dynamic>))
                .toList();
            filteredRooms = List.from(rooms);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = resp.body.isNotEmpty
                ? resp.body
                : 'Server error: ${resp.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load rooms: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 8. ADDED FILTER FUNCTION
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

  // 9. ADDED IMAGE HELPER (NOW SENDS TOKEN)
  Widget _roomImage(Room room) {
    final img = room.imageUrl;
    final src = img.startsWith('http') ? img : '$_backendBase$img';

    // Show a loader if token hasn't been read yet
    if (_token == null) {
      return Container(
        width: 200,
        height: 120,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Image.network(
      src,
      headers: {'Authorization': 'Bearer $_token'}, // Pass token here
      width: 200,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 120,
          color: Colors.grey[300],
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
          height: 120,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        offset: const Offset(2, 4),
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
                        // 10. WIRED UP SEARCH BAR
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
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
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
                        
                        // 11. ADDED DYNAMIC CONTENT BUILDER
                        _buildRoomList(),
                        
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

  // 12. WIDGET TO HANDLE LOADING/ERROR/EMPTY/DATA STATES
  Widget _buildRoomList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (filteredRooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No rooms found matching your search.',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: filteredRooms.map((room) {
        final String fullImageUrl = room.imageUrl.startsWith('http')
            ? room.imageUrl
            : '$_backendBase${room.imageUrl}';
        
        final String displayStatus = room.status.toLowerCase() == 'enable'
            ? 'Available'
            : 'Disabled';

        return Container(
          width: 360,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EBFC),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _roomImage(room),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LectureDetails(
                            roomId: room.id, // ✅ PASS THE ID
                            roomName: room.name,
                            roomType: room.type,
                            imagePath: fullImageUrl, // Pass the full URL
                            status: displayStatus, // Pass 'Available' or 'Disabled'
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "(${room.type})",
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
    );
  }
}