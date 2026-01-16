import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/cash_register/views/cash_register_view.dart';
import 'package:restic_movil/app/modules/commands/views/commands_view.dart';
import 'package:restic_movil/app/modules/orders/views/orders_view.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final Widget view;
  final List<String> allowedRoles;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.view,
    required this.allowedRoles,
  });
}

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final currentIndex = 0.obs;
  final isLoading = true.obs;
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNavigationItems();
  }

  /*metodo para validar roles y cargar items de navegación */
  Future<void> _loadNavigationItems() async {
    try {
      isLoading.value = true;
      final user = await _storageService.getUser();

      if (user == null) {
        return;
      }

      final roles =
          user.roles
              ?.map((r) => r.name?.trim().toUpperCase() ?? '')
              .where((r) => r.isNotEmpty)
              .toList() ??
          [];

      final allItems = [
        NavigationItem(
          title: 'Pedidos',
          icon: Icons.receipt_long,
          view: const OrdersView(),
          allowedRoles: ['SUPER', 'ADMINISTRADOR', 'PEDIDO'],
        ),
        NavigationItem(
          title: 'Comandas',
          icon: Icons.restaurant,
          view: const CommandsView(),
          allowedRoles: ['SUPER', 'ADMINISTRADOR', 'COCINA'],
        ),
        NavigationItem(
          title: 'Caja',
          icon: Icons.credit_card,
          view: const CashRegisterView(),
          allowedRoles: ['SUPER', 'ADMINISTRADOR', 'CAJA'],
        ),
      ];

      final allowed = allItems.where((item) {
        return item.allowedRoles.any((role) => roles.contains(role));
      }).toList();

      navigationItems.assignAll(allowed);

      // Reset index if out of bounds or default to 0
      if (currentIndex.value >= allowed.length) {
        currentIndex.value = 0;
      }
    } catch (e) {
      debugPrint('Error loading navigation items: $e');
    } finally {
      isLoading.value = false;
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
    Get.offAllNamed('/login');
  }
}
