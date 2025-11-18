import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // ✅ USE FILE PICKER
import 'package:path_provider/path_provider.dart';

class EditRoomDialog extends StatefulWidget {
  final Map<String, dynamic> room;

  const EditRoomDialog({super.key, required this.room});

  @override
  State<EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  late TextEditingController _roomNameController;
  late TextEditingController _roomTypeController;
  late TextEditingController _imagePathController;
  String? _newImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(text: widget.room['name']);
    _roomTypeController = TextEditingController(text: widget.room['type']);
    
    // Just show the filename, not the full ugly URL/Path
    String currentImage = widget.room['image'] ?? '';
    if (currentImage.isNotEmpty) {
      currentImage = currentImage.split('/').last;
    }
    _imagePathController = TextEditingController(text: currentImage);
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomTypeController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  // ✅ PICK IMAGE FROM FILE SYSTEM (Mac/Simulator compatible)
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result == null || result.files.single.path == null) return;

      setState(() {
        _isLoading = true;
      });

      // Copy file to app directory so we can access it later
      final File originalFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}-${result.files.single.name}';
      final String localImagePath = '${appDir.path}/$fileName';

      final File newImage = await originalFile.copy(localImagePath);

      setState(() {
        _newImagePath = newImage.path;
        _imagePathController.text = result.files.single.name;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _onSave() {
    final name = _roomNameController.text;
    final type = _roomTypeController.text;

    if (name.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Return the new path if selected, otherwise return the old URL
    final String finalImagePath = _newImagePath ?? widget.room['image'];

    final result = {'name': name, 'type': type, 'image': finalImagePath};
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Processing image..."),
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Room",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _roomNameController,
                      label: "Room Name",
                      hint: "Enter room name",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _roomTypeController,
                      label: "Room Type",
                      hint: "Enter room type",
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Image",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // ✅ TAP INPUT TO PICK FILE
                    GestureDetector(
                      onTap: _pickImage, 
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _imagePathController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Tap to select image",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: const Icon(Icons.file_upload_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          ),
                          child: const Text("Save"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}