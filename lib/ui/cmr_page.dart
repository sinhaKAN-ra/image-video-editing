import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';

class CMRpage extends StatefulWidget {
  final List<File> fileList;
  const CMRpage({super.key, required this.fileList});

  @override
  State<CMRpage> createState() => _CMRpageState();
}

class _CMRpageState extends State<CMRpage> {
  double x = 0;
  double y = 0;
  double z = 0;

  Matrix4 flipMatrix = Matrix4.rotationY(pi);
  bool flip = false; 

  Matrix4 rotateMatrix = Matrix4.rotationX(pi/2);
  bool isRotate = false; 

  int _rotateValue = 0;
  List<File> newFile = [];

  _rotateImage() async {
    setState(() {
      // x=0;y=0;z=0;
      isRotate = !isRotate;
      _rotateValue += 1;
    },);
    File file = await _capturePng();
    newFile.add(file);
  }

  _mirrorImage(){
    setState(() {
      // x=0;y=0;z=0;
      flip = !flip;
    },);
  }

  _cropImage(){}

  _resetImage(){}

  _undoImage(){
    debugPrint('${widget.fileList.length} : pics');
    debugPrint('${newFile.length} : pics');
    newFile.removeLast();
    setState(() {});
  }

  final GlobalKey _addImageKey = GlobalKey();
  bool isAdd = false;
  late File imagePath ;

  Future<File> _capturePng() async {
    // try {
      RenderRepaintBoundary boundary = _addImageKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      // File file = File(image.);

      // return image;

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      var pngBytes = byteData?.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes!);

      // final directory = await getApplicationDocumentsDirectory();
      // imagePath = await File('${directory.path}/karan_container_image.png').create();
      // await imagePath.writeAsBytes(pngBytes);

      File file = File(bs64);
      return file;

      // // saveImage(pngBytes);
      // setState(() {
      //   isAdd = true;
      // });
      // return pngBytes;
    // } catch (e) {
    //   print(e);
    // }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('CMR'),
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
      // extendBodyBehindAppBar: true,
      body: Column(
        children: [
        // RepaintBoundary(
        //   key: _addImageKey,
        //   child: Center(
        //     child: rotate ? Transform.rotate(
        //       angle: pi/2,
        //       child: Expanded(child: Image.file(widget.fileList.last)),
        //     ) :Transform(
        //       transform: 
              
        //        flip ? flipMatrix : Matrix4(
        //         1,0,0,0,
        //         0,1,0,0,
        //         0,0,1,0,
        //         0,0,0,1,
        //     )..rotateX(x)..rotateY(y)..rotateZ(z) ,
        //     alignment: FractionalOffset.center,
        //       child: (flip) ? Image.file(widget.fileList.last) : GestureDetector(
        //         onPanUpdate: ((details) {
        //           setState(() {
        //             y = y - details.delta.dx / 100;
        //             x = x + details.delta.dy / 100;
        //           });
        //         }),
        //         child: Expanded(
        //           child: Image.file(widget.fileList.last),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // Text('add a caption'),
        RepaintBoundary(
          key: _addImageKey,
          child: Center(
            child: isRotate ? RotatedBox(
            quarterTurns: _rotateValue,
            child: Image.file(widget.fileList.last),
            ) : Expanded(child: Image.file(widget.fileList.last))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () => _cropImage(), icon: const Icon(Icons.crop)),
            IconButton(
                onPressed: (() => _rotateImage()), icon: const Icon(Icons.rotate_90_degrees_ccw_rounded)),
            IconButton(
                onPressed: (() => _mirrorImage()), icon: const Icon(Icons.flip_rounded)),
            IconButton(
                onPressed: (() => _undoImage()), icon: const Icon(Icons.undo_outlined)),
          ],
        )
      ]),
    );
  }
}