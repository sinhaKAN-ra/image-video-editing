import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_and_video_editing/recurring/capture_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PreviewScreen extends StatefulWidget {
  final File imageFile;
  final List<File> fileList;

  const PreviewScreen({super.key, 
    required this.imageFile,
    required this.fileList,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final GlobalKey _addImageKey = GlobalKey();
  bool isAdd = false;
  late File imagePath;

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
      imagePath = await File('${directory.path}/karan_container_image.png').create();
      await imagePath.writeAsBytes(pngBytes);

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
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RepaintBoundary(
            key: _addImageKey,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Expanded(
                child: isAdd ? Image.file(imagePath):Image.file(widget.imageFile),
              ),
              const Text('data'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CapturesScreen(
                      imageFileList: widget.fileList,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('Go to all captures'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () => _capturePng(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('add text'),
            ),
          ),
        ],
      ),
    );
  }
}