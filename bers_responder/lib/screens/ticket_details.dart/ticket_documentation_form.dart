import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketDocumentationForm extends StatefulWidget {
  const TicketDocumentationForm({super.key});

 static Future<List<String>> getCachedMediaPaths() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('cached_media_paths') ?? [];
}

  @override
  State<TicketDocumentationForm> createState() => _TicketDocumentationFormState();
}

class _TicketDocumentationFormState extends State<TicketDocumentationForm> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];

  @override
  void initState() {
    super.initState();
    _loadCachedMedia();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        final file = File(pickedFile.path);
        _mediaFiles.add(file);
      });
      _saveMediaCache();
    }
  }

  Future<void> _saveMediaCache() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> paths = _mediaFiles.map((file) => file.path).toList();
    await prefs.setStringList('cached_media_paths', paths);
  }

  Future<void> _loadCachedMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('cached_media_paths') ?? [];
    setState(() {
      _mediaFiles = paths.map((path) => File(path)).toList();
    });
  }

  void _removeMedia(File file) async {
    setState(() => _mediaFiles.remove(file));
    _saveMediaCache();
  }

  void _showMediaPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_camera_back),
                title: const Text("Record Video"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, isVideo: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _showMediaPickerSheet,
            icon: const Icon(Icons.upload),
            label: const Text("Upload Media"),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mediaFiles.map((file) {
            final isVideo = file.path.endsWith('.mp4');
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                    image: isVideo
                        ? null
                        : DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: isVideo
                      ? const Center(child: Icon(Icons.videocam, size: 40, color: Colors.white))
                      : null,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeMedia(file),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
