// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:pose_selfie_app/src/features/home/domain/use_case.dart';
import 'package:pose_selfie_app/src/features/home/model/pose_model.dart';

class DetailCategoryController extends GetxController {
  final HomeUseCase _useCase;
  final RxInt _categoryId;

  DetailCategoryController(this._useCase, int categoryId) 
      : _categoryId = categoryId.obs;

  int get categoryId => _categoryId.value;

  // loading and error states
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // list of poses for the category
  final RxList<PoseModel> listPose = <PoseModel>[].obs;

  // Static cache for storing pose lists
  static final Map<int, List<PoseModel>> _poseCache = {};

  // Cache for storing contour data
  static final Map<int, String> _contourCache = {};

  @override
  void onInit() {
    super.onInit();
    getPoseByCategory();
  }

  void updateCategory(int newCategoryId) {
    if (_categoryId.value != newCategoryId) {
      _categoryId.value = newCategoryId;
      getPoseByCategory();
    }
  }

  Future<void> getPoseByCategory() async {
    try {
      // Check if data exists in cache
      if (_poseCache.containsKey(categoryId)) {
        print('Getting poses from cache for category $categoryId');
        listPose.value = _poseCache[categoryId]!;
        return;
      }

      isLoading.value = true;
      error.value = '';

      print('Fetching poses for category $categoryId');
      final result = await _useCase.getPoseByCategory(categoryId);
      print('Received ${result.length} poses for category $categoryId');
      
      // Store in cache
      _poseCache[categoryId] = result;
      listPose.value = result;
    } catch (e) {
      print('Error fetching poses for category $categoryId: $e');
      error.value = 'Error fetching poses for category $categoryId';
      listPose.clear(); // Clear the list when there's an error
    } finally {
      isLoading.value = false;
    }
  }

  void removePose(int index) {
    if (index >= 0 && index < listPose.length) {
      listPose.removeAt(index);
      update();
    }
  }

  void clearError() {
    error.value = '';
  }

  // Clear cache for a specific category
  static void clearCache(int categoryId) {
    _poseCache.remove(categoryId);
  }

  // Clear all cache
  static void clearAllCache() {
    _poseCache.clear();
  }

  Future<void> loadContourForPose(PoseModel pose) async {
    try {
      error.value = '';
      
      // Check cache first
      if (_contourCache.containsKey(pose.id)) {
        pose.contourWhite = _contourCache[pose.id];
        // Force UI update
        Future.microtask(() => listPose.refresh());
        return;
      }

      print('Loading contour for pose ${pose.id}');
      await _useCase.updatePoseContour(pose);
      
      if (pose.contourWhite != null && pose.contourWhite!.isNotEmpty) {
        print('Contour loaded successfully for pose ${pose.id}');
        _contourCache[pose.id] = pose.contourWhite!;
        // Force UI update
        Future.microtask(() => listPose.refresh());
      } else {
        print('No contour data available for pose ${pose.id}');
        error.value = 'No contour data available for this pose';
      }
    } catch (e) {
      print('Error loading contour for pose ${pose.id}: $e');
      error.value = 'Failed to load pose contour: $e';
      // Force UI update even on error
      Future.microtask(() => listPose.refresh());
    }
  }

  // Clear contour cache for a specific pose
  static void clearContourCache(int poseId) {
    _contourCache.remove(poseId);
  }

  // Clear all contour cache
  static void clearAllContourCache() {
    _contourCache.clear();
  }
}

