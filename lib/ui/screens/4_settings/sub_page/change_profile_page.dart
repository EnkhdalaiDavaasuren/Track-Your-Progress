import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/services/auth_service.dart'; // Relative import is safer
import 'dart:io'; 

class ChangeProfilePage extends StatefulWidget {
  const ChangeProfilePage({super.key});

  @override
  State<ChangeProfilePage> createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, 
      maxHeight: 512,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60, // Larger for the edit screen
                    backgroundColor: Colors.grey.shade200,
                    // --- THE FIX: PREVIEW LOGIC ---
                    backgroundImage: _selectedImage != null 
                        ? FileImage(_selectedImage!) // 1. Show the photo just picked
                        : (user?.photoURL != null && File(user!.photoURL!).existsSync())
                            ? FileImage(File(user!.photoURL!)) // 2. Show the previously saved photo
                            : null, // 3. Show nothing (fallback to child icon)
                    child: (_selectedImage == null && 
                           (user?.photoURL == null || !File(user!.photoURL!).existsSync()))
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
                onPressed: () async {
                  // 1. Update the Name
                  await AuthService().updateProfileName(_nameController.text);
                  
                  // 2. Update the Image Path if a new one was selected
                  if (_selectedImage != null) {
                    await AuthService().updateProfileImage(_selectedImage!.path);
                  }
                  
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}