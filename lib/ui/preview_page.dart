import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_image.dart';

class HomeScreen extends StatefulWidget {
   const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
List<File> listOfEdits = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          icon: const Icon(
            Icons.camera,
          ),
          onPressed: () async {
            XFile? file = await ImagePicker().pickImage(
              source: ImageSource.camera,
            );
            if(file != null){
            listOfEdits.add(File(file.path)) ;
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditImageScreen(
                    // selectedImage: file.path,
                    fileList: listOfEdits,
                  ),
                ),
              );
            }
            // if() {
              
            // }
          },
        ),
      ),
    );
  }
}
