import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/cash_register/views/cash_register/cash_register_view.dart';
import 'package:restic_movil/app/modules/commands/views/commands_view.dart';
import 'package:restic_movil/app/modules/orders/views/orders_view.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final Widget view;
  final List<String> allowedModules;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.view,
    required this.allowedModules,
  });
}

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final currentIndex = 0.obs;
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;
  final RxList<String> modules = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNavigationItems();
  }

  /*metodo para validar módulos y cargar items de navegación */
  Future<void> _loadNavigationItems() async {
    try {
      final user = await _storageService.getUser();

      if (user == null) {
        return;
      }

      final loadedModules =
          user.modules
              ?.map((m) => m.trim().toUpperCase())
              .where((m) => m.isNotEmpty)
              .toList() ??
          [];
      modules.assignAll(loadedModules);

      final allItems = [
        NavigationItem(
          title: 'Pedidos',
          icon: Icons.receipt_long,
          view: const OrdersView(),
          allowedModules: ['PEDIDOS'],
        ),
        NavigationItem(
          title: 'Comandas',
          icon: Icons.restaurant,
          view: const CommandsView(),
          allowedModules: ['COMANDAS'],
        ),
        NavigationItem(
          title: 'Caja',
          icon: Icons.credit_card,
          view: const CashRegisterView(),
          allowedModules: ['CAJA'],
        ),
      ];

      final allowed = allItems.where((item) {
        return item.allowedModules.any((m) => modules.contains(m));
      }).toList();

      navigationItems.assignAll(allowed);

      // Reset index if out of bounds or default to 0
      if (currentIndex.value >= allowed.length) {
        currentIndex.value = 0;
      }
    } catch (e) {
      debugPrint('Error loading navigation items: $e');
    }
  }

  /*metodo para cambiar de página */
  void changePage(int index) {
    currentIndex.value = index;
  }

  Future<String> getUserName() async {
    final user = await _storageService.getUser();
    return user?.name ?? 'Usuario';
  }

  Future<String> getBranchName() async {
    final branchId = await _storageService.getBranchId();
    final user = await _storageService.getUser();
    if (branchId != null && user?.branches != null) {
      final branch = user!.branches!.firstWhereOrNull((b) => b.id == branchId);
      return branch?.name ?? 'Restic Movil';
    }
    return 'Restic Movil';
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteUser();
    await _storageService.deleteBranchId();
    await _storageService.deleteOrderOrigins();
    await _storageService.deleteOrderStatuses();
    await _storageService.deleteOrderDetailStatuses();
    await _storageService.deletePaymentMethods();
    await _storageService.deleteTransactionTypes();
    Get.offAllNamed('/login');
  }
}
