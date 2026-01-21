import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class OrdersController extends GetxController {
  final OrdersRepository ordersRepository;

  OrdersController({required this.ordersRepository});

  final RxList<OrderModel> _allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterOrders);
  }

  @override
  void onReady() {
    super.onReady();
    loadOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /*obtener pedidos en estado open*/
  Future<void> loadOrders({bool withOverlay = true}) async {
    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatus('OPEN');
        _allOrders.assignAll(result);
        _filterOrders();
      } catch (e) {
        final String errorMessage = ExceptionHandler.extractMessage(e);
        Get.showSnackbar(ErrorSnackbar(errorMessage));
      }
    }

    if (withOverlay) {
      Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: loadAction,
      );
    } else {
      await loadAction();
    }
  }

  /*filtrar pedidos por mesa*/
  void _filterOrders() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      orders.assignAll(_allOrders);
    } else {
      orders.assignAll(
        _allOrders.where((order) {
          final tableNames =
              order.tables?.map((t) => t.name?.toLowerCase() ?? '').toList() ??
              [];
          // Busca si alguna mesa contiene el texto buscado
          return tableNames.any((name) => name.contains(query));
        }).toList(),
      );
    }
  }
}
