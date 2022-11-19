import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Preview'),
      elevation: 0,
      backgroundColor: Colors.black26,
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            print('do something with the file');
          },
        )
      ],
    ),
      extendBodyBehindAppBar: true,
      body: Image.file(File(imagePath)),
    );
    
  }
}