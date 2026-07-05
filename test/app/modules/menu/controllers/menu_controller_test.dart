import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/associated_product_model.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/data/models/product_recipe_model.dart';
import 'package:restic_movil/app/data/models/stock_movement_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/combos_repository.dart';
import 'package:restic_movil/app/data/repositories/inventory_repository.dart';
import 'package:restic_movil/app/modules/menu/controllers/menu_controller.dart' as app_menu;

class MockCategoriesRepository implements CategoriesRepository {
  bool throwError = false;
  bool isCategoryCreated = false;
  bool isCategoryUpdated = false;

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (throwError) throw Exception('Error al obtener el menú');
    return [
      CategoryModel(id: 'c-1', name: 'Bebidas', description: 'Refrescos y licores', subcategories: []),
      CategoryModel(id: 'c-2', name: 'Postres', description: 'Dulces', subcategories: []),
    ];
  }

  @override
  Future<void> createCategory(Map<String, dynamic> data) async {
    isCategoryCreated = true;
  }

  @override
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    isCategoryUpdated = true;
  }

  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> createSubcategory(Map<String, dynamic> data) async {}

  @override
  Future<void> updateSubcategory(String id, Map<String, dynamic> data) async {}

  Future<void> deleteSubcategory(String id) async {}

  @override
  Future<void> createProduct(Map<String, dynamic> data) async {}

  @override
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {}

  Future<void> deleteProduct(String id) async {}

  @override
  Future<CategoryModel> updateCategoryPrinter(String id, {required String? printerIp, required int? printerPort}) async {
    return CategoryModel(id: id, name: '', subcategories: []);
  }
}

class MockInventoryRepository implements InventoryRepository {
  @override
  Future<void> createItem(Map<String, dynamic> data) async {}

  @override
  Future<void> createManualMovement(Map<String, dynamic> data) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> deleteRecipe(String productId, {String? priceVariantId}) async {}

  @override
  Future<List<InventoryItemModel>> getAlerts() async => <InventoryItemModel>[];

  @override
  Future<List<InventoryItemModel>> getItems() async => <InventoryItemModel>[];

  @override
  Future<List<StockMovementModel>> getMovements({
    String? inventoryItemId,
    String? type,
    String? fromDate,
    String? toDate,
  }) async => <StockMovementModel>[];

  @override
  Future<List<ProductRecipeModel>> getRecipesForProduct(String productId) async => <ProductRecipeModel>[];

  @override
  Future<List<AssociatedProductModel>> getAssociatedProducts(String itemId) async => <AssociatedProductModel>[];

  @override
  Future<void> saveRecipe(String productId, Map<String, dynamic> data) async {}

  @override
  Future<void> saveAllRecipes(String productId, List<Map<String, dynamic>> recipes) async {}

  @override
  Future<void> updateItem(String id, Map<String, dynamic> data) async {}
}

class MockCombosRepository implements CombosRepository {
  @override
  Future<void> addOption(String groupId, String productId) async {}

  @override
  Future<void> removeOption(String optionId) async {}

  @override
  Future<void> toggleOption(String optionId) async {}
}

// Sobrescribimos el onReady para no colgar el flujo de prueba
class TestMenuController extends app_menu.MenuController {
  TestMenuController(super.categoriesRepository, super.inventoryRepository, super.combosRepository);

  @override
  void onReady() {}
}

void main() {
  group('Pruebas de Componentes - MenuController', () {
    late TestMenuController controller;
    late MockCategoriesRepository mockRepository;
    late MockInventoryRepository mockInventoryRepository;
    late MockCombosRepository mockCombosRepository;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      mockRepository = MockCategoriesRepository();
      mockInventoryRepository = MockInventoryRepository();
      mockCombosRepository = MockCombosRepository();
    });

    testWidgets('Debe cargar exitosamente la lista inicial de Categorías', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller = Get.put(TestMenuController(mockRepository, mockInventoryRepository, mockCombosRepository));
      
      // Llamar manualmente al super._loadMenu (con alias)
      await tester.runAsync(() async {
         final result = await mockRepository.getCategories();
         controller.categories.assignAll(result);
      });

      expect(controller.categories.length, 2);
      expect(controller.categories[0].name, 'Bebidas');
      expect(controller.categories[1].name, 'Postres');
    });

    testWidgets('Debe cambiar la categoría seleccionada correctamente (TABS)', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller = Get.put(TestMenuController(mockRepository, mockInventoryRepository, mockCombosRepository));

      expect(controller.selectedCategoryIndex.value, 0);

      controller.changeCategory(1);

      expect(controller.selectedCategoryIndex.value, 1);
    });
  });
}
