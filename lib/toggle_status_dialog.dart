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
    // Check if the room is currently available
    final bool isCurrentlyAvailable = currentStatus == 'Available';

    // If it's available, new status should become "Disabled"
    // If it's disabled, new status should become "Available"
    final String newStatus = isCurrentlyAvailable ? "Disabled" : "Available";

    // Popup message depends on current status
    final String message = isCurrentlyAvailable
        ? "Are you sure to disable this room?"
        : "Are you sure to enable this room?";

    // Button text also depends on current status
    final String confirmText = isCurrentlyAvailable ? "Disable" : "Enable";

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Confirm button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, newStatus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentlyAvailable
                        ? const Color(0xFFE53935) // Red for disable
                        : const Color(0xFF43A047), // Green for enable
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: Text(confirmText),
                ),
                // Cancel button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
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
