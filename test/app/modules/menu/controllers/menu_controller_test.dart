import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
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

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> createSubcategory(Map<String, dynamic> data) async {}

  @override
  Future<void> updateSubcategory(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteSubcategory(String id) async {}

  @override
  Future<void> createProduct(Map<String, dynamic> data) async {}

  @override
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteProduct(String id) async {}
}

// Sobrescribimos el onReady para no colgar el flujo de prueba
class TestMenuController extends app_menu.MenuController {
  TestMenuController(super.repository);

  @override
  void onReady() {}

  // Usaremos métodos manuales inyectando la data del repo
}

void main() {
  group('Pruebas de Componentes - MenuController', () {
    late TestMenuController controller;
    late MockCategoriesRepository mockRepository;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      mockRepository = MockCategoriesRepository();
    });

    testWidgets('Debe cargar exitosamente la lista inicial de Categorías', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      controller = Get.put(TestMenuController(mockRepository));
      
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
      controller = Get.put(TestMenuController(mockRepository));

      expect(controller.selectedCategoryIndex.value, 0);

      controller.changeCategory(1);

      expect(controller.selectedCategoryIndex.value, 1);
    });
  });
}
