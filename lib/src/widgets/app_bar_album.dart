import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:album_image/src/widgets/thumbnail_path.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AppBarAlbum extends StatelessWidget {
  /// picker provider
  final PickerDataProvider provider;

  final Color appBarColor;

  /// album background color
  final Color albumBackGroundColor;

  /// album header text color
  final TextStyle albumHeaderTextStyle;

  /// album text color
  final TextStyle albumTextStyle;

  /// album sub text color
  final TextStyle albumSubTextStyle;

  /// album divider color
  final Color albumDividerColor;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  ///appBar actions widgets
  final List<Widget>? appBarActionWidgets;

  final double height;

  final bool centerTitle;

  const AppBarAlbum(
      {Key? key,
      required this.provider,
      required this.appBarColor,
      required this.albumBackGroundColor,
      required this.albumDividerColor,
      this.albumHeaderTextStyle =
          const TextStyle(color: Colors.white, fontSize: 18),
      this.albumTextStyle = const TextStyle(color: Colors.white, fontSize: 18),
      this.albumSubTextStyle =
          const TextStyle(color: Colors.white, fontSize: 14),
      this.height = 65,
      this.centerTitle = true,
      this.appBarLeadingWidget,
      this.appBarActionWidgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: provider.currentPathNotifier,
      builder: (_, value, __) => AppBar(
        automaticallyImplyLeading: false,
        leading: appBarLeadingWidget,
        toolbarHeight: height,
        backgroundColor: appBarColor,
        actions: appBarActionWidgets,
        title: _buildAlbumButton(context, ValueNotifier(false)),
        centerTitle: centerTitle,
      ),
    );
  }

  Widget _buildAlbumButton(
    BuildContext context,
    ValueNotifier<bool> arrowDownNotifier,
  ) {
    if (provider.pathList.isEmpty || provider.currentPath == null) {
      return Container();
    }

    final decoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(35),
    );
    if (provider.currentPath == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: decoration,
      );
    } else {
      return GestureDetector(
        onTap: () => onSelectAlbum(context),
        child: Container(
          decoration: decoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.currentPath!.name,
                overflow: TextOverflow.ellipsis,
                style: albumHeaderTextStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedBuilder(
                  animation: arrowDownNotifier,
                  builder: (BuildContext context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: albumHeaderTextStyle.color!,
                    size: albumHeaderTextStyle.fontSize! * 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void onSelectAlbum(BuildContext context) {
    showModalBottomSheet(
        context: context,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2.5),
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return ChangePathWidget(
            albumDividerColor: albumDividerColor,
            albumTextStyle: albumTextStyle,
            albumSubTextStyle: albumSubTextStyle,
            provider: provider,
            itemHeight: 45,
            close: (value) {
              provider.currentPath = value;
              Navigator.pop(context);
            },
            albumBackGroundColor: albumBackGroundColor,
          );
        });
  }
}

class ChangePathWidget extends StatefulWidget {
  final PickerDataProvider provider;
  final ValueSetter<AssetPathEntity> close;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final TextStyle? albumTextStyle;

  /// album text sub color
  final TextStyle? albumSubTextStyle;

  /// album divider color
  final Color albumDividerColor;

  final double itemHeight;

  const ChangePathWidget(
      {Key? key,
      required this.provider,
      required this.close,
      required this.albumBackGroundColor,
      required this.albumDividerColor,
      this.albumTextStyle,
      this.albumSubTextStyle,
      this.itemHeight = 65})
      : super(key: key);

  @override
  _ChangePathWidgetState createState() => _ChangePathWidgetState();
}

class _ChangePathWidgetState extends State<ChangePathWidget> {
  PickerDataProvider get provider => widget.provider;

  late ScrollController controller;

  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = provider.pathList.indexOf(provider.currentPath!);
    controller =
        ScrollController(initialScrollOffset: widget.itemHeight * currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.albumBackGroundColor,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: Column(
          children: [
            Container(
              width: 24,
              height: 4,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(18)),
            ),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: provider.pathList.length,
                itemBuilder: _buildItem,
                separatorBuilder: (context, index) {
                  return Container(
                    color: widget.albumDividerColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = provider.pathList[index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.close.call(item);
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image(
                  image: ThumbnailPath(item, thumbSize: 100),
                  fit: BoxFit.cover,
                  width: widget.itemHeight,
                  height: widget.itemHeight,
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: widget.albumTextStyle ??
                          const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${item.assetCount}',
                      overflow: TextOverflow.ellipsis,
                      style: widget.albumSubTextStyle ??
                          const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: currentIndex == index ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.check),
            )
          ],
        ),
      ),
    );
  }
}
