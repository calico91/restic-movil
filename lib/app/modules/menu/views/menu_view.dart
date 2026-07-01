import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/menu/controllers/menu_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/expandable_section.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';
import 'package:restic_movil/core/utils/buttons/custom_floating_action_button.dart';
import 'package:restic_movil/core/utils/buttons/custom_edit_button.dart';
import 'package:restic_movil/app/data/models/product_model.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Menú',
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => controller.showCategoryForm(),
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
                labelColor: const Color(0xFF0D47A1),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF0D47A1),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              CustomEditButton(
                                onPressed: () => controller.showCategoryForm(
                                  category: category,
                                ),
                                label: 'Editar Categoría',
                              ),
                              ElevatedButton.icon(
                                onPressed: () => controller.showSubcategoryForm(
                                  categoryId: category.id ?? '',
                                ),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Subcategoría'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: subcategories.isEmpty
                              ? const Center(
                                  child: Text('No hay subcategorías'),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: subcategories.length,
                                  itemBuilder: (context, index) {
                                    final subcategory = subcategories[index];
                                    final products = subcategory.products ?? [];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: ExpandableSection(
                                        title: subcategory.name ?? 'Sin nombre',
                                        initiallyExpanded: true,
                                        content: Column(
                                          children: [
                                            // Acciones de la subcategoría
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 8.0,
                                                  ),
                                              child: Wrap(
                                                alignment:
                                                    WrapAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: [
                                                  CustomEditButton(
                                                    onPressed: () => controller
                                                        .showSubcategoryForm(
                                                          categoryId:
                                                              category.id ?? '',
                                                          subcategory:
                                                              subcategory,
                                                        ),
                                                    label: 'Editar Sub',
                                                    iconSize: 16,
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () => controller
                                                        .showProductForm(
                                                          categoryId:
                                                              category.id ?? '',
                                                          subcategoryId:
                                                              subcategory.id ??
                                                              '',
                                                        ),
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                    ),
                                                    label: const Text(
                                                      'Añadir Producto',
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                            0xFF0D47A1,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            if (products.isEmpty)
                                              const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Center(
                                                  child: Text(
                                                    'No hay productos',
                                                  ),
                                                ),
                                              )
                                            else
                                              ListView.separated(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: products.length,
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const Divider(
                                                          height: 1,
                                                        ),
                                                itemBuilder: (context, productIndex) {
                                                  final product =
                                                      products[productIndex];

                                                  if (product.productType ==
                                                          'VARIABLE' &&
                                                      (product
                                                              .prices
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    return _buildVariableProductTile(
                                                      product,
                                                      controller,
                                                      category.id ?? '',
                                                      subcategory.id ?? '',
                                                    );
                                                  }

                                                  final price =
                                                      product
                                                          .prices
                                                          ?.firstOrNull
                                                          ?.amount ??
                                                      0;
                                                  return ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 0,
                                                        ),
                                                    title: Text(
                                                      product.name ??
                                                          'Sin nombre',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle:
                                                        product.description !=
                                                                null &&
                                                            product
                                                                .description!
                                                                .isNotEmpty
                                                        ? Text(
                                                            product
                                                                .description!,
                                                          )
                                                        : null,
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          CurrencyFormatter.toCurrency(
                                                            price,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                  0xFF0D47A1,
                                                                ),
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        PopupMenuButton<String>(
                                                          tooltip: 'Acciones del producto',
                                                          icon: const Icon(
                                                            Icons.more_vert,
                                                            color: Color(0xFF0D47A1),
                                                          ),
                                                          onSelected: (value) {
                                                            // Ejecuta la accion despues de cerrar el popup.
                                                            Future<void>.delayed(Duration.zero, () async {
                                                              if (value == 'edit') {
                                                                controller.showProductForm(
                                                                  categoryId:
                                                                      category
                                                                          .id ??
                                                                          '',
                                                                  subcategoryId:
                                                                      subcategory
                                                                          .id ??
                                                                          '',
                                                                  product:
                                                                      product,
                                                                );
                                                              } else if (value == 'recipe') {
                                                                await controller.showRecipeForm(product);
                                                              } else if (value == 'manage_combo') {
                                                                await controller.showComboEditor(product);
                                                              }
                                                            });
                                                          },
                                                          itemBuilder: (context) {
                                                            final items = <PopupMenuEntry<String>>[
                                                              PopupMenuItem<String>(
                                                                value: 'edit',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(Icons.edit, size: 18),
                                                                    SizedBox(width: 8),
                                                                    Text('Editar producto'),
                                                                  ],
                                                                ),
                                                              ),
                                                              PopupMenuItem<String>(
                                                                value: 'recipe',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(Icons.restaurant_menu, size: 18),
                                                                    SizedBox(width: 8),
                                                                    Text('Configurar receta'),
                                                                  ],
                                                                ),
                                                              ),
                                                            ];
                                                            if (product.productType == 'COMBO') {
                                                              items.add(
                                                                PopupMenuItem<String>(
                                                                  value: 'manage_combo',
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(Icons.add_circle_outline, size: 18),
                                                                      SizedBox(width: 8),
                                                                      Text('Administrar combo'),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return items;
                                                          },
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

  Widget _buildVariableProductTile(
    ProductModel product,
    MenuController controller,
    String categoryId,
    String subcategoryId,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(product.description!),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Acciones del producto',
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF0D47A1),
                ),
                onSelected: (value) {
                  // Ejecuta la accion despues de cerrar el popup.
                  Future<void>.delayed(Duration.zero, () async {
                    if (value == 'edit') {
                      controller.showProductForm(
                        categoryId: categoryId,
                        subcategoryId: subcategoryId,
                        product: product,
                      );
                    } else if (value == 'recipe') {
                      await controller.showRecipeForm(product);
                    } else if (value == 'manage_combo') {
                      await controller.showComboEditor(product);
                    }
                  });
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar producto'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'recipe',
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_menu, size: 18),
                          SizedBox(width: 8),
                          Text('Configurar receta'),
                        ],
                      ),
                    ),
                  ];
                  if (product.productType == 'COMBO') {
                    items.add(
                      PopupMenuItem<String>(
                        value: 'manage_combo',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Administrar combo'),
                          ],
                        ),
                      ),
                    );
                  }
                  return items;
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...product.prices!.map((price) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price.sizeLabel ?? 'Sin tamaño',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.toCurrency(price.amount ?? 0.0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
