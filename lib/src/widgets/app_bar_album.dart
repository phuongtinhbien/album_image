import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AppBarAlbum extends StatelessWidget {
  /// picker provider
  final PickerDataProvider provider;

  final Color appBarColor;

  /// appBar TextColor
  final TextStyle? appBarTextStyle;

  /// appBar icon Color
  final Color appBarIconColor;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final TextStyle albumTextStyle;

  /// album divider color
  final Color albumDividerColor;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  ///appBar actions widgets
  final List<Widget>? appBarActionWidgets;

  final double itemPathHeight;

  const AppBarAlbum(
      {Key? key,
      required this.provider,
      this.appBarTextStyle,
      required this.appBarIconColor,
      required this.appBarColor,
      required this.albumBackGroundColor,
      required this.albumDividerColor,
      this.albumTextStyle = const TextStyle(color: Colors.white, fontSize: 18),
      this.itemPathHeight = 65,
      this.appBarLeadingWidget,
      this.appBarActionWidgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider.currentPathNotifier,
      builder: (_, __) => AppBar(
        automaticallyImplyLeading: false,
        leading: appBarLeadingWidget,
        backgroundColor: appBarColor,
        actions: appBarActionWidgets,
        title: buildButton(context, ValueNotifier(false)),
        centerTitle: true,
      ),
    );
  }

  Widget buildButton(
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
        onTap: () {
          showModalBottomSheet(
              context: context,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height/3),
              enableDrag: true,

              builder: (_) {
                return ChangePathWidget(
                  albumDividerColor: albumDividerColor,
                  provider: provider,
                  itemHeight: 45,
                  close: (AssetPathEntity value) {
                    provider.currentPath = value;
                  },
                  albumBackGroundColor: albumBackGroundColor,
                );
              });
        },
        child: Container(
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.currentPath!.name,
                overflow: TextOverflow.ellipsis,
                style: albumTextStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AnimatedBuilder(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: albumTextStyle.color!,
                  ),
                  animation: arrowDownNotifier,
                  builder: (BuildContext context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class ChangePathWidget extends StatefulWidget {
  final PickerDataProvider provider;
  final ValueSetter<AssetPathEntity> close;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final TextStyle? albumTextStyle;

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
      this.itemHeight = 65})
      : super(key: key);

  @override
  _ChangePathWidgetState createState() => _ChangePathWidgetState();
}

class _ChangePathWidgetState extends State<ChangePathWidget> {
  PickerDataProvider get provider => widget.provider;

  ScrollController? controller;

  @override
  void initState() {
    super.initState();
    final index = provider.pathList.indexOf(provider.currentPath!);
    controller =
        ScrollController(initialScrollOffset: widget.itemHeight * index);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.albumBackGroundColor,
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
          controller: controller,
          shrinkWrap: true,
          itemCount: provider.pathList.length,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = provider.pathList[index];
    Widget w = SizedBox(
      height: widget.itemHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            style: widget.albumTextStyle ??
                const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
    w = Stack(
      children: <Widget>[
        /// list of album
        w,

        /// divider
        Positioned(
          height: 1,
          bottom: 0,
          right: 0,
          left: 1,
          child: IgnorePointer(
            child: Container(
              color: widget.albumDividerColor,
            ),
          ),
        ),
      ],
    );
    return GestureDetector(
      child: w,
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.close.call(item);
      },
    );
  }
}
