import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/modals/modal_warning.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/create_transaction_request.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';
import 'package:restic_movil/app/data/models/transaction_type_model.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/repositories/payment_methods_repository.dart';
import 'package:restic_movil/app/data/repositories/transactions_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/websocket_service.dart';
import 'package:restic_movil/app/modules/cash_register/views/cash_register/widgets/transaction_modal.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/app/data/models/transaction_receipt_model.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/transaction_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/58mm/precount_ticket_58mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/transaction_ticket_80mm.dart';
import 'package:restic_movil/core/utils/printers/tickets/80mm/precount_ticket_80mm.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';

class CashRegisterController extends GetxController {
  final OrdersRepository ordersRepository;
  final PaymentMethodsRepository paymentMethodsRepository;
  final TransactionsRepository transactionsRepository;
  final StorageService _storageService = Get.find<StorageService>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final PrinterService _printerService = Get.find<PrinterService>();

  CashRegisterController({
    required this.ordersRepository,
    required this.paymentMethodsRepository,
    required this.transactionsRepository,
  });

  // Tab Handling
  final RxInt currentTab =
      0.obs; // 0: Pending (Open/Finalized), 1: History (Paid/Canceled)
  final RxList<OrderModel> pendingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;

  // Filtro de fecha
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  String get _formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate.value);
  final RxList<PaymentMethodModel> paymentMethods = <PaymentMethodModel>[].obs;
  final RxList<TransactionTypeModel> transactionTypes =
      <TransactionTypeModel>[].obs;
  final RxString defaultTipPercentage = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  @override
  void onClose() {
    _webSocketService.disconnect();
    super.onClose();
  }

  /*conectar al websocket */
  void _connectWebSocket() {
    _webSocketService.connect();

    // Escuchar actualizaciones completas de ordenes abiertas
    _webSocketService.openOrdersStream.listen((updatedOrders) {
      if (currentTab.value == 0) {
        loadPendingOrders(withOverlay: false);
      }
    });

    // Escuchar ordenes individuales para recargar si es necesario
    _webSocketService.ordersStream.listen((order) {
      if (currentTab.value == 0) {
        loadPendingOrders(withOverlay: false);
      } else {
        loadHistoryOrders(withOverlay: false);
      }
    });
  }

  Future<void> _loadInitialData() async {
    final tipVal = await _storageService.getDefaultTipPercentage() ?? '0';
    defaultTipPercentage.value = tipVal.isEmpty ? '0' : tipVal;

    await Future.wait([
      loadPendingOrders(withOverlay: true),
      loadPaymentMethods(),
      _loadTransactionTypes(),
    ]);
  }

  /*cargar métodos de pago: primero intenta cargar desde almacenamiento local, 
  si no hay, carga desde API y guarda en local*/
  Future<void> loadPaymentMethods() async {
    try {
      final savedMethods = await _storageService.getPaymentMethods();
      List<PaymentMethodModel> methodsToAssign = [];
      if (savedMethods != null && savedMethods.isNotEmpty) {
        methodsToAssign = savedMethods
            .map((e) => PaymentMethodModel.fromJson(e))
            .toList();
      } else {
        final methods = await paymentMethodsRepository
            .getPaymentMethodsActive();
        methodsToAssign = methods;
        await _storageService.savePaymentMethods(
          methods.map((e) => e.toJson()).toList(),
        );
      }

      // Ordenar por displayOrder, los que no tengan van al final
      methodsToAssign.sort(
        (a, b) => (a.displayOrder ?? 999).compareTo(b.displayOrder ?? 999),
      );
      paymentMethods.assignAll(methodsToAssign);
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    }
  }

  /*cargar tipos de transacción: primero intenta cargar desde almacenamiento local, 
  si no hay, carga desde API y guarda en local*/
  Future<void> _loadTransactionTypes() async {
    try {
      final savedTypes = await _storageService.getTransactionTypes();
      if (savedTypes != null && savedTypes.isNotEmpty) {
        transactionTypes.assignAll(
          savedTypes.map((e) => TransactionTypeModel.fromJson(e)).toList(),
        );
      } else {
        final types = await transactionsRepository.getTransactionTypes();
        transactionTypes.assignAll(types);
        await _storageService.saveTransactionTypes(
          types.map((e) => e.toJson()).toList(),
        );
      }
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    }
  }

  /*retroceder un día y recargar*/
  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    _reloadCurrentTab();
  }

  /*avanzar un día (máximo hoy) y recargar*/
  void nextDay() {
    final DateTime now = DateTime.now();
    final DateTime next = selectedDate.value.add(const Duration(days: 1));
    if (next.year <= now.year && next.month <= now.month && next.day <= now.day) {
      selectedDate.value = next;
      _reloadCurrentTab();
    }
  }

  /*cambiar a una fecha específica y recargar*/
  void changeDate(DateTime date) {
    selectedDate.value = date;
    _reloadCurrentTab();
  }

  /*recargar el tab activo*/
  void _reloadCurrentTab() {
    if (currentTab.value == 0) {
      loadPendingOrders(withOverlay: true);
    } else {
      loadHistoryOrders(withOverlay: true);
    }
  }

  /*cargar pedidos pendientes (Open, Finalized)*/
  Future<void> loadPendingOrders({bool withOverlay = false}) async {
    Future<void> loadAction() async {
      try {
        final result = await ordersRepository.getOrdersByStatuses(
          ['OPEN', 'FINALIZED'],
          date: _formattedDate,
        );
        pendingOrders.assignAll(result);
      } catch (e) {
        ErrorHandler.showErrorDialog(e);
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
        final result = await ordersRepository.getOrdersByStatuses(
          ['PAID', 'CANCELED'],
          date: _formattedDate,
        );
        historyOrders.assignAll(result);
      } catch (e) {
        final String errorMessage = ExceptionHandler.extractMessage(e);
        Get.dialog(ModalError(message: errorMessage));
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

  void showTransactionModal(OrderModel order) {
    if (order.id == null) return;

    if (paymentMethods.isEmpty) {
      Get.dialog(const ModalError(message: 'No hay métodos de pago activos'));
      return;
    }

    Get.bottomSheet(
      TransactionModal(order: order),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  /*crear formulario para crear transacción a partir de un pedido*/
  FormGroup createTransactionForm(OrderModel order) {
    final currencyFormat = NumberFormat.decimalPattern('es_CO');

    // Obtener porcentaje de propina por defecto, si está vacío o null, será 0
    final defaultTip = defaultTipPercentage.value;

    final defaultPaymentMethod = paymentMethods.isNotEmpty
        ? paymentMethods.first.method
        : 'CASH';

    final form = FormGroup({
      'transactionType': FormControl<String>(value: 'SALE'),
      'tipPercentage': FormControl<String>(value: defaultTip),
      'tipAmount': FormControl<String>(value: '0'),
      'totalToPay': FormControl<String>(value: '0'),
      'originalTransactionId': FormControl<String>(),
      'payments': FormArray<Map<String, dynamic>>([
        FormGroup({
          'paymentMethod': FormControl<String>(
            value: defaultPaymentMethod,
            validators: [Validators.required],
          ),
          'amount': FormControl<String>(
            value: currencyFormat.format((order.total ?? 0).round()),
            validators: [Validators.required],
          ),
          'cardLastFour': FormControl<String>(),
          'cardBrand': FormControl<String>(),
          'authorizationCode': FormControl<String>(),
          'referenceNumber': FormControl<String>(),
        }),
      ]),
    });

    // Calcular montos iniciales basados en el porcentaje por defecto
    final orderTotal = order.total ?? 0.0;
    final initialPercent = double.tryParse(defaultTip) ?? 0.0;
    final orderSubtotal = order.subtotal ?? orderTotal;
    final initialTip = orderSubtotal * (initialPercent / 100);
    form.control('tipAmount').value = currencyFormat.format(initialTip.round());
    form.control('totalToPay').value = currencyFormat.format(
      (orderTotal + initialTip).round(),
    );

    String? expectedTipPercentage;
    String? expectedTipAmount;
    String? expectedTotalToPay;

    void updateControl(String name, String val) {
      if (form.control(name).value != val) {
        form.control(name).value = val;
      }
    }

    // Suscripción al porcentaje de propina
    form.control('tipPercentage').valueChanges.listen((value) {
      if (value != null && value.toString() == expectedTipPercentage) {
        expectedTipPercentage = null;
        return;
      }
      if (value != null && value.toString().isNotEmpty) {
        final percent = double.tryParse(value.toString()) ?? 0.0;
        final calcTip = orderSubtotal * (percent / 100);

        final newTipAmount = currencyFormat.format(calcTip.round());
        final newTotalToPay = currencyFormat.format(
          (orderTotal + calcTip).round(),
        );

        expectedTipAmount = newTipAmount;
        expectedTotalToPay = newTotalToPay;

        updateControl('tipAmount', newTipAmount);
        updateControl('totalToPay', newTotalToPay);
        updateInitialPayment(form, orderTotal + calcTip, currencyFormat);
      }
    });

    // Suscripción a la propina manual
    form.control('tipAmount').valueChanges.listen((value) {
      if (value != null && value.toString() == expectedTipAmount) {
        expectedTipAmount = null;
        return;
      }
      if (value != null) {
        final cleanValue = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
        final tipVal =
            double.tryParse(cleanValue.isEmpty ? '0' : cleanValue) ?? 0.0;

        final newPercent = orderSubtotal > 0
            ? (tipVal / orderSubtotal) * 100
            : 0.0;
        final newTipPercentage = newPercent
            .toStringAsFixed(1)
            .replaceAll('.0', '');
        final newTotalToPay = currencyFormat.format(
          (orderTotal + tipVal).round(),
        );

        expectedTipPercentage = newTipPercentage;
        expectedTotalToPay = newTotalToPay;

        updateControl('tipPercentage', newTipPercentage);
        updateControl('totalToPay', newTotalToPay);
        updateInitialPayment(form, orderTotal + tipVal, currencyFormat);
      }
    });

    // Suscripción al total manual
    form.control('totalToPay').valueChanges.listen((value) {
      if (value != null && value.toString() == expectedTotalToPay) {
        expectedTotalToPay = null;
        return;
      }
      if (value != null) {
        final cleanValue = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
        final totalVal =
            double.tryParse(cleanValue.isEmpty ? '0' : cleanValue) ?? 0.0;

        if (totalVal >= orderTotal) {
          final newTip = totalVal - orderTotal;

          final newTipAmount = currencyFormat.format(newTip.round());
          final newPercent = orderSubtotal > 0
              ? (newTip / orderSubtotal) * 100
              : 0.0;
          final newTipPercentage = newPercent
              .toStringAsFixed(1)
              .replaceAll('.0', '');

          expectedTipAmount = newTipAmount;
          expectedTipPercentage = newTipPercentage;

          updateControl('tipAmount', newTipAmount);
          updateControl('tipPercentage', newTipPercentage);
          updateInitialPayment(form, totalVal, currencyFormat);
        }
      }
    });

    // Actualizar el monto del pago inicial
    updateInitialPayment(form, orderTotal + initialTip, currencyFormat);

    return form;
  }

  void updateInitialPayment(
    FormGroup form,
    double totalToPay,
    NumberFormat currencyFormat,
  ) {
    final payments = form.control('payments') as FormArray;
    if (payments.controls.length == 1) {
      final firstPayment = payments.controls.first as FormGroup;
      final newAmount = currencyFormat.format(totalToPay);
      if (firstPayment.control('amount').value != newAmount) {
        firstPayment.control('amount').value = newAmount;
      }
    }
  }

  Future<void> updateDefaultTipPreference(String value) async {
    final cleanValue = value.isEmpty ? '0' : value;
    await _storageService.saveDefaultTipPercentage(cleanValue);
    defaultTipPercentage.value = cleanValue;
    Get.showSnackbar(
      const InfoSnackbar('Porcentaje de propina predeterminado actualizado'),
    );
  }

  /*anular orden completa*/
  void confirmCancelOrder(OrderModel order) {
    Get.dialog(
      ModalWarning(
        title: 'Anular Orden',
        message:
            '¿Está seguro que desea anular la orden #${order.orderNumber}?',
        buttonText: 'Cancelar',
        secondaryButtonText: 'Sí, Anular',
        onSecondaryAction: () {
          Get.back(); // Cerrar modal
          _cancelOrder(order);
        },
      ),
    );
  }

  // Función para cancelar la orden
  Future<void> _cancelOrder(OrderModel order) async {
    if (order.id == null) return;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await ordersRepository.updateOrderStatus(order.id!, 'CANCELED');

          Get.dialog(
            ModalInfo(
              title: '¡Operación Exitosa!',
              message:
                  'La orden #${order.orderNumber} se canceló correctamente.',
              onClose: () => Get.back(),
            ),
          );

          if (currentTab.value == 0) {
            await loadPendingOrders(withOverlay: false);
          } else {
            await loadHistoryOrders(withOverlay: false);
          }
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  Future<void> printPrecount(OrderModel order) async {
    final tipValStr = defaultTipPercentage.value;
    final tipPercentage = double.tryParse(tipValStr) ?? 0.0;

    final bool is80mm = _printerService.printerSize.value == '80mm';
    final ticket = is80mm
        ? PrecountTicket80mm(order: order, tipPercentage: tipPercentage)
        : PrecountTicket58mm(order: order, tipPercentage: tipPercentage);

    _printerService.printTicket(ticket);
  }

  // Reimprimir factura: si el pedido tiene transactionId, se puede reimprimir la factura, si no, mostrar error
  Future<void> reprintInvoice(String transactionId) async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final response = await transactionsRepository.getTransactionInvoice(
            transactionId,
          );

          final modelResponse = TransactionReceiptModel.fromJson(response);

          final bool is80mmReprint = _printerService.printerSize.value == '80mm';
          final ticket = is80mmReprint
              ? TransactionTicket80mm(transaction: modelResponse)
              : TransactionTicket58mm(transaction: modelResponse);
          await _printerService.printTicket(ticket);

          Get.showSnackbar(
            const InfoSnackbar('Factura reimpresa correctamente'),
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /*crear consumo de API para crear transacción a partir de formulario*/
  Future<void> createTransaction(CreateTransactionRequest request) async {
    // 1. Get current user ID for cashierId
    final loginResponse = await _storageService.getUser();
    final cashierId = loginResponse?.id;

    if (cashierId == null) {
      ErrorHandler.showErrorDialog('No se pudo identificar al usuario actual (Cajero).');
      return;
    }

    request.cashierId = cashierId;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final response = await transactionsRepository.createTransaction(
            request,
          );

          final modelResponse = TransactionReceiptModel.fromJson(response);

          // 4. Success handling
          Get.back(); // Close TransactionModal

          final format = NumberFormat.decimalPattern('es_CO');

          final change = modelResponse.change ?? 0.0;

          Get.dialog(
            ModalInfo(
              title: 'Pago realizado correctamente',
              message:
                  'Valor a devolver: \$${format.format(change)}\nFactura N°: ${modelResponse.transactionNumber ?? ''}',
              buttonText: 'Cerrar',
              secondaryButtonText: 'Imprimir Factura',
              onSecondaryAction: () {
                final bool is80mm = _printerService.printerSize.value == '80mm';
                final ticket = is80mm
                    ? TransactionTicket80mm(transaction: modelResponse)
                    : TransactionTicket58mm(transaction: modelResponse);
                _printerService.printTicket(ticket);
                Get.back();
              },
              onClose: () {
                Get.back(); // Close ModalInfo
                loadPendingOrders();
              },
            ),
            barrierDismissible: false,
          );
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );
  }

  /* actualizar cargos adicionales de un pedido desde caja registradora */
  Future<void> saveOrderSurcharges(String orderId, List<dynamic> surcharges) async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final mappedSurcharges = surcharges.map((s) => {
            'description': s.description,
            'amount': s.amount,
          }).toList();
          await ordersRepository.updateOrderSurcharges(orderId, mappedSurcharges);
          Get.back();
          Get.showSnackbar(
            const InfoSnackbar('Cargos adicionales actualizados exitosamente'),
          );
          await loadPendingOrders();
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }
}
