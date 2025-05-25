import 'package:pose_selfie_app/src/features/home/data/api.dart';
import 'package:pose_selfie_app/src/features/home/model/category_model.dart';
import 'package:pose_selfie_app/src/features/home/model/pose_model.dart';

abstract class HomeRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<PoseModel>> getPoseByCategory(int idCategory);
  Future<void> updatePoseContour(PoseModel pose);
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeApi _api;

  HomeRepositoryImpl(this._api);

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await _api.getCategories();
  }

  @override
  Future<List<PoseModel>> getPoseByCategory(int idCategory) async {
    return await _api.getPoseByCategory(idCategory);
  }

  @override
  Future<void> updatePoseContour(PoseModel pose) async {
    final contourData = await _api.getContourData(pose.id);
    if (contourData.containsKey('contour_white_url_png')) {
      pose.contourWhite = contourData['contour_white_url_png'];
    }
  }
}
