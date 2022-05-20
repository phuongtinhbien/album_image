Album Image is based in [photo_manager](https://pub.dev/packages/photo_manager) package and has the same concept as image_picker but with a more attractive interface to choose an image or video from the device gallery, whether it is Android or iOS.

## Features

[✔] pick image

[✔] pick video

[✔] pick multi image / video

[✔] cover thumbnail (preview first image on gallery)

[❌] take picture or video from camera

## Installation
1) This package has only tested in android, add `album_image: 0.0.1` in your `pubspec.yaml`
2) import `album_image`
```dart
import 'package:album_image/album_image.dart';
```

## Getting started
#### Android
add uses-permission `AndroidMAnifest.xml` file
 ```xml
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
 ```
#### ios
add this config in your `info.plist` file
 ```xml
     <key>NSPhotoLibraryUsageDescription</key>
     <string>Privacy - Photo Library Usage Description</string>
     <key>NSMotionUsageDescription</key>
     <string>Motion usage description</string>
     <key>NSPhotoLibraryAddUsageDescription</key>
     <string>NSPhotoLibraryAddUsageDescription</string>
 ```

## How to use
Create a `GalleryMediaPicker()` widget:
```dart
AlbumImagePicker(
onSelected: (items) {},
iconSelectionBuilder: (_, selected, index) {
if (selected) {
return CircleAvatar(
child: Text(
'${index + 1}',
style: const TextStyle(fontSize: 10, height: 1.4),
),
radius: 10,
);
}
return Container();
},
crossAxisCount: 3,
maxSelection: 4,
onSelectedMax: () {
print('Reach max');
},
albumBackGroundColor: Colors.white,
appBarHeight: 45,
itemBackgroundColor: Colors.grey[100]!,
appBarColor: Colors.white,
albumTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
albumSubTextStyle:
const TextStyle(color: Colors.grey, fontSize: 10),
type: AlbumType.image,
closeWidget: const BackButton(
color: Colors.black,
),
thumbnailQuality: thumbnailQuality * 3,
);
```

## Example
```dart
import 'package:album_image/album_image.dart';
import 'package:flutter/material.dart';

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
          final thumbnailQuality = MediaQuery.of(context).size.width ~/ 3;
          return AlbumImagePicker(
            onSelected: (items) {},
            iconSelectionBuilder: (_, selected, index) {
              if (selected) {
                return CircleAvatar(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 10, height: 1.4),
                  ),
                  radius: 10,
                );
              }
              return Container();
            },
            crossAxisCount: 3,
            maxSelection: 4,
            onSelectedMax: () {
              print('Reach max');
            },
            albumBackGroundColor: Colors.white,
            appBarHeight: 45,
            itemBackgroundColor: Colors.grey[100]!,
            appBarColor: Colors.white,
            albumTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
            albumSubTextStyle:
            const TextStyle(color: Colors.grey, fontSize: 10),
            type: AlbumType.image,
            closeWidget: const BackButton(
              color: Colors.black,
            ),
            thumbnailQuality: thumbnailQuality * 3,
          );
        }),
      ),
    );
  }
}


```