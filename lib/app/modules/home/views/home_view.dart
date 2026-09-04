import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/data/services/subscription_service.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/home/views/widgets/custom_drawer.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/lazy_indexed_stack.dart';
import 'package:restic_movil/core/utils/icons/action_icon_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      /*Como se garantiza que el usuario tiene roles (validado en login),
        si la lista está vacía significa que aún estamos cargando los datos del Storage.
        Se muestra el loading hasta que se obtengan los items permitidos. */
      if (controller.navigationItems.isEmpty) {
        return const Scaffold(
          backgroundColor: Color(0xFFF5F6FA),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final currentIndex =
          controller.currentIndex.value < controller.navigationItems.length
          ? controller.currentIndex.value
          : 0;

      final currentItem = controller.navigationItems[currentIndex];
      final showPrinterIcon =
          currentItem.title == 'Pedidos' || currentItem.title == 'Caja';

      return CustomScaffold(
        title: currentItem.title,
        drawer: const CustomDrawer(),
        actions: showPrinterIcon
            ? [
                Obx(() {
                  final printerService = Get.find<PrinterService>();
                  final isConnected = printerService.isConnected.value ||
                      printerService.isNetworkConnected.value;
                  return ActionIconButton(
                    icon: Icons.print,
                    color: isConnected ? Colors.greenAccent : Colors.redAccent,
                    tooltip: 'Configuración de impresora',
                    onPressed: () => Get.toNamed(Routes.PRINTER_SETTINGS),
                  );
                }),
              ]
            : null,
        body: Column(
          children: [
            _buildSubscriptionBanner(),
            Expanded(
              child: LazyIndexedStack(
                index: currentIndex,
                children: controller.navigationItems.map((e) => e.view).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
          child: _buildBottomNavBar(currentIndex),
        ),
      );
    });
  }

  Widget _buildSubscriptionBanner() {
    try {
      final svc = Get.find<SubscriptionService>();
      return Obx(() {
        if (!svc.hasSubscription.value) return const SizedBox.shrink();
        final status = svc.status.value;
        if (status == null) return const SizedBox.shrink();
        if (status.isSuspended) {
          return Material(
            color: Colors.red.shade100,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Suscripción suspendida. Toca para ver facturas pendientes.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.red, size: 18),
                  ],
                ),
              ),
            ),
          );
        }
        if (status.isTrial) {
          final days = status.trialDaysRemaining ?? 0;
          return Material(
            color: Colors.orange.shade50,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Te quedan $days días de prueba. Toca para ver detalles.',
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.orange, size: 18),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavBar(int currentIndex) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(controller.navigationItems.length, (index) {
          final item = controller.navigationItems[index];
          return _navItem(
            item.icon,
            currentIndex == index,
            onTap: () => controller.changePage(index),
          );
        }),
      ),
    );
  }

  Widget _navItem(IconData icon, bool isActive, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: isActive
            ? BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? Colors.brown : Colors.red,
          size: 28,
        ),
      ),
    );
  }
}
