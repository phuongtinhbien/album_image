import 'package:photo_manager/photo_manager.dart';

class PickedAssetEntity extends AssetEntity {
  PickedAssetEntity(
      {required String id,
      required int typeInt,
      required int width,
      required int height})
      : super(id: id, typeInt: typeInt, width: width, height: height);
}
