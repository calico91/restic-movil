import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/data/models/product_recipe_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/combos_repository.dart';
import 'package:restic_movil/app/data/repositories/inventory_repository.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/modals/recipe_form_dialog.dart';
import 'package:restic_movil/app/modules/menu/views/widgets/menu_forms.dart';
import 'package:restic_movil/app/modules/menu/views/widgets/combo_editor_dialog.dart';

class MenuController extends GetxController {
  final CategoriesRepository _categoriesRepository;
  final InventoryRepository _inventoryRepository;
  final CombosRepository _combosRepository;

  MenuController(this._categoriesRepository, this._inventoryRepository, this._combosRepository);

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
          Get.dialog(ModalError(message: message));
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
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /// Abre el modal para configurar receta del producto seleccionado.
  Future<void> showRecipeForm(ProductModel product) async {
    if (product.id == null) {
      Get.dialog(
        const ModalError(message: 'No se puede configurar receta: producto sin identificador.'),
      );
      return;
    }

    try {
      late final List<InventoryItemModel> inventoryItems;
      late final List<ProductRecipeModel> existingRecipes;

      await Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: () async {
          inventoryItems = await _inventoryRepository.getItems();
          existingRecipes = await _inventoryRepository.getRecipesForProduct(product.id!);
        },
      );

      final String actionResult =
          await Get.dialog<String>(
        RecipeFormDialog(
          product: product,
          inventoryItems: inventoryItems,
          existingRecipes: existingRecipes,
          onSave: (priceVariantId, ingredients) async {
            return saveRecipe(product.id!, priceVariantId, ingredients);
          },
          onDelete: (priceVariantId) async {
            return deleteRecipe(product.id!, priceVariantId: priceVariantId);
          },
        ),
      ) ??
          '';

      if (actionResult == 'saved') {
        Get.dialog(
          const ModalInfo(
            title: 'Exito',
            message: 'Receta guardada correctamente.',
          ),
        );
      } else if (actionResult == 'deleted') {
        Get.dialog(
          const ModalInfo(
            title: 'Exito',
            message: 'Receta eliminada correctamente.',
          ),
        );
      }
    } catch (e) {
      final message = ExceptionHandler.extractMessage(e);
      Get.dialog(ModalError(message: message));
    }
  }

  /// Guarda receta (base o por variante) asociada al producto.
  Future<bool> saveRecipe(
    String productId,
    String? priceVariantId,
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      await Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: () async {
          await _inventoryRepository.saveRecipe(productId, {
            'priceVariantId': priceVariantId,
            'ingredients': ingredients,
          });
        },
      );
      return true;
    } catch (e) {
      final message = ExceptionHandler.extractMessage(e);
      Get.dialog(ModalError(message: message));
      return false;
    }
  }

  /// Elimina receta (base o por variante) asociada al producto.
  Future<bool> deleteRecipe(String productId, {String? priceVariantId}) async {
    try {
      await Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: () async {
          await _inventoryRepository.deleteRecipe(
            productId,
            priceVariantId: priceVariantId,
          );
        },
      );
      return true;
    } catch (e) {
      final message = ExceptionHandler.extractMessage(e);
      Get.dialog(ModalError(message: message));
      return false;
    }
  }

  /// Retorna todos los productos SIMPLE de la sucursal (sin filtrar por combo).
  List<ProductModel> getAllSimpleProducts() {
    final simpleProducts = <ProductModel>[];
    for (final category in categories) {
      for (final subcategory in category.subcategories ?? []) {
        for (final product in subcategory.products ?? []) {
          if (product.productType == 'SIMPLE' && product.id != null) {
            simpleProducts.add(product);
          }
        }
      }
    }
    return simpleProducts;
  }

  /// Abre el editor de combos para un producto COMBO.
  Future<void> showComboEditor(ProductModel combo) async {
    await Get.dialog(
      ComboEditorDialog(
        combo: combo,
        simpleProducts: getAllSimpleProducts(),
        onAddOption: (groupId, productId) async {
          await _combosRepository.addOption(groupId, productId);
        },
        onRemoveOption: (optionId) async {
          await _combosRepository.removeOption(optionId);
        },
        onToggleOption: (optionId) async {
          await _combosRepository.toggleOption(optionId);
        },
        onRefresh: () async {
          final result = await _categoriesRepository.getCategories();
          categories.assignAll(result);
          for (final c in result) {
            for (final s in c.subcategories ?? []) {
              for (final p in s.products ?? []) {
                if (p.id == combo.id) return p;
              }
            }
          }
          return combo;
        },
      ),
    );
  }
}
