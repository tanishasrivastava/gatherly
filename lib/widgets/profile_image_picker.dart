import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final Function(File) onImagePicked;

  const ProfileImagePicker({Key? key, required this.onImagePicked}) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      widget.onImagePicked(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.deepPurple.shade100,
          backgroundImage:
          _pickedImage != null ? FileImage(_pickedImage!) : AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        SizedBox(height: 10),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.camera_alt_rounded, color: Colors.deepPurple),
          label: Text(
            'Choose Profile Pic',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
