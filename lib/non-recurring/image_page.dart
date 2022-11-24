import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {

final GlobalKey _addImageKey = GlobalKey();
  bool isAdd = false;
  late File newImage;

  _capturePng() async {

    try {
      
      RenderRepaintBoundary boundary =
          _addImageKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      var pngBytes = byteData?.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes!);
      
      final directory = await getApplicationDocumentsDirectory();
      newImage = await File('${directory.path}/karan_container_image.png').create();
      await newImage.writeAsBytes(pngBytes);

      saveImage(pngBytes);
      setState(() {
        isAdd = true;
      });
      // return pngBytes;
    } catch (e) {
      print(e);
    }
  }
  
  saveImage(Uint8List bytes) async {
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = "karan_$time";
    await requestPermission(Permission.storage);
    await ImageGallerySaver.saveImage(bytes, name: name);
  }

Future<bool> requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}
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
      body: RepaintBoundary(
            key: _addImageKey,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Expanded(
                child: isAdd ? Image.file(newImage):Image.file(File(widget.imagePath)),
              ),
              const Text('data added', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _capturePng(),
      ),
    );
    
  }
}