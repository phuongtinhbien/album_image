import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

typedef SortListBy = int Function(
  AssetPathEntity a,
  AssetPathEntity b,
);
mixin PhotoDataProvider on ChangeNotifier {
  /// current gallery album
  final currentPathNotifier = ValueNotifier<AssetPathEntity?>(null);

  AssetPathEntity? _current;

  AssetPathEntity? get currentPath => _current;

  set currentPath(AssetPathEntity? current) {
    if (_current != current) {
      _current = current;
      currentPathNotifier.value = current;
    }
  }

  /// save path in list
  List<AssetPathEntity> pathList = [];
  final pathListNotifier = ValueNotifier<List<AssetPathEntity>>([]);

  /// order path by date
  static int _defaultSort(
    AssetPathEntity a,
    AssetPathEntity b,
  ) {
    if (a.isAll) {
      return -1;
    }
    if (b.isAll) {
      return 1;
    }
    return 0;
  }

  /// add assets to a list
  void resetPathList(
    List<AssetPathEntity> list, {
    int defaultIndex = 0,
    SortListBy sortBy = _defaultSort,
  }) {
    list.sort(sortBy);
    pathList.clear();
    pathList.addAll(list);
    currentPath = list[defaultIndex];
    pathListNotifier.value = pathList;
    notifyListeners();
  }
}

class PickerDataProvider extends ChangeNotifier with PhotoDataProvider {
  final List<AssetEntity> picked;

  final pickedNotifier = ValueNotifier<List<AssetEntity>>([]);

  final onPickMax = ChangeNotifier();

  final maxSelection = ValueNotifier(0);

  int get max => maxSelection.value;

  set max(int value) => maxSelection.value = value;

  bool get singleMode => maxSelection.value == 1;

  void pickEntity(AssetEntity entity) {
    if (singleMode) {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        picked.clear();
        picked.add(entity);
      }
    } else {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        if (picked.length == maxSelection.value) {
          onPickMax.notifyListeners();
          return;
        }
        picked.add(entity);
      }
    }
    pickedNotifier.value = picked;
    pickedNotifier.notifyListeners();
    notifyListeners();
  }

  int pickIndex(AssetEntity entity) {
    return picked.indexOf(entity);
  }

  PickerDataProvider({this.picked = const [], required int maxSelectionCount}) {
    maxSelection.value = maxSelectionCount;
  }
}
