import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'enum/album_type.dart';

class AlbumImagePicker extends StatefulWidget {
  /// maximum images allowed (default 1)
  final int maxImages;

  /// return all selected images
  final Function(List<AssetEntity>) onSelected;

  /// preSelected images
  final List<AssetEntity>? selected;

  /// The request type when requesting paths.
  ///
  ///  * [all] - Request paths that return images and videos.
  ///  * [image] - Request paths that only return images.
  ///  * [video] - Request paths that only return videos.
  final AlbumType type;

  /// image quality thumbnail
  final int? thumbnailQuality;

  /// On reach max
  final VoidCallback? onSelectedMax;

  const AlbumImagePicker(
      {Key? key,
      this.maxImages = 1,
      required this.onSelected,
      this.selected,
      this.type = AlbumType.all,
      this.thumbnailQuality,
      this.onSelectedMax})
      : super(key: key);

  @override
  _AlbumImagePickerState createState() => _AlbumImagePickerState();
}

class _AlbumImagePickerState extends State<AlbumImagePicker> {
  _getPermission() async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermisstionRequestOption(
            iosAccessLevel: IosAccessLevel.readWrite));
    if (result.isAuth) {
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList();
      });

      // if (provider.pathList.isEmpty) {
      //   _refreshPathList();
      // }
    } else {
      /// if result is fail, you can call `PhotoManager.openSetting();`
      /// to open android/ios application's setting to get permission
      PhotoManager.openSetting();
    }
  }

  _refreshPathList() {
    late RequestType type;
    switch (widget.type) {
      case AlbumType.all:
        type = RequestType.common;
        break;
      case AlbumType.image:
        type = RequestType.image;
        break;
      case AlbumType.video:
        type = RequestType.video;
        break;
    }
    PhotoManager.getAssetPathList(type: type).then((pathList) {
      /// don't delete setState
      setState(() {
        provider.resetPathList(pathList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
