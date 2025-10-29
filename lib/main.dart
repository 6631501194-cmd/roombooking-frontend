import 'package:flutter/material.dart';
import 'edit_room_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edit Room Dialog Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EditRoomTestPage(),
    );
  }
}

class EditRoomTestPage extends StatefulWidget {
  const EditRoomTestPage({super.key});

  @override
  State<EditRoomTestPage> createState() => _EditRoomTestPageState();
}

class _EditRoomTestPageState extends State<EditRoomTestPage> {
  final Map<String, dynamic> testRoom = {
    "name": "Room 201",
    "type": "Meeting Room",
    "image": "assets/images/studyRoom1.png",
  };

  void _openDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditRoomDialog(room: testRoom),
    );

    if (result != null) {
      debugPrint("Updated Room: $result");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Edit Room Dialog"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          child: const Text("Open Edit Room Dialog"),
        ),
      ),
    );
  }
}
