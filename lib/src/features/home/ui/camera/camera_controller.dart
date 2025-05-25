// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'dart:io';
import 'package:pose_selfie_app/src/features/home/data/api.dart';
import 'package:pose_selfie_app/src/features/home/data/repository.dart';
import 'package:pose_selfie_app/src/features/home/domain/use_case.dart';
import 'package:pose_selfie_app/src/features/home/ui/detail_category/detail_category_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pose_selfie_app/src/features/home/ui/camera/layouts/tutorial_dialog.dart';
import 'package:torch_light/torch_light.dart';

class CameraScreenController extends GetxController
    with WidgetsBindingObserver {
  final int categoryId;
  late final DetailCategoryController detailCategoryController;

  CameraScreenController({required this.categoryId});

  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  late List<CameraDescription> cameras;

  final isRecording = false.obs;
  final isVideoMode = false.obs;
  final selectedFilterIndex = 0.obs;
  final isInitialized = false.obs;
  final error = ''.obs;
  final countdown = (-1).obs;
  final selectedPoseIndex = 0.obs;
  final isLoadingContour = false.obs;
  final isFlashOn = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    _showTutorialIfNeeded();
  }

  void _initializeController() async {
    String tag = categoryId.toString();
    if (!Get.isRegistered<DetailCategoryController>(tag: tag)) {
      detailCategoryController = Get.put(
        DetailCategoryController(
          HomeUseCase(HomeRepositoryImpl(HomeApiImpl())),
          categoryId,
        ),
        tag: tag,
      );
    } else {
      detailCategoryController = Get.find<DetailCategoryController>(tag: tag);
      detailCategoryController.updateCategory(categoryId);
    }

    if (detailCategoryController.listPose.isNotEmpty) {
      selectedFilterIndex.value = 0;
      selectedPoseIndex.value = 0;
      // Load contour for initial pose
      detailCategoryController
          .loadContourForPose(detailCategoryController.listPose[0]);
    }

    await initCamera();
  }

  void _showTutorialIfNeeded() async {
    final shouldShow = await checkAndShowTutorial();
    if (shouldShow) {
      Get.dialog(const TutorialDialog());
    }
  }

  Future<bool> checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_camera_tutorial') ?? false;

    if (!hasSeenTutorial) {
      await prefs.setBool('has_seen_camera_tutorial', true);
      return true;
    }
    return false;
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      // Ưu tiên camera sau (back) nếu có
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final newController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await newController.initialize();
      cameraController.value = newController;
      isInitialized.value = true;
    } catch (e) {
      error.value = 'Failed to initialize camera: ${e.toString()}';
      isInitialized.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Nếu đang quay video thì tự động dừng và lưu video
      if (isRecording.value && cameraController.value != null) {
        stopVideoRecording();
      }
      // Không dispose camera, giữ nguyên trạng thái
    } else if (state == AppLifecycleState.resumed) {
      // Nếu camera chưa được khởi tạo lại thì khởi tạo lại
      if (cameraController.value == null ||
          !(cameraController.value?.value.isInitialized ?? false)) {
        Future.microtask(() async {
          await initCamera();
        });
      }
    }
    // AppLifecycleState.inactive: không làm gì, camera vẫn hoạt động
  }

  Future<void> disposeCamera() async {
    if (cameraController.value != null) {
      await cameraController.value!.dispose();
      cameraController.value = null;
      isInitialized.value = false;
    }
  }

  Future<void> reinitializeCamera() async {
    if (cameraController.value == null ||
        !(cameraController.value?.value.isInitialized ?? false)) {
      await initCamera();
    }
  }

  Future<String> getMediaDirectory(String type) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/$type');

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    return mediaDir.path;
  }

  void showSuccessNotification(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
    );
  }

  void showErrorNotification(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
    );
  }

  Future<void> takePicture() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      return;
    }

    try {
      final photoDir = await getMediaDirectory('photos');
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = join(photoDir, fileName);

      final file = await cameraController.value!.takePicture();
      await file.saveTo(path);

      showSuccessNotification('Photo saved successfully!');
    } catch (e) {
      showErrorNotification('Failed to take picture: ${e.toString()}');
    }
  }

  Future<void> startVideoRecording() async {
    if (cameraController.value == null ||
        cameraController.value!.value.isRecordingVideo) {
      return;
    }

    try {
      countdown.value = 3;

      await cameraController.value!.startVideoRecording();
      isRecording.value = true;

      for (int i = 3; i >= 1; i--) {
        await Future.delayed(const Duration(seconds: 1));
        countdown.value = i - 1;
      }
    } catch (e) {
      countdown.value = -1;
      isRecording.value = false;
      showErrorNotification('Failed to start recording: ${e.toString()}');
    }
  }

  Future<void> stopVideoRecording() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isRecordingVideo) {
      return;
    }

    try {
      final videoDir = await getMediaDirectory('videos');
      final videoFile = await cameraController.value!.stopVideoRecording();
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedFile = File('$videoDir/$fileName');

      await videoFile.saveTo(savedFile.path);
      isRecording.value = false;

      showSuccessNotification('Video saved successfully!');
    } catch (e) {
      isRecording.value = false;
      showErrorNotification('Failed to stop recording: ${e.toString()}');
    }
  }

  void toggleCameraMode() {
    if (isRecording.value) return;
    isVideoMode.toggle();
  }

  Future<void> switchCamera() async {
    // Nếu đang quay video thì thông báo và không cho đổi camera
    if (isRecording.value) {
      showErrorNotification('This function is disabled when recording video.');
      return;
    }
    final lensDirection = cameraController.value!.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.front) {
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } else {
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    }

    await cameraController.value!.dispose();
    final newCameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await newCameraController.initialize();
    cameraController.value = newCameraController;
    update();
  }

  void selectFilter(int index) async {
    selectedFilterIndex.value = index;
    selectedPoseIndex.value = index;
    isLoadingContour.value = true;
    // Load contour when filter is selected
    await detailCategoryController
        .loadContourForPose(detailCategoryController.listPose[index]);
    isLoadingContour.value = false;
  }

  String getCountdownImage(int count) {
    switch (count) {
      case 3:
        return 'three.svg';
      case 2:
        return 'two.svg';
      case 1:
        return 'one.svg';
      default:
        return '';
    }
  }

  Future<void> toggleFlashlight() async {
    try {
      if (isFlashOn.value) {
        await TorchLight.disableTorch();

        isFlashOn.value = false;
      } else {
        await TorchLight.enableTorch();
        isFlashOn.value = true;
      }
    } on Exception catch (e) {
      print('Flash toggle error: $e');
    }
  }

  @override
  void onClose() async {
    WidgetsBinding.instance.removeObserver(this);
    // Nếu đang quay thì dừng lại và lưu video
    if (isRecording.value && cameraController.value != null) {
      await stopVideoRecording();
    }
    disposeCamera();
    super.onClose();
  }
}
