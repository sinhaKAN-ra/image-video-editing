import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


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
