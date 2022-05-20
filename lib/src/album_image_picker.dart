import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:album_image/src/widgets/app_bar_album.dart';
import 'package:album_image/src/widgets/gallery_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'enum/album_type.dart';

typedef IconWidgetBuilder = Widget Function(
    BuildContext context, bool selected);

class AlbumImagePicker extends StatefulWidget {
  /// maximum images allowed (default 1)
  final int maxSelection;

  /// return all selected images
  final Function(List<AssetEntity>) onSelected;

  /// preSelected images
  final List<AssetEntity>? selected;

  /// The album type when requesting paths.
  ///
  ///  * [all] - Request paths that return images and videos.
  ///  * [image] - Request paths that only return images.
  ///  * [video] - Request paths that only return videos.
  final AlbumType type;

  /// image quality thumbnail
  final int thumbnailQuality;

  /// On reach max
  final VoidCallback? onSelectedMax;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// gridview crossAxisCount
  final int crossAxisCount;

  /// gallery gridview aspect ratio
  final double childAspectRatio;

  /// gridView Padding
  final EdgeInsets gridPadding;

  /// gridView physics
  final ScrollPhysics? scrollPhysics;

  /// gridView controller
  final ScrollController? scrollController;

  /// gridView background color
  final Color listBackgroundColor;

  /// grid image backGround color
  final Color itemBackgroundColor;

  /// grid selected image backGround color
  final Color selectedItemBackgroundColor;

  /// dropdown appbar color
  final Color appBarColor;

  ///Icon widget builder
  final IconWidgetBuilder? iconSelectionBuilder;

  ///Close widget
  final Widget? closeWidget;

  ///appBar actions widgets
  final List<Widget>? appBarActionWidgets;

  const AlbumImagePicker(
      {Key? key,
      this.maxSelection = 1,
      required this.onSelected,
      this.selected,
      this.type = AlbumType.all,
      this.thumbnailBoxFix = BoxFit.cover,
      this.crossAxisCount = 3,
      this.childAspectRatio = 1.0,
      this.thumbnailQuality = 200,
      this.gridPadding = EdgeInsets.zero,
      this.listBackgroundColor = Colors.white,
      this.itemBackgroundColor = Colors.grey,
      this.selectedItemBackgroundColor = Colors.grey,
      this.appBarColor = Colors.redAccent,
      this.appBarActionWidgets,
      this.closeWidget,
      this.iconSelectionBuilder,
      this.scrollPhysics,
      this.scrollController,
      this.onSelectedMax})
      : super(key: key);

  @override
  _AlbumImagePickerState createState() => _AlbumImagePickerState();
}

class _AlbumImagePickerState extends State<AlbumImagePicker> {
  /// create object of PickerDataProvider
  late PickerDataProvider provider;

  @override
  void initState() {
    _initProvider();
    _getPermission();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AlbumImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.selected != widget.selected) {
    //   provider.picked
    // }
    if (oldWidget.maxSelection != widget.maxSelection) {
      provider.max = widget.maxSelection;
    }
    if (oldWidget.type != widget.type) {
      _refreshPathList();
    }
  }

  void _initProvider() {
    provider = PickerDataProvider(
        picked: widget.selected ?? [], maxSelectionCount: widget.maxSelection);
    provider.onPickMax.addListener(onPickMax);
  }

  void _getPermission() async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermisstionRequestOption(
            iosAccessLevel: IosAccessLevel.readWrite));
    if (result.isAuth) {
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList();
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList();
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  void _refreshPathList() {
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

  void onPickMax() {
    widget.onSelectedMax?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// album drop down
        AppBarAlbum(
          provider: provider,
          appBarIconColor: const Color(0xFFB2B2B2),
          albumDividerColor: const Color(0xFF484848),
          albumBackGroundColor: const Color(0xFF333333),
          appBarColor: widget.appBarColor,
          appBarLeadingWidget: widget.closeWidget ?? _defaultCloseWidget(),
          appBarActionWidgets: widget.appBarActionWidgets,
        ),

        /// grid view
        Expanded(
          child: ValueListenableBuilder<AssetPathEntity?>(
            valueListenable: provider.currentPathNotifier,
            builder: (context, currentPath, child) => currentPath != null
                ? GalleryGridView(
                    path: currentPath,
                    thumbnailQuality: widget.thumbnailQuality,
                    provider: provider,
                    padding: widget.gridPadding,
                    loadWhenScrolling: true,
                    childAspectRatio: widget.childAspectRatio,
                    crossAxisCount: widget.crossAxisCount,
                    gridViewBackgroundColor: widget.listBackgroundColor,
                    gridViewController: widget.scrollController,
                    gridViewPhysics: widget.scrollPhysics,
                    imageBackgroundColor: widget.itemBackgroundColor,
                    selectedBackgroundColor: widget.selectedItemBackgroundColor,
                    iconSelectionBuilder: widget.iconSelectionBuilder,
                    thumbnailBoxFix: widget.thumbnailBoxFix,
                    selectedCheckBackgroundColor:
                        widget.selectedItemBackgroundColor,
                    onAssetItemClick: (ctx, asset, index) async {
                      provider.pickEntity(asset);
                      widget.onSelected(provider.picked);
                    },
                  )
                : Container(),
          ),
        )
      ],
    );
  }

  Widget _defaultCloseWidget() {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Text('Cancel'));
  }
}
