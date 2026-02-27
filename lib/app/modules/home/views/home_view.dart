import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/home/controllers/home_controller.dart';
import 'package:restic_movil/app/modules/home/views/widgets/custom_drawer.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/widgets/lazy_indexed_stack.dart';

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

      return CustomScaffold(
        title: currentItem.title,
        drawer: const CustomDrawer(),
        body: LazyIndexedStack(
          index: currentIndex,
          children: controller.navigationItems.map((e) => e.view).toList(),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
          child: _buildBottomNavBar(currentIndex),
        ),
      );
    });
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
