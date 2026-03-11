import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class MenuController extends GetxController {
  final CategoriesRepository _categoriesRepository;

  MenuController(this._categoriesRepository);

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxInt selectedCategoryIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    _loadMenu();
  }

  /// Carga la lista completa de categorias y sus productos.
  void _loadMenu() {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await _categoriesRepository.getCategories();
          categories.assignAll(result);
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }

  /// Actualiza el indice de la categoria seleccionada en los tabs.
  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }
}
