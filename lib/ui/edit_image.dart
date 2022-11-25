import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_and_video_editing/ui/add_text_page.dart';
import 'package:image_and_video_editing/ui/cmr_page.dart';
import 'package:image_and_video_editing/ui/edit_widgets.dart';
import 'package:path_provider/path_provider.dart';


class EditImageScreen extends StatefulWidget {
  const EditImageScreen({Key? key, required this.fileList}) : super(key: key);
  final List<File> fileList;

  @override
  State<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  final GlobalKey _addImageKey = GlobalKey();
  bool isAdd = false;
  late File imagePath;
  double x = 0;
  double y = 0;
  double z = 0;

  _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _addImageKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      var pngBytes = byteData?.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes!);

      final directory = await getApplicationDocumentsDirectory();
      imagePath =
          await File('${directory.path}/karan_container_image.png').create();
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
      body: Column(children: [
        SizedBox(
          // height: MediaQuery.of(context).size.height/.9,
          height: 700,
          child: RepaintBoundary(
          key: _addImageKey,
          child: Center(
            child: Transform(
              transform: Matrix4(
                1,0,0,0,
                0,1,0,0,
                0,0,1,0,
                0,0,0,1,
            )..rotateX(x)..rotateY(y)..rotateZ(z) ,
            alignment: FractionalOffset.center,
              child: GestureDetector(
                onPanUpdate: ((details) {
                  setState(() {
                    y = y - details.delta.dx / 100;
                    x = x + details.delta.dy / 100;
                  });
                }),
                child: Expanded(
                  child: Image.file(widget.fileList.last),
                ),
              ),
            ),
          ),),
        ),
        Text('add a caption'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {
                  // fileList.add(File(file.path)) ;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CMRpage(
                        // selectedImage: file.path,
                        fileList: widget.fileList,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.crop_outlined)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTextPage(
                        // selectedImage: file.path,
                        fileList: widget.fileList,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.mode_edit_outline_outlined)),
            IconButton(
                onPressed: (() => _capturePng()),
                icon: const Icon(Icons.save_alt_rounded)),
            IconButton(onPressed: (() {
              setState(() {
                x=0;y=0;z=0;
              });
            }), icon: const Icon(Icons.restore_rounded)),
            IconButton(
                onPressed: (() {}),
                icon: const Icon(Icons.send_and_archive_rounded)),
          ],
        )
      ]),
    );
  }
}
