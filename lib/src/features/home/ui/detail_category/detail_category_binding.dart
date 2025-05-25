import 'package:get/get.dart';
import 'package:pose_selfie_app/src/features/home/data/api.dart';
import 'package:pose_selfie_app/src/features/home/data/repository.dart';
import 'package:pose_selfie_app/src/features/home/domain/use_case.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_controller.dart';

class DetailCategoryBinding extends Bindings {
  final int categoryId;

  DetailCategoryBinding(this.categoryId);

  @override
  void dependencies() {
    Get.put(
      DetailCategoryController(
        HomeUseCase(HomeRepositoryImpl(HomeApiImpl())),
        categoryId,
      ),
      tag: categoryId.toString(),
    );
  }
} 