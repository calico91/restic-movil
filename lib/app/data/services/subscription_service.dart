import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/models/subscription_status_model.dart';
import 'package:restic_movil/app/data/repositories/subscription_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';

class SubscriptionService extends GetxService {
  final SubscriptionRepository _repository;
  final StorageService _storageService;

  SubscriptionService({SubscriptionRepository? repository})
    : _repository = repository ?? SubscriptionRepository(BaseHttpClient()),
      _storageService = Get.find<StorageService>();

  final Rxn<SubscriptionStatusModel> status = Rxn<SubscriptionStatusModel>();
  final RxBool hasSubscription = false.obs;
  final RxBool loading = false.obs;

  List<String> _userModules = [];

  @override
  void onInit() {
    super.onInit();
    _loadModulesFromStorage();
  }

  Future<void> _loadModulesFromStorage() async {
    try {
      final user = await _storageService.getUser();
      _userModules = user?.modules ?? [];
    } catch (_) {
      _userModules = [];
    }
  }

  void setUserModules(List<String> modules) {
    _userModules = modules;
  }

  bool get canManage => _userModules.contains('SUSCRIPCION');

  Future<void> refreshStatus() async {
    if (!canManage) {
      status.value = null;
      hasSubscription.value = false;
      return;
    }
    loading.value = true;
    try {
      final result = await _repository.getStatus();
      status.value = result;
      hasSubscription.value = result != null;
    } catch (_) {
      hasSubscription.value = false;
      status.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> startTrial() async {
    loading.value = true;
    try {
      await _repository.startTrial();
      await refreshStatus();
      return true;
    } catch (_) {
      return false;
    } finally {
      loading.value = false;
    }
  }

  void clear() {
    status.value = null;
    hasSubscription.value = false;
    _userModules = [];
  }
}