import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/payment_methods_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class CashRegisterController extends GetxController {
  final OrdersRepository ordersRepository;
  final PaymentMethodsRepository paymentMethodsRepository;
  final StorageService _storageService = Get.find<StorageService>();

  CashRegisterController({
    required this.ordersRepository,
    required this.paymentMethodsRepository,
  });

  // Tab Handling
  final RxInt currentTab =
      0.obs; // 0: Pending (Open/Finalized), 1: History (Paid/Canceled)
  final RxList<OrderModel> pendingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;
  final RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadPendingOrders(withOverlay: true),
      _loadPaymentMethods(),
    ]);
  }

  /*cargar métodos de pago: primero intenta cargar desde almacenamiento local, 
  si no hay, carga desde API y guarda en local*/
  Future<void> _loadPaymentMethods() async {
    try {
      final savedMethods = await _storageService.getPaymentMethods();
      if (savedMethods != null && savedMethods.isNotEmpty) {
        paymentMethods.assignAll(
          savedMethods.map((e) => PaymentMethodModel.fromJson(e)).toList(),
        );
      } else {
        final methods = await paymentMethodsRepository.getPaymentMethods();
        paymentMethods.assignAll(methods);
        await _storageService.savePaymentMethods(
          methods.map((e) => e.toJson()).toList(),
        );
      }
    } catch (e) {
      Get.log('Error loading payment methods: $e');
    }
  }

  /*cargar pedidos pendientes (Open, Finalized)*/
  Future<void> loadPendingOrders({bool withOverlay = false}) async {
    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatuses([
          'OPEN',
          'FINALIZED',
        ]);
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
        final result = await ordersRepository.getOrdersByStatuses([
          'PAID',
          'CANCELED',
        ]);
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
