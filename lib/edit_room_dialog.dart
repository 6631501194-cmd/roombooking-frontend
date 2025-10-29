import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    _imagePathController =
        TextEditingController(text: widget.room['image'].split('/').last);
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomTypeController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}-${pickedFile.path.split('/').last}';
      final String localImagePath = '${appDir.path}/$fileName';

      final File newImage = await File(pickedFile.path).copy(localImagePath);

      setState(() {
        _newImagePath = newImage.path;
        _imagePathController.text = newImage.path.split('/').last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
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

    final String finalImagePath = _newImagePath ?? widget.room['image'];

    final result = {
      'name': name,
      'type': type,
      'image': finalImagePath,
    };
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
                        Text("Saving image..."),
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _roomNameController,
                      label: "New Room name",
                      hint: "Room name",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _roomTypeController,
                      label: "Room Type",
                      hint: "Description",
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Image",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: TextField(
                        controller: _imagePathController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: "image_roomC.jpg",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: const Icon(Icons.file_upload_outlined),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}