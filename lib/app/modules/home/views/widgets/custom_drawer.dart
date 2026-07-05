import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/routes/app_routes.dart';

class CustomDrawer extends GetView<HomeController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Obx(() {
                  if (!controller.modules.contains('USUARIOS')) {
                    return const SizedBox.shrink();
                  }
                  return _buildDrawerItem(
                    icon: Icons.manage_accounts,
                    title: 'Usuarios',
                    onTap: () => Get.toNamed(Routes.USERS),
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('MENU')) {
                    return const SizedBox.shrink();
                  }
                  return _buildDrawerItem(
                    icon: Icons.restaurant_menu,
                    title: 'Menú',
                    onTap: () => Get.toNamed(Routes.MENU),
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('MESAS')) {
                    return const SizedBox.shrink();
                  }
                  return _buildDrawerItem(
                    icon: Icons.table_restaurant,
                    title: 'Mesas',
                    onTap: () => Get.toNamed(Routes.TABLES),
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('CLIENTES')) {
                    return const SizedBox.shrink();
                  }
                  return _buildDrawerItem(
                    icon: Icons.people_outline,
                    title: 'Clientes',
                    onTap: () => Get.toNamed(Routes.CUSTOMERS),
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('OPCIONES_CAJA')) {
                    return const SizedBox.shrink();
                  }
                  return _buildExpansionTile(
                    icon: Icons.point_of_sale,
                    title: 'Opciones de Caja',
                    children: [
                      _buildDrawerSubItem(
                        title: 'Apertura de Caja',
                        onTap: () => Get.toNamed(Routes.OPEN_SHIFT),
                      ),
                      _buildDrawerSubItem(
                        title: 'Cierre de Caja',
                        onTap: () => Get.toNamed(Routes.CLOSE_SHIFT),
                      ),
                      _buildDrawerSubItem(
                        title: 'Egresos de Caja',
                        onTap: () => Get.toNamed(Routes.EXPENSES),
                      ),
                      _buildDrawerSubItem(
                        title: 'Cierres Pendientes',
                        onTap: () => Get.toNamed(Routes.PENDING_CLOSES),
                      ),
                      _buildDrawerSubItem(
                        title: 'Historial de Egresos',
                        onTap: () => Get.toNamed(Routes.WITHDRAWALS_HISTORY),
                      ),
                    ],
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('REPORTES')) {
                    return const SizedBox.shrink();
                  }

                  return _buildDrawerItem(
                    icon: Icons.bar_chart,
                    title: 'Reportes',
                    onTap: () => Get.toNamed(Routes.REPORTS),
                  );
                }),
                Obx(() {
                  final hasPrinter = controller.modules.contains(
                    'CONFIGURACION_IMPRESORA',
                  );
                  final hasFiscal = controller.modules.contains(
                    'CONFIGURACION_DATOS_FISCALES',
                  );
                  final isAdminOrSuper =
                      controller.userRoles.contains('ADMINISTRADOR') ||
                      controller.userRoles.contains('SUPER');

                  if (!hasPrinter && !hasFiscal && !isAdminOrSuper) {
                    return const SizedBox.shrink();
                  }

                  return _buildExpansionTile(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    children: [
                      if (hasPrinter)
                        _buildDrawerSubItem(
                          title: 'Impresora',
                          onTap: () => Get.toNamed(Routes.PRINTER_SETTINGS),
                        ),
                      if (hasFiscal)
                        _buildDrawerSubItem(
                          title: 'Datos Fiscales',
                          onTap: () => Get.toNamed(Routes.FISCAL_DATA),
                        ),
                      if (isAdminOrSuper)
                        Obx(
                          () => SwitchListTile(
                            contentPadding: const EdgeInsets.only(left: 56.0, right: 16.0),
                            title: const Text(
                              'Solo ver mis pedidos (meseros)',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            value: controller.waiterViewOwnOrdersOnly.value,
                            onChanged: (val) =>
                                controller.setWaiterViewOwnOrdersOnly(val),
                          ),
                        ),
                    ],
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('METODOS_PAGO')) {
                    return const SizedBox.shrink();
                  }
                  return _buildDrawerItem(
                    icon: Icons.payments_outlined,
                    title: 'Métodos de Pago',
                    onTap: () => Get.toNamed(Routes.PAYMENT_METHODS),
                  );
                }),
                Obx(() {
                  if (!controller.modules.contains('INVENTARIO')) {
                    return const SizedBox.shrink();
                  }
                  return _buildDrawerItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventario',
                    onTap: () => Get.toNamed(Routes.INVENTORY),
                  );
                }),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.account_circle,
            title: 'Perfil',
            onTap: () => Get.toNamed(Routes.PROFILE),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: controller.logout,
            color: Colors.red,
          ),
          Obx(() {
            if (controller.appVersion.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Text(
                  controller.appVersion.value,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox(height: 20);
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: controller.getUserName(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Usuario',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          FutureBuilder(
            future: controller.getBranchName(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Restic Movil',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: children,
    );
  }

  Widget _buildDrawerSubItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72.0),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}
