import 'package:flutter/material.dart';
import 'toggle_status_dialog.dart'; // make sure this file name matches exactly

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toggle Status Dialog Demo',
      home: ToggleStatusTestPage(),
    );
  }
}

class ToggleStatusTestPage extends StatefulWidget {
  const ToggleStatusTestPage({super.key});

  @override
  State<ToggleStatusTestPage> createState() => _ToggleStatusTestPageState();
}

class _ToggleStatusTestPageState extends State<ToggleStatusTestPage> {
  String roomStatus = "Available"; // initial status

  Future<void> _openToggleDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ToggleStatusDialog(
        roomName: "Room 305",
        currentStatus: roomStatus,
      ),
    );

    if (result != null && result != roomStatus) {
      setState(() {
        roomStatus = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room status changed to $roomStatus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Toggle Status Dialog"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Current Status: $roomStatus",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _openToggleDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Open Toggle Dialog"),
            ),
          ],
        ),
      ),
    );
  }
}
