import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  final void Function(File picekdImage) onPickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  XFile? profileImage;

  void _pickImage() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          alignment: Alignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 15.0),
          title: const Text("Where would you like to take the image from?"),
          titleTextStyle: TextStyle(
              fontSize: 24.0, color: Theme.of(context).colorScheme.primary),
          actions: [
            TextButton(
              onPressed: () async {
                profileImage = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                  maxWidth: 150,
                );
                if (profileImage == null) {
                  Navigator.of(context).pop();
                  return;
                }
                setState(() {
                  _pickedImageFile = File(profileImage!.path);
                });
                widget.onPickedImage(_pickedImageFile!);
                Navigator.of(context).pop();
              },
              child: const Text("Gallery"),
            ),
            const SizedBox(
              width: 18,
            ),
            TextButton(
              onPressed: () async {
                profileImage = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                  maxWidth: 150,
                );
                if (profileImage == null) {
                  Navigator.of(context).pop();
                  return;
                }
                setState(() {
                  _pickedImageFile = File(profileImage!.path);
                });
                widget.onPickedImage(_pickedImageFile!);
                Navigator.of(context).pop();
              },
              child: const Text("Camera"),
            ),
          ],
        );
      },
    );

    // final profileImage = await ImagePicker().pickImage(
    //   source: ImageSource.gallery,
    //   imageQuality: 50,
    //   maxWidth: 150,
    // );
    // if (profileImage == null) {
    //   return;
    // }

    // setState(() {
    //   _pickedImageFile = File(profileImage!.path);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.grey,
                foregroundImage: _pickedImageFile != null
                    ? FileImage(_pickedImageFile!)
                    : null,
              ),
              _pickedImageFile == null
                  ? const Positioned(
                      top: 0,
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 110,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _pickImage();
            });
          },
          icon: Icon(Icons.image_rounded,
              color: Theme.of(context).colorScheme.onSecondary),
          label: Text(
            "Add Image",
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
      ],
    );
  }
}
