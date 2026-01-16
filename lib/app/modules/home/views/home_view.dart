import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/cash_register/views/cash_register_view.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/orders/views/orders_view.dart';
import 'package:restic_movil/core/utils/widgets/custom_app_bar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOrdersTab = controller.currentIndex.value == 0;
      return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: CustomAppBar(
          title: isOrdersTab ? 'Pedidos' : 'Caja',
          icons: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
        ),
        body: Stack(
          children: [
            _buildBackgroundGradient(),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 20),
                      child: IndexedStack(
                        index: controller.currentIndex.value,
                        children: const [OrdersView(), CashRegisterView()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
          child: _buildBottomNavBar(),
        ),
      );
    });
  }

  Widget _buildBackgroundGradient() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              Icons.receipt_long,
              controller.currentIndex.value == 0,
              onTap: () => controller.changePage(0),
            ),
            _navItem(
              Icons.credit_card,
              controller.currentIndex.value == 1,
              onTap: () => controller.changePage(1),
            ),
          ],
        ),
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
                color: Colors.red.withOpacity(0.2),
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
