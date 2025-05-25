import 'package:get/get.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/camera_controller.dart';

class CameraScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CameraScreenController(categoryId: Get.arguments['categoryId']));
  }
} 