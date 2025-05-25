import 'package:get/get.dart';
import 'package:pose_selfie_app/src/features/home/data/api.dart';
import 'package:pose_selfie_app/src/features/home/data/repository.dart';
import 'package:pose_selfie_app/src/features/home/domain/use_case.dart';
import 'package:pose_selfie_app/src/features/home/ui/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeApiImpl());
    Get.lazyPut(() => HomeRepositoryImpl(Get.find<HomeApiImpl>()));
    Get.lazyPut(() => HomeUseCase(Get.find<HomeRepositoryImpl>()));
    Get.lazyPut(() => HomeController(Get.find<HomeUseCase>()));
  }
} 