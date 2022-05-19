import 'package:album_image/src/provider/gallery_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dropdown.dart';

class SelectedPathDropdownButton extends StatelessWidget {
  /// picker provider
  final PhotoDataProvider provider;

  /// global key
  final GlobalKey? dropdownRelativeKey;
  final Color appBarColor;

  /// appBar TextColor
  final TextStyle? appBarTextStyle;

  /// appBar icon Color
  final Color appBarIconColor;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final TextStyle? albumTextStyle;

  /// album divider color
  final Color albumDividerColor;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  ///appBar actions widgets
  final Widget? appBarActionWidget;

  final double itemPathHeight;

  const SelectedPathDropdownButton(
      {Key? key,
      required this.provider,
      required this.dropdownRelativeKey,
      this.appBarTextStyle,
      required this.appBarIconColor,
      required this.appBarColor,
      required this.albumBackGroundColor,
      required this.albumDividerColor,
      this.albumTextStyle,
      this.itemPathHeight = 65,
      this.appBarLeadingWidget,
      this.appBarActionWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider.currentPathNotifier,
      builder: (_, __) => AppBar(
        automaticallyImplyLeading: false,
        leading: appBarLeadingWidget,
        backgroundColor: appBarColor,
        actions: [appBarActionWidget ?? Container()],
        title: Column(
          children: [
            DropdownButton<AssetPathEntity>(
                style: albumTextStyle ??
                    const TextStyle(color: Colors.white, fontSize: 18),
                value: provider.currentPath,
                isDense: true,
                dropdownColor: albumBackGroundColor,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: appBarIconColor,
                ),
                borderRadius: BorderRadius.circular(4),
                elevation: 2,
                itemHeight: null,
                underline: const SizedBox(),
                items: provider.pathList
                    .map((e) => DropdownMenuItem<AssetPathEntity>(
                        value: e,
                        child: Text(
                          e.name,
                          overflow: TextOverflow.ellipsis,
                          style: albumTextStyle ??
                              const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        )))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.currentPath = value;
                  }
                }),
          ],
        ),
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
      return Container(
        decoration: decoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                provider.currentPath!.name,
                overflow: TextOverflow.ellipsis,
                style: appBarTextStyle ??
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: AnimatedBuilder(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: appBarIconColor,
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
