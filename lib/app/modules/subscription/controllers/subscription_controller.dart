import 'package:get/get.dart';
import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/data/models/subscription_invoice_model.dart';
import 'package:restic_movil/app/data/services/subscription_service.dart';
import 'package:restic_movil/app/data/repositories/subscription_repository.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';

enum SubscriptionViewMode { loading, noSubscription, trial, active, suspended }

class SubscriptionController extends GetxController {
  final SubscriptionService service = Get.find<SubscriptionService>();
  late final SubscriptionRepository _repository;

  final RxList<SubscriptionInvoiceModel> invoices = <SubscriptionInvoiceModel>[].obs;
  final RxBool loadingInvoices = false.obs;
  final RxBool paying = false.obs;
  final RxBool startingTrial = false.obs;
  final Rxn<String>errorMessage = Rxn<String>();

  bool get canManage => service.canManage;

  @override
  void onInit() {
    super.onInit();
    _repository = SubscriptionRepository(BaseHttpClient());
    if (service.status.value == null) {
      refreshStatus();
    } else {
      loadInvoices();
    }
  }

  SubscriptionViewMode get mode {
    if (service.loading.value) return SubscriptionViewMode.loading;
    if (!service.hasSubscription.value) return SubscriptionViewMode.noSubscription;
    final status = service.status.value;
    if (status == null) return SubscriptionViewMode.noSubscription;
    if (status.isSuspended) return SubscriptionViewMode.suspended;
    if (status.isTrial) return SubscriptionViewMode.trial;
    return SubscriptionViewMode.active;
  }

  Future<void> refreshStatus() async {
    errorMessage.value = null;
    await service.refreshStatus();
    if (service.hasSubscription.value) {
      await loadInvoices();
    }
  }

  Future<void> loadInvoices() async {
    loadingInvoices.value = true;
    try {
      invoices.value = await _repository.getInvoices();
    } catch (e) {
      invoices.value = [];
    } finally {
      loadingInvoices.value = false;
    }
  }

  Future<bool> startTrial() async {
    startingTrial.value = true;
    errorMessage.value = null;
    try {
      final ok = await service.startTrial();
      if (ok) {
        await loadInvoices();
      }
      return ok;
    } catch (e) {
      errorMessage.value = 'No se pudo iniciar la prueba: $e';
      return false;
    } finally {
      startingTrial.value = false;
    }
  }

  Future<bool> payInvoice(String id) async {
    paying.value = true;
    errorMessage.value = null;
    try {
      await _repository.payInvoice(id);
      await refreshStatus();
      return true;
    } catch (e) {
      if (e is SubscriptionSuspendedException || e is SubscriptionRequiredException) {
        await refreshStatus();
      }
      errorMessage.value = 'No se pudo marcar como pagada: $e';
      return false;
    } finally {
      paying.value = false;
    }
  }
}