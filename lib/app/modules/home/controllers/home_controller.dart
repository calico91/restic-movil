import 'package:get/get.dart';
import '../../../data/models/order_model.dart';

class HomeController extends GetxController {
  final orders = <OrderModel>[].obs;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  void loadOrders() {
    orders.assignAll([
      OrderModel(
        id: 1,
        title: "Mesa 15",
        amount: 30000,
        status: "Pendiente",
        date: "Hoy, 14:50",
      ),
      OrderModel(
        id: 2,
        title: "Mesa 08",
        amount: 40000,
        status: "Preparando",
        date: "Hoy, 15:10",
      ),
      OrderModel(
        id: 3,
        title: "Mesa 10",
        amount: 50000,
        status: "Entregado",
        date: "Hoy, 17:50",
      ),
      OrderModel(
        id: 4,
        title: "Domicilio",
        amount: 70000,
        status: "Preparando",
        date: "Hoy, 18:00",
      ),
    ]);
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
