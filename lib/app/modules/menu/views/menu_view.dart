import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/menu/controllers/menu_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';
import 'package:restic_movil/app/modules/home/views/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
      customPattern: '\$ #,##0',
    );

    return CustomScaffold(
      title: 'Menú',
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showCategoryForm(),
        backgroundColor: Get.theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(
            child: Text(
              'No hay categorías disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return DefaultTabController(
          length: controller.categories.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                onTap: controller.changeCategory,
                labelColor: Get.theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Get.theme.primaryColor,
                tabs: controller.categories.map((category) {
                  return Tab(text: category.name ?? 'Sin nombre');
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: controller.categories.map((category) {
                    final subcategories = category.subcategories ?? [];

                    return Column(
                      children: [
                        // Acciones principales de la Categoría
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () => controller.showCategoryForm(category: category),
                                icon: const Icon(Icons.edit, size: 20),
                                label: const Text('Editar Categoría'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => controller.showSubcategoryForm(categoryId: category.id ?? ''),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Subcategoría'),
                              ),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: subcategories.isEmpty
                              ? const Center(child: Text('No hay subcategorías'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: subcategories.length,
                                  itemBuilder: (context, index) {
                                    final subcategory = subcategories[index];
                                    final products = subcategory.products ?? [];

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: ExpandableSection(
                                        title: subcategory.name ?? 'Sin nombre',
                                        initiallyExpanded: true,
                                        content: Column(
                                          children: [
                                            // Acciones de la subcategoría
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () => controller.showSubcategoryForm(
                                                      categoryId: category.id ?? '', 
                                                      subcategory: subcategory,
                                                    ),
                                                    icon: const Icon(Icons.edit, size: 16),
                                                    label: const Text('Editar Sub'),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () => controller.showProductForm(subcategoryId: subcategory.id ?? ''),
                                                    icon: const Icon(Icons.add, size: 16),
                                                    label: const Text('Añadir Producto'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            if (products.isEmpty)
                                              const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Center(child: Text('No hay productos')),
                                              )
                                            else
                                              ListView.separated(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: products.length,
                                                separatorBuilder: (context, index) =>
                                                    const Divider(height: 1),
                                                itemBuilder: (context, productIndex) {
                                                  final product = products[productIndex];
                                                  final price = product.price?.amount ?? 0;
                                                  return ListTile(
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 0,
                                                    ),
                                                    title: Text(
                                                      product.name ?? 'Sin nombre',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: product.description != null
                                                        ? Text(product.description!)
                                                        : null,
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          currencyFormat.format(price),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Get.theme.primaryColor,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        IconButton(
                                                          icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                                                          constraints: const BoxConstraints(),
                                                          padding: EdgeInsets.zero,
                                                          onPressed: () => controller.showProductForm(
                                                            subcategoryId: subcategory.id ?? '', 
                                                            product: product,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
