import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/cash_register/views/cash_register/cash_register_view.dart';
import 'package:restic_movil/app/modules/commands/views/commands_view.dart';
import 'package:restic_movil/app/modules/orders/controllers/orders_controller.dart';
import 'package:restic_movil/app/modules/orders/views/orders_view.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  final BaseHttpClient _httpClient = Get.find<BaseHttpClient>();
  final currentIndex = 0.obs;
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;
  final RxList<String> modules = <String>[].obs;
  final RxList<String> userRoles = <String>[].obs;
  final RxBool waiterViewOwnOrdersOnly = false.obs;
  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNavigationItems();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'Versión ${packageInfo.version} ';
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
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

      // Cargar roles del usuario
      userRoles.assignAll(user.roles ?? []);

      // Cargar configuración del filtro de mesero desde la sucursal activa
      final branchId = await _storageService.getBranchId();
      final branch = user.branches?.firstWhereOrNull((b) => b.id == branchId);
      waiterViewOwnOrdersOnly.value = branch?.waiterViewOwnOrdersOnly ?? false;

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
    await _storageService.saveWaiterViewOwnOrdersOnly(false);
    Get.offAllNamed('/login');
  }

  /*actualizar el filtro de pedidos por mesero en el backend y localmente*/
  Future<void> setWaiterViewOwnOrdersOnly(bool value) async {
    try {
      final branchId = await _storageService.getBranchId();
      if (branchId == null) return;

      await _httpClient.patch(
        '${UrlPaths.updateBranchWaiterFilter}/$branchId/waiter-filter',
        body: {'waiterViewOwnOrdersOnly': value},
      );

      waiterViewOwnOrdersOnly.value = value;
      await _storageService.saveWaiterViewOwnOrdersOnly(value);

      // Notificar al OrdersController si está activo para re-filtrar en caliente
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().updateWaiterFilter(value);
      }
    } catch (e) {
      final String errorMessage = ExceptionHandler.extractMessage(e);
      Get.showSnackbar(ErrorSnackbar(errorMessage));
    }
  }
}
