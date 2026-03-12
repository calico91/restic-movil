import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/app/modules/menu/views/widgets/menu_forms.dart';

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

  // ==========================================
  // METODOS VISUALES PARA FORMULARIOS
  // ==========================================

  void showCategoryForm({CategoryModel? category}) {
    Get.dialog(
      CategoryFormDialog(
        category: category,
        onSubmit: (data) async {
          await _handleSave(
            action: () async {
              if (category == null) {
                await _categoriesRepository.createCategory(data);
              } else {
                await _categoriesRepository.updateCategory(category.id!, data);
              }
            },
            successMessage: category == null
                ? 'Categoría creada exitosamente'
                : 'Categoría actualizada correctamente',
          );
        },
      ),
    );
  }

  void showSubcategoryForm({
    required String categoryId,
    SubcategoryModel? subcategory,
  }) {
    Get.dialog(
      SubcategoryFormDialog(
        categoryId: categoryId,
        subcategory: subcategory,
        onSubmit: (data) async {
          await _handleSave(
            action: () async {
              if (subcategory == null) {
                await _categoriesRepository.createSubcategory(data);
              } else {
                await _categoriesRepository.updateSubcategory(
                  subcategory.id!,
                  data,
                );
              }
            },
            successMessage: subcategory == null
                ? 'Subcategoría creada exitosamente'
                : 'Subcategoría actualizada correctamente',
          );
        },
      ),
    );
  }

  void showProductForm({
    required String categoryId,
    required String subcategoryId,
    ProductModel? product,
  }) {
    Get.dialog(
      ProductFormDialog(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        product: product,
        onSubmit: (data) async {
          await _handleSave(
            action: () async {
              if (product == null) {
                await _categoriesRepository.createProduct(data);
              } else {
                await _categoriesRepository.updateProduct(product.id!, data);
              }
            },
            successMessage: product == null
                ? 'Producto creado exitosamente'
                : 'Producto actualizado correctamente',
          );
        },
      ),
    );
  }

  /// Ejecuta la accion (llamar a API) con loadng state, actualiza lista y muestra dialog
  Future<void> _handleSave({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await action();
          // Volver a cargar los datos para reflejar los cambios
          final result = await _categoriesRepository.getCategories();
          categories.assignAll(result);
          // Mostrar mensaje de exito
          Get.dialog(ModalInfo(title: 'Éxito', message: successMessage));
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }
}
