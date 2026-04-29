import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/take_order/controllers/take_order_controller.dart';

/// Barra de búsqueda de productos por nombre.
class ProductSearchBar extends GetView<TakeOrderController> {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TextField(
        controller: controller.searchTextController,
        onChanged: controller.onSearchProduct,
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.searchProductQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.clearProductSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
    });
  }
}
