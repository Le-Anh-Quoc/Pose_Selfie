// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, avoid_print

import 'dart:async';
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
import 'package:pose_selfie_app/src/features/home/model/pose_model.dart';

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
  final isRemovingPose = false.obs;
  final isSavingPicture = false.obs;
  final isSavingVideo = false.obs;
  final isVideoActionProcessing = false.obs;

  // List pose riêng cho CameraScreen
  final RxList<PoseModel> cameraScreenPoseList = <PoseModel>[].obs;

  DateTime? _lastRemoveErrorTime;

  final RxInt recordingDuration = 0.obs;
  final RxDouble videoProgress = 0.0.obs; // Tiến trình quay video (0-1)

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

    initializeCameraScreenPoseList();

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

  // Future<void> initCamera() async {
  //   //Kiểm tra quyền camera và microphone
  //   PermissionStatus status = await Permission.camera.status;
  //   if (status.isDenied) {
  //     PermissionStatus newStatus = await Permission.camera.request();
  //     if (newStatus.isGranted) {
  //       await reloadCamera();
  //     } else if (newStatus.isPermanentlyDenied) {
  //       // Người dùng từ chối vĩnh viễn – hiển thị hộp thoại điều hướng đến cài đặt
  //       print('Điều hướng đến cài đặt khi bị từ chối');
  //       Get.back();
  //     }
  //   } else if (status.isGranted) {
  //     // Nếu đã có quyền, kiểm tra và khởi tạo camera
  //     await reloadCamera();
  //   } else if (status.isPermanentlyDenied) {
  //     Get.back();
  //     showErrorNotification(
  //       'Camera permission is permanently denied. Please enable it in settings.',
  //     );
  //   }
  // }

  // Future<void> reloadCamera() async {
  //   try {
  //     cameras = await availableCameras();
  //     // Ưu tiên camera sau (back) nếu có
  //     final backCamera = cameras.firstWhere(
  //       (camera) => camera.lensDirection == CameraLensDirection.back,
  //       orElse: () => cameras.first,
  //     );
  //     final newController = CameraController(
  //       backCamera,
  //       ResolutionPreset.high,
  //       enableAudio: true,
  //       imageFormatGroup: ImageFormatGroup.jpeg,
  //     );
  //     await newController.initialize();
  //     cameraController.value = newController;
  //     isInitialized.value = true;
  //   } catch (e) {
  //     error.value = 'Failed to initialize camera:  ${e.toString()}';
  //     isInitialized.value = false;
  //   }
  // }

  Future<void> initCamera() async {
    // if (_isInitializing) return;
    // _isInitializing = true;

    // bool hasPermission = await _checkAndRequestPermissions();
    // if (!hasPermission) {
    //   Get.back();
    //   return;
    // }

    try {
      cameras = await availableCameras();
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
      error.value = 'Failed to initialize camera: ${e.toString()}';
      isInitialized.value = false;
    }
  }

  // Future<bool> _checkAndRequestPermissions() async {
  //   PermissionStatus status = await Permission.camera.status;

  //   if (status.isGranted) {
  //     return true;
  //   }

  //   if (status.isDenied) {
  //     PermissionStatus newStatus = await Permission.camera.request();
  //     if (newStatus.isGranted) {
  //       return true;
  //     } else if (newStatus.isPermanentlyDenied) {
  //       return false;
  //     } else {
  //       return false; // Trường hợp bị từ chối lại nhưng không vĩnh viễn
  //     }
  //   }

  //   if (status.isPermanentlyDenied) {
  //     return false;
  //   }

  //   // Dự phòng cho các trạng thái khác (hiếm gặp)
  //   return false;
  // }

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
        !cameraController.value!.value.isInitialized ||
        isSavingPicture.value) {
      return;
    }

    isSavingPicture.value = true;
    bool isFlashAvailable = isFlashOn.value;

    // Đặt chế độ flash theo ý muốn, không để auto
    await cameraController.value!.setFlashMode(
      isFlashAvailable ? FlashMode.torch : FlashMode.off,
    );

    try {
      final photoDir = await getMediaDirectory('photos');
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = join(photoDir, fileName);

      final file = await cameraController.value!.takePicture();
      await file.saveTo(path);

      await cameraController.value!.setFlashMode(FlashMode.off);

      showSuccessNotification('Photo saved successfully!');
    } catch (e) {
      showErrorNotification('Failed to take picture: [${e.toString()}');
    } finally {
      isSavingPicture.value = false;
    }
  }

  Future<void> startVideoRecording() async {
    if (cameraController.value == null ||
        cameraController.value!.value.isRecordingVideo ||
        isSavingVideo.value ||
        isRecording.value ||
        isVideoActionProcessing.value) {
      return;
    }
    isVideoActionProcessing.value = true;
    try {
      countdown.value = 3;
      await cameraController.value!.startVideoRecording();
      await cameraController.value!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
      isRecording.value = true;
      recordingDuration.value = 0;
      videoProgress.value = 0.0; // reset progress
      _startRecordingTimer();
      for (int i = 3; i >= 1; i--) {
        await Future.delayed(const Duration(seconds: 1));
        countdown.value = i - 1;
      }
    } catch (e) {
      countdown.value = -1;
      isRecording.value = false;
      videoProgress.value = 0.0;
      showErrorNotification('Failed to start recording:  ${e.toString()}');
    } finally {
      isVideoActionProcessing.value = false;
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isRecording.value) {
        timer.cancel();
      } else {
        recordingDuration.value++;
        // Cập nhật tiến trình (giả sử tối đa 60s)
        videoProgress.value = (recordingDuration.value) / 60.0;
        if (videoProgress.value >= 1.0) {
          videoProgress.value = 1.0;
          stopVideoRecording();
        }
      }
    });
  }

  Timer? _recordingTimer;

  Future<void> stopVideoRecording() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isRecordingVideo ||
        isSavingVideo.value ||
        !isRecording.value ||
        isVideoActionProcessing.value) {
      return;
    }
    isVideoActionProcessing.value = true;
    isSavingVideo.value = true;
    try {
      final videoDir = await getMediaDirectory('videos');
      final videoFile = await cameraController.value!.stopVideoRecording();
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedFile = File('$videoDir/$fileName');

      await videoFile.saveTo(savedFile.path);
      isRecording.value = false;
      _recordingTimer?.cancel();
      videoProgress.value = 0.0;
      await cameraController.value!.setFlashMode(
        FlashMode.off,
      );
      showSuccessNotification('Video saved successfully!');
    } catch (e) {
      isRecording.value = false;
      _recordingTimer?.cancel();
      videoProgress.value = 0.0;
      showErrorNotification('Failed to stop recording: ${e.toString()}');
    } finally {
      isSavingVideo.value = false;
      isVideoActionProcessing.value = false;
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

  void toggleFlash() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      return;
    }

    isFlashOn.value = !isFlashOn.value;
    // Cho phép bật/tắt flash cả khi đang quay video
    if (isRecording.value) {
      await cameraController.value!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  void selectFilter(int index) async {
    selectedFilterIndex.value = index;
    selectedPoseIndex.value = index;
    isLoadingContour.value = true;
    // Load contour when filter is selected
    await detailCategoryController
        .loadContourForPose(cameraScreenPoseList[index]);
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

  void initializeCameraScreenPoseList() {
    cameraScreenPoseList.assignAll(detailCategoryController.listPose.map((e) =>
        PoseModel(id: e.id, image: e.image, contourWhite: e.contourWhite)));
  }

  void removeCameraScreenPose(int index) async {
    if (isRemovingPose.value || isLoadingContour.value) {
      // Chỉ hiện thông báo lỗi nếu chưa hiện trong 1 giây gần nhất
      final now = DateTime.now();
      if (_lastRemoveErrorTime == null ||
          now.difference(_lastRemoveErrorTime!) > const Duration(seconds: 1)) {
        showErrorNotification('Please wait until the current pose is loaded.');
        _lastRemoveErrorTime = now;
      }
      return;
    }
    if (cameraScreenPoseList.isNotEmpty &&
        index < cameraScreenPoseList.length) {
      isRemovingPose.value = true;
      cameraScreenPoseList.removeAt(index);
      if (cameraScreenPoseList.isNotEmpty) {
        int newIndex = (index > 0) ? index : 0;
        selectFilter(newIndex);
        await detailCategoryController
            .loadContourForPose(cameraScreenPoseList[newIndex]);
      }
      isRemovingPose.value = false;
    }
  }

  Future<void> loadContourForCameraScreenPose(PoseModel pose) async {
    isLoadingContour.value = true;
    await detailCategoryController.loadContourForPose(pose);
    isLoadingContour.value = false;
  }

  @override
  void onClose() async {
    WidgetsBinding.instance.removeObserver(this);
    // Nếu đang quay thì dừng lại và lưu video
    if (isRecording.value && cameraController.value != null) {
      await stopVideoRecording();
    }
    if (isFlashOn.value) {
      await TorchLight.disableTorch();
      isFlashOn.value = false;
    }
    await disposeCamera();
    super.onClose();
  }

  String formatRecordingDuration() {
    final int seconds = recordingDuration.value;
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
