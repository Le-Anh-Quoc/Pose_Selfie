// ignore_for_file: deprecated_member_use

import 'package:camera/camera.dart' as camera;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pose_selfie_app/src/common_widgets/icon_widget.dart';
import 'package:pose_selfie_app/src/constants/app_constants.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/layouts/tutorial_dialog.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/camera_controller.dart';

class CameraScreen extends GetView<CameraScreenController> {
  final int categoryId;

  const CameraScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isInitialized.value) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      if (controller.error.isNotEmpty) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.error.value,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.error.value = '';
                    controller.initCamera();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final size = MediaQuery.of(context).size;
      final deviceRatio = size.width / size.height;
      final scale = 1 /
          (controller.cameraController.value!.value.aspectRatio * deviceRatio);

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            Transform.scale(
              scale: scale,
              child: Center(
                  child:
                      camera.CameraPreview(controller.cameraController.value!)),
            ),

            // Contour Overlay
            Obx(() {
              if (controller.isLoadingContour.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (controller.detailCategoryController.listPose.isEmpty ||
                  controller.selectedPoseIndex.value >=
                      controller.detailCategoryController.listPose.length) {
                return const SizedBox();
              }

              final selectedPose = controller.detailCategoryController
                  .listPose[controller.selectedPoseIndex.value];
              if (selectedPose.contourWhite != null &&
                  selectedPose.contourWhite!.isNotEmpty) {
                return Center(
                  child: Image.network(
                    selectedPose.contourWhite!,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.7),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Error loading contour',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(
                child: Text(
                  'Unable to load contour',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }),

            // Countdown Overlay
            Obx(() {
              if (controller.countdown.value > 0) {
                return Center(
                  child: SvgPicture.asset(
                    'assets/images/${controller.getCountdownImage(controller.countdown.value)}',
                    width: 100,
                    height: 100,
                  ),
                );
              }
              return const SizedBox();
            }),

            // UI Controls
            Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconWidget(
            icon: Icons.arrow_back_ios,
            onPressed: () {
              Get.back();
            },
          ),
          IconWidget(
              icon: Icons.help_outline,
              paddingLeft: 0,
              onPressed: () {
                showDialog(
                  context: Get.context!,
                  builder: (context) => const TutorialDialog(),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterList(),
          const SizedBox(height: 20),
          _buildCameraControls(),
          const SizedBox(height: 20),
          _buildModeToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterList() {
    return SizedBox(
      height: 100,
      child: Obx(
        () {
          final poses = controller.detailCategoryController.listPose;
          if (poses.isEmpty) {
            return const Center(
              child: Text(
                'Unable to load poses',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: poses.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildFilterItem(index),
          );
        },
      ),
    );
  }

  Widget _buildFilterItem(int index) {
    final pose = controller.detailCategoryController.listPose[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => controller.selectFilter(index),
        child: Obx(
          () => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: controller.selectedFilterIndex.value == index
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pose.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
          
              // Nút close
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => {
                    controller.detailCategoryController.removePose(index),
                    controller.detailCategoryController.loadContourForPose(
                        controller.detailCategoryController.listPose[0]),
                    controller.selectedPoseIndex.value = 0,
                    controller.selectedFilterIndex.value = 0,
                  }, // thay bằng hàm bạn muốn
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            onTap: () {
              controller.toggleFlashlight();
            },
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: AppIcon.both)),
        Obx(() => _buildCaptureButton()),
        GestureDetector(
            onTap: () => controller.switchCamera(),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: AppIcon.change)),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: controller.isVideoMode.value
          ? (controller.isRecording.value
              ? controller.stopVideoRecording
              : controller.startVideoRecording)
          : controller.takePicture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 4),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: controller.isRecording.value
                ? BoxShape.rectangle
                : BoxShape.circle,
            borderRadius:
                controller.isRecording.value ? BorderRadius.circular(32) : null,
            color: controller.isVideoMode.value
                ? (controller.isRecording.value ? Colors.white : Colors.red)
                : Colors.white,
          ),
          child: controller.isRecording.value
              ? Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() => _buildToggleButton('Photo', !controller.isVideoMode.value)),
        const SizedBox(width: 20),
        Obx(() => _buildToggleButton('Video', controller.isVideoMode.value)),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: controller.toggleCameraMode,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          isSelected
              ? Container(
                  height: 2,
                  width: 30,
                  color: Colors.white, // hoặc Colors.white
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
