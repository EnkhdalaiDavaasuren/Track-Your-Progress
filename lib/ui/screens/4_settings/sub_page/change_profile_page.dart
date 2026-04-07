import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/services/auth_service.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart'; // RELEASE FIX: Required for kIsWeb check

class ChangeProfilePage extends StatefulWidget {
  const ChangeProfilePage({super.key});

  @override
  State<ChangeProfilePage> createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, 
        maxHeight: 512,
      );

      if (pickedFile != null) {
        // On Web, pickedFile.path is a Blob URL, not a file path.
        // dart:io.File(path) will crash on Web.
        if (!kIsWeb) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        } else {
          // If you ever use Web, you'd handle it differently (e.g. Image.network)
          // For now, we focus on preventing the crash.
          debugPrint("Web image picking is not handled via dart:io");
        }
      }
    } catch (e) {
      debugPrint("Image Pick Error: $e");
    }
  }

  // Helper to determine what image to show safely
  ImageProvider? _getProfileImage() {
    // 1. If we just picked a file (Mobile only)
    if (!kIsWeb && _selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    
    // 2. Check Firebase User's photoURL
    final String? photoUrl = user?.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // If it's a network link (e.g. from Google Login)
      if (photoUrl.startsWith('http')) {
        return NetworkImage(photoUrl);
      } 
      
      // If it's a local path (Mobile only)
      if (!kIsWeb) {
        try {
          File localFile = File(photoUrl);
          if (localFile.existsSync()) {
            return FileImage(localFile);
          }
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getProfileImage(),
                    child: (_getProfileImage() == null)
                        ? Icon(Icons.add_a_photo, size: 40, color: borderColor)
                        : null,
                  ),
                  Positioned(
                    right: 0, bottom: 0,
                    child: CircleAvatar(
                      radius: 18, 
                      backgroundColor: borderColor,
                      child: Icon(Icons.edit, size: 18, color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Icons are auto-resized to 512x512", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              enabled: !_isSaving,
              decoration: InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: borderColor)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: borderColor,
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: _isSaving ? null : () async {
                  setState(() => _isSaving = true);
                  
                  try {
                    // Update Name
                    await AuthService().updateProfileName(_nameController.text.trim());
                    
                    // Update Image (Only on Mobile)
                    if (!kIsWeb && _selectedImage != null) {
                      await AuthService().updateProfileImage(_selectedImage!.path);
                    }
                    
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    debugPrint("Save Profile Error: $e");
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to update profile."))
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}