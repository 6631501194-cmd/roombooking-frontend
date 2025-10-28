import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // == รูป blob มุมบนซ้าย ==
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/first.jpg',
              width: 400, // ปรับขนาดได้ตามต้องการ
              fit: BoxFit.cover,
            ),
          ),

          // == เนื้อหาหลัก (กล่องล่าง) ==
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFD5E3FC), // สีพื้นตามที่ระบุ
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
                children: [
                  const Text(
                    'Welcome to Library\nRoom Reservation\nSystem',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.left, // ชิดซ้าย
                  ),
                  const SizedBox(height: 40),
                  buildButton('Sign in'),
                  const SizedBox(height: 20),
                  buildButton('Sign up'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF262759),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {},
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
