// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_and_video_editing/non-recurring/image_page.dart';
import 'package:image_and_video_editing/non-recurring/video_replay.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecording = false;
  bool isFront = false;
  bool isFlash = false;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);

    if (isFront) {
      _cameraController = CameraController(front, ResolutionPreset.max);
    } else {
      _cameraController = CameraController(backCamera, ResolutionPreset.max);
    }
    // if (isFlash) {
    //     _cameraController.setFlashMode(FlashMode.torch);
    //   }
    //   else{
    //     _cameraController.setFlashMode(FlashMode.torch);
    //     }
    //  _cameraController.setFlashMode(FlashMode.always);
     _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {
      _isLoading = false;
    });
    
    // _rotateCamera();
  }

  @override
  void initState() {
    super.initState();
    // _rotateCamera();
        _initCamera();

  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      // final route = MaterialPageRoute(
      // fullscreenDialog: true,
      // builder: (_) => VideoPage(filePath: file.path),
      // );
      // ignore: use_build_context_synchronously
      // Navigator.push(context, route);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(
          filePath: file.path,
        ),
      ));
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();

      setState(() => _isRecording = true);
    }
  }

  _cameraFlash() {
    // _cameraController.setFlashMode(FlashMode.always);
    setState(() {
      isFlash = !isFlash;
    });
    _initCamera();

  }

  _rotateCamera() {
    setState(() {
      isFront = !isFront;
    });
    _initCamera();
  }

  _recordImage() async {
    await _initializeControllerFuture;
    final image = await _cameraController.takePicture();
    if (!mounted) return;

    await Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => DisplayPictureScreen(
        imagePath: image.path,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Material(
       
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter, children: [
            FutureBuilder(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_cameraController);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            IconButton(onPressed: (() => _cameraFlash()), icon: const Icon(Icons.flash_off_sharp)),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(onPressed: (() => _cameraFlash()), icon: const Icon(Icons.flash_off_sharp, color: Colors.white,)),
                  GestureDetector(
                    onLongPress: (() => _recordVideo()),
                    onTap: _isRecording
                        ? (() => _recordVideo())
                        : (() => _recordImage()),
                    child: (_isRecording
                        ? Row(
                            children: const [
                              Icon(
                                Icons.pause,
                                color: Colors.red,
                              ),
                              Icon(
                                Icons.stop,
                                color: Colors.red,
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.camera_rounded,
                            color: Colors.white,
                          )),
                  ),
                  IconButton(onPressed: (() => _rotateCamera()), icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white,)),
                ],
              ),
            ),
          ]),
        ),
      );
    }
  }
}

// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;
//   const DisplayPictureScreen({super.key, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('display pic')),
//       extendBodyBehindAppBar: true,
//       body: Image.file(File(imagePath)),
//     );
//   }
// }
