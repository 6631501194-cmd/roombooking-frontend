import 'package:flutter/material.dart';

class ToggleStatusDialog extends StatelessWidget {
  final String roomName;
  final String currentStatus;

  const ToggleStatusDialog({
    super.key,
    required this.roomName,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentlyAvailable = currentStatus == 'Available';
    final String actionText = isCurrentlyAvailable ? "Disable" : "Enable";
    final String newStatus = isCurrentlyAvailable ? "Disabled" : "Available";

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
               
                Expanded(
                  child: Text(
                    "$actionText Room",
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
               
                // IconButton(
                //   icon: const Icon(Icons.close),
                //   onPressed: () => Navigator.pop(context, null),
                // ),
              ],
            ),
            Text(
              "Room name : $roomName",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 24),
            Text(
              "Are you sure you want to\n$actionText this Room?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, newStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentlyAvailable
                        ? const Color(0xFFE53935)
                        : const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: Text(actionText),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}