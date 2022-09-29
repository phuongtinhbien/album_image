import 'package:album_image/src/album_image_picker.dart';
import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:album_image/src/widgets/thumbnail_image_widget.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

typedef OnAssetItemClick = void Function(
    BuildContext context, AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  /// asset album
  final AssetPathEntity path;

  /// on tap thumbnail
  final OnAssetItemClick? onAssetItemClick;

  /// picker data provider
  final PickerDataProvider provider;

  /// gallery gridview crossAxisCount
  final int crossAxisCount;

  /// gallery gridview aspect ratio
  final double childAspectRatio;

  /// gridView background color
  final Color gridViewBackgroundColor;

  /// gridView Padding
  final EdgeInsets? padding;

  /// gridView physics
  final ScrollPhysics? gridViewPhysics;

  /// gridView controller
  final ScrollController? gridViewController;

  /// selected background color
  final Color selectedBackgroundColor;

  /// builder icon selection
  final SelectionWidgetBuilder? selectionBuilder;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// background image color
  final Color imageBackgroundColor;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// image quality thumbnail
  final int thumbnailQuality;

  const GalleryGridView(
      {Key? key,
      required this.path,
      required this.provider,
      this.onAssetItemClick,
      this.childAspectRatio = 0.5,
      this.gridViewBackgroundColor = Colors.white,
      this.crossAxisCount = 3,
      this.padding = EdgeInsets.zero,
      this.gridViewController,
      this.gridViewPhysics,
      this.selectedBackgroundColor = Colors.black,
      this.imageBackgroundColor = Colors.white,
      this.thumbnailBoxFix = BoxFit.cover,
      this.selectedCheckBackgroundColor = Colors.white,
      this.thumbnailQuality = 200,
      this.selectionBuilder})
      : super(key: key);

  @override
  _GalleryGridViewState createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  static Map<int?, AssetEntity?> _createMap() {
    return {};
  }

  /// create cache for images
  var cacheMap = _createMap();

  /// notifier for scroll events
  final scrolling = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    /// generate thumbnail image grid view
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Container(
        color: widget.gridViewBackgroundColor,
        child: FutureBuilder<int>(
            future: widget.path.assetCountAsync,
            builder: (context, snapshot) {
              return GridView.builder(
                key: ValueKey(widget.path),
                padding: widget.padding,
                physics: widget.gridViewPhysics,
                controller: widget.gridViewController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: widget.childAspectRatio,
                  crossAxisCount: widget.crossAxisCount,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                ),

                /// render thumbnail
                itemBuilder: (context, index) =>
                    _buildItem(context, index, widget.provider),
                itemCount: snapshot.data ?? 0,
              );
            }),
      ),
    );
  }

  Widget _buildItem(BuildContext context, index, PickerDataProvider provider) {
    return GestureDetector(
      /// on tap thumbnail
      onTap: () async {
        final asset = cacheMap[index] ??
            (await widget.path
                .getAssetListRange(start: index, end: index + 1))[0];
        widget.onAssetItemClick?.call(context, asset, index);
      },

      /// render thumbnail
      child: _buildScrollItem(context, index, provider),
    );
  }

  Widget _buildScrollItem(
      BuildContext context, int index, PickerDataProvider provider) {
    /// load cache images
    return FutureBuilder<List<AssetEntity>>(
      future: widget.path.getAssetListRange(start: index, end: index + 1),
      builder: (ctx, snapshot) {
        final cachedImage = cacheMap[index];
        if (cachedImage == null &&
            (!snapshot.hasData || snapshot.data!.isEmpty)) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: widget.imageBackgroundColor,
          );
        }

        final asset = cachedImage ?? snapshot.data!.first;
        cacheMap[index] = asset;

        /// thumbnail widget
        return ThumbnailImageWidget(
          asset: asset,
          provider: provider,
          thumbnailQuality: widget.thumbnailQuality,
          selectedBackgroundColor: widget.selectedBackgroundColor,
          selectionBuilder: widget.selectionBuilder,
          imageBackgroundColor: widget.imageBackgroundColor,
          fit: widget.thumbnailBoxFix,
          selectedCheckBackgroundColor: widget.selectedCheckBackgroundColor,
        );
      },
    );
  }

  /// scroll notifier
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      scrolling.value = false;
    } else if (notification is ScrollStartNotification) {
      scrolling.value = true;
    }
    return false;
  }

  /// update widget on scroll
  @override
  void didUpdateWidget(GalleryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      cacheMap.clear();
      scrolling.value = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
