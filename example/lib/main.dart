import 'package:album_image/album_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          final thumbnailQuality = MediaQuery.of(context).size.width / 3;
          return AlbumImagePicker(
            onSelected: (items) {},
            iconSelectionBuilder: (_, selected) {
              return Icon(
                Icons.check_circle,
                color: selected ? Colors.greenAccent : Colors.transparent,
              );
            },
            maxSelection: 4,
            onSelectedMax: (){
              print ('Reach max');
            },
            itemBackgroundColor: Colors.grey[100]!,
            thumbnailBoxFix: BoxFit.contain,
            type: AlbumType.image,
            selectedItemBackgroundColor: Colors.amberAccent,
            // appBarColor: Colors.white,
            thumbnailQuality: thumbnailQuality.toInt() * 3,
          );
        }),
      ),
    );
  }
}
