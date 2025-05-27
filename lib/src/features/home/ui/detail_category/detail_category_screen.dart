// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';
import 'package:pose_selfie_app/src/features/home/model/category_model.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/camera_binding.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/camera_screen.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_controller.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/layouts/detail_category_header.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/layouts/detail_category_preview.dart';

class DetailCategoryScreen extends GetView<DetailCategoryController> {
  final CategoryModel poseItem;

  // Thêm biến đếm số lần từ chối quyền
  static int _permissionDeniedCount = 0;

  const DetailCategoryScreen({super.key, required this.poseItem});

  @override
  String? get tag => poseItem.id.toString();

  Future<void> _onStartPressed(BuildContext context) async {
    try {
      // Phải luôn kiểm tra quyền ở đầu hàm
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus micStatus = await Permission.microphone.status;
      if (cameraStatus.isGranted && micStatus.isGranted) {
        _permissionDeniedCount = 0;
        if (controller.listPose.isNotEmpty) {
          await controller.loadContourForPose(controller.listPose[0]);
        }
        if (context.mounted) {
          await Get.to(
            () => CameraScreen(categoryId: poseItem.id),
            arguments: {'categoryId': poseItem.id},
            binding: CameraScreenBinding(),
          );
        }
        return;
      }
      // Nếu đã từ chối 2 lần, chuyển hướng đến cài đặt
      if (_permissionDeniedCount >= 2) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Instruct', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text(
                  'Please go to "Permissions" in the app settings then enable Camera and Microphone permissions to use this feature.'),
              actions: [
                TextButton(
                  onPressed: () async => await openAppSettings(),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }
      // Nếu chưa có quyền, yêu cầu quyền
      Map<Permission, PermissionStatus> statuses =
          await [Permission.camera, Permission.microphone].request();
      if (!statuses[Permission.camera]!.isGranted ||
          !statuses[Permission.microphone]!.isGranted) {
        // Tăng biến đếm nếu bị từ chối
        _permissionDeniedCount++;
        // Hiện thông báo lỗi và không chuyển trang
        Get.snackbar(
          'Error',
          'You need to grant camera and microphone access to use this feature.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        );
        return;
      } else {
        // Nếu đã cấp quyền, reset biến đếm
        _permissionDeniedCount = 0;
      }
      if (controller.listPose.isNotEmpty) {
        await controller.loadContourForPose(controller.listPose[0]);
      }
      if (context.mounted) {
        await Get.to(
          () => CameraScreen(categoryId: poseItem.id),
          arguments: {'categoryId': poseItem.id},
          binding: CameraScreenBinding(),
        );
      }
    } catch (e) {
      print('Error in DetailCategoryScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: DetailCategoryHeader(poseItem: poseItem),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Obx(() => ElevatedButton(
                          onPressed: (controller.isLoading.value)
                              ? null
                              : () => _onStartPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.yellowButton,
                            disabledBackgroundColor: Colors
                                .yellow, // Keep yellow color when disabled
                            padding: const EdgeInsets.symmetric(
                              horizontal: 56,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                              side: const BorderSide(
                                  color: Colors.white, width: 3),
                            ),
                          ),
                          child: const Text(
                            "Let's start",
                            style: TextStyle(
                              fontSize: AppFontSize.small,
                              color: Colors.black87,
                              fontFamily: 'BowlbyOne',
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),
                    Expanded(
                      child: DetailCategoryPreview(
                        categoryId: poseItem.id,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
