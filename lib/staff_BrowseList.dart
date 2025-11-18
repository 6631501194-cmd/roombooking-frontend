import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'toggle_status_dialog.dart';
import 'add_room_dialog.dart';
import 'edit_room_dialog.dart'; 
import 'room_detail_screen.dart'; 

class StaffBrowselist extends StatefulWidget {
  const StaffBrowselist({super.key});

  @override
  State<StaffBrowselist> createState() => _StaffBrowselistState();
}

class _StaffBrowselistState extends State<StaffBrowselist> {
  List<dynamic> _allRooms = [];
  List<dynamic> _foundRooms = [];
  
  int _refreshKey = 0; 

  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();
  String? _token; 
  
  final TextEditingController _searchController = TextEditingController();

  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000'; 
  }

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final token = await _storage.read(key: 'jwt_token');
    if (mounted) {
      setState(() { _token = token; });
    }
    _fetchRooms(token);
  }

  Future<void> _fetchRooms(String? token) async {
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final uri = Uri.parse('$_baseUrl/api/rooms');
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (resp.statusCode == 200) {
        if (mounted) {
          final data = json.decode(resp.body);
          setState(() {
            _allRooms = data;
            _isLoading = false;
            _refreshKey = DateTime.now().millisecondsSinceEpoch; 

            if (_searchController.text.isEmpty) {
              _foundRooms = data;
            } else {
              _runFilter(_searchController.text);
            }
          });
        }
      } else {
        if(mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allRooms;
    } else {
      results = _allRooms
          .where((room) =>
              room["room_name"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              room["room_type"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundRooms = results;
    });
  }

  Future<void> _addRoom() async {
    final newRoomData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddRoomDialog(),
    );

    if (newRoomData != null) {
      setState(() => _isLoading = true);
      try {
        final uri = Uri.parse('$_baseUrl/api/rooms');
        var request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $_token';
        request.fields['room_name'] = newRoomData['name'];
        request.fields['room_type'] = newRoomData['type'];
        if (newRoomData['image'] != null) {
          request.files.add(await http.MultipartFile.fromPath('image', newRoomData['image']));
        }
        var response = await request.send();
        if (response.statusCode == 201) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Room added successfully!"), backgroundColor: Colors.green),
          );
          _fetchRooms(_token); 
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateRoom(int roomId, Map<String, dynamic> updatedData) async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$_baseUrl/api/rooms/$roomId');
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $_token';
      request.fields['room_name'] = updatedData['name'];
      request.fields['room_type'] = updatedData['type'];

      String imagePath = updatedData['image'];
      if (!imagePath.startsWith('http') && !imagePath.contains('/api/rooms') && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room updated successfully!"), backgroundColor: Colors.green),
        );
        _fetchRooms(_token); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: ${response.body}"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ✅ NEW FUNCTION: Change Room Status (Enable/Disable)
  Future<void> _changeRoomStatus(int roomId, String newDbStatus) async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$_baseUrl/api/rooms/$roomId/status');
      final resp = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: json.encode({'status': newDbStatus}),
      );

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text("Room is now ${newDbStatus == 'enable' ? 'Enabled' : 'Disabled'}"), 
             backgroundColor: newDbStatus == 'enable' ? Colors.green : Colors.orange
           ),
        );
        _fetchRooms(_token); // Refresh list to update buttons
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status update failed: ${resp.body}"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      "Browse List",
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addRoom,
                    icon: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Color(0xFF222558), size: 18),
                    ),
                    label: const Padding(
                      padding: EdgeInsets.only(left: 4.0, right: 6.0),
                      child: Text("Add Room", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222558),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFB9D6FF),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => _runFilter(value),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search room name',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _runFilter('');
                                    },
                                  )
                                : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _foundRooms.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No rooms found", style: TextStyle(fontSize: 16)),
                          )
                        : Center(
                          child: Column(
                            children: _foundRooms.map((room) {
                              final int roomId = room['room_id']; 
                              final String name = room['room_name'] ?? "Unknown";
                              final String type = room['room_type'] ?? "Unknown";
                              final String statusDb = room['room_status'] ?? 'enable';
                              
                              final String imageUrl = room['image_url'] != null 
                                  ? '$_baseUrl${room['image_url']}?v=$_refreshKey' 
                                  : '';

                              // UI Logic
                              final String currentStatus = statusDb == 'enable' ? "Available" : "Disabled";
                              final bool isAvailable = statusDb == 'enable';

                              return Container(
                                width: 360,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF4FF),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 200, height: 120, color: Colors.white,
                                            child: Image.network(
                                              imageUrl,
                                              headers: {'Authorization': 'Bearer $_token'},
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                color: Colors.grey[300],
                                                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        SizedBox(
                                          width: 120,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildStaffButton(
                                                icon: Icons.info_outline, label: "Detail", color: const Color(0xFF222558),
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => StaffRoomDetail(
                                                        roomId: roomId, 
                                                        roomName: name, 
                                                        roomType: type, 
                                                        imagePath: imageUrl, 
                                                        status: currentStatus,
                                                      ),
                                                  ));
                                                },
                                              ),
                                              const SizedBox(height: 8),
                                              
                                              _buildStaffButton(
                                                icon: Icons.edit, label: "Edit", color: const Color(0xFF222558),
                                                onPressed: () async {
                                                  final updatedData = await showDialog<Map<String, dynamic>>(
                                                    context: context,
                                                    builder: (context) => EditRoomDialog(
                                                      room: {
                                                        "name": name,
                                                        "type": type,
                                                        "image": imageUrl,
                                                        "status": currentStatus
                                                      },
                                                    ),
                                                  );
                                                  if (updatedData != null) {
                                                    _updateRoom(roomId, updatedData);
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 8),
                                              
                                              // ✅ ENABLE/DISABLE BUTTON (Connected to API)
                                              _buildStaffButton(
                                                icon: isAvailable ? Icons.visibility_off : Icons.visibility,
                                                label: isAvailable ? "Disable" : "Enable",
                                                color: isAvailable ? const Color(0xFFE53935) : const Color(0xFF43A047),
                                                onPressed: () async {
                                                  // 1. Open Confirmation Dialog
                                                  final newStatusUI = await showDialog<String>(
                                                    context: context,
                                                    builder: (context) => ToggleStatusDialog(
                                                      roomName: name,
                                                      currentStatus: currentStatus,
                                                    ),
                                                  );

                                                  // 2. If confirmed, call API
                                                  if (newStatusUI != null) {
                                                    // Convert UI status back to DB status format ('enable'/'disable')
                                                    final dbStatus = newStatusUI == "Available" ? "enable" : "disable";
                                                    _changeRoomStatus(roomId, dbStatus);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                                        const SizedBox(height: 4),
                                        Text("($type)", style: const TextStyle(fontSize: 20, color: Colors.black87)),
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

  Widget _buildStaffButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(44),
      ),
    );
  }
}