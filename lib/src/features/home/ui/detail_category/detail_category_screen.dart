import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';
import 'package:pose_selfie_app/src/features/home/model/category_model.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/camera_binding.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/camera_screen.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_controller.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/layouts/detail_category_header.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/layouts/detail_category_preview.dart';

class DetailCategoryScreen extends GetView<DetailCategoryController> {
  final CategoryModel poseItem;

  const DetailCategoryScreen({super.key, required this.poseItem});

  @override
  String? get tag => poseItem.id.toString();

  Future<void> _onStartPressed(BuildContext context) async {
    try {
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
      // handle error if needed
    } finally {
      //Future.microtask(() => controller.isProcessing.value = false);
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
                          onPressed:
                              (controller.isLoading.value)
                                  ? null
                                  : () => _onStartPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.yellowButton,
                            disabledBackgroundColor: Colors.yellow, // Keep yellow color when disabled
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
