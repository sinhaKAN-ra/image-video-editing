// import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_and_video_editing/camera_page.dart';
// import 'package:image_picker/image_picker.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraPage(),

    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen ({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
   
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }
  @override
  void dispose() {
    
    // super.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            return CameraPreview(_controller);
          }else{
            return const Center(child: CircularProgressIndicator(),);
          }
        } 
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          try{
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if(!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              )
            );
          }catch(e){
            print(e);
          }
        },
        child: const Icon(Icons.camera_rounded),
      ),
    );
  }
}

