import 'package:pose_selfie_app/src/features/home/data/repository.dart';
import 'package:pose_selfie_app/src/features/home/model/category_model.dart';
import 'package:pose_selfie_app/src/features/home/model/pose_model.dart';

class HomeUseCase {
  final HomeRepository _repository;
  HomeUseCase(this._repository);

  Future<List<CategoryModel>> getCategories() async {
    return await _repository.getCategories();
  }

  Future<List<PoseModel>> getPoseByCategory(int idCategory) async {
    return await _repository.getPoseByCategory(idCategory);
  }

  Future<void> updatePoseContour(PoseModel pose) async {
    await _repository.updatePoseContour(pose);
  }
}