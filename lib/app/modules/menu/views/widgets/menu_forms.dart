import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/category_model.dart';

class CategoryFormDialog extends StatelessWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(category == null ? 'Nueva Categoría' : 'Editar Categoría'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: category?.name,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Categoría',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class SubcategoryFormDialog extends StatelessWidget {
  final String categoryId;
  final SubcategoryModel? subcategory;

  const SubcategoryFormDialog({
    super.key,
    required this.categoryId,
    this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          subcategory == null ? 'Nueva Subcategoría' : 'Editar Subcategoría'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: subcategory?.name,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: subcategory?.description,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class ProductFormDialog extends StatelessWidget {
  final String subcategoryId;
  final ProductModel? product;

  const ProductFormDialog({
    super.key,
    required this.subcategoryId,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(product == null ? 'Nuevo Producto' : 'Editar Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: product?.name,
              decoration: const InputDecoration(
                labelText: 'Nombre del Producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: product?.description,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: product?.price?.amount?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
