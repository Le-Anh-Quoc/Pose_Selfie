import 'package:get/get.dart';
import 'package:pose_selfie_app/src/features/home/domain/use_case.dart';
import 'package:pose_selfie_app/src/features/home/model/category_model.dart';

class HomeController extends GetxController {
  final HomeUseCase _useCase;

  HomeController(this._useCase);

  // tabs
  final RxInt selectedTabIndex = 0.obs;
  final RxList<String> tabs = ['All', 'Popular', 'New'].obs;

  // loading and error
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // list categories
  final RxList<CategoryModel> listCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    getCategories();
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await _useCase.getCategories();
      listCategories.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }
}
