import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class CashRegisterController extends GetxController {
  final OrdersRepository ordersRepository;

  CashRegisterController({required this.ordersRepository});

  // Tab Handling
  final RxInt currentTab = 0.obs; // 0: Pending (Open/Finalized), 1: History (Paid/Canceled)
  final RxList<OrderModel> pendingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await loadPendingOrders(withOverlay: true);
  }

  /*cargar pedidos pendientes (Open, Finalized)*/
  Future<void> loadPendingOrders({bool withOverlay = false}) async {
    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatuses(['OPEN', 'FINALIZED']);
        pendingOrders.assignAll(result);
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

  /*cargar historial (Paid, Canceled)*/
  Future<void> loadHistoryOrders({bool withOverlay = false}) async {
    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatuses(['PAID', 'CANCELED']);
        historyOrders.assignAll(result);
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

  /*cambiar tab*/
  void changeTab(int index) {
    currentTab.value = index;
    if (index == 0) {
      loadPendingOrders(withOverlay: true);
    } else {
      loadHistoryOrders(withOverlay: true);
    }
  }
}
