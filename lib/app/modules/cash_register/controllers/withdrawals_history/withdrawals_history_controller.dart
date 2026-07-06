import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_reason.dart';
import 'package:restic_movil/app/data/models/cashier_user_model.dart';
import 'package:restic_movil/app/data/repositories/cash_withdrawals_repository.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:share_plus/share_plus.dart';

class WithdrawalsHistoryController extends GetxController {
  final CashWithdrawalsRepository _withdrawalRepository;
  final CashierRepository _cashierRepository;
  final StorageService _storageService = Get.find<StorageService>();

  WithdrawalsHistoryController(
    this._withdrawalRepository,
    this._cashierRepository,
  );

  final withdrawals = <CashWithdrawal>[].obs;
  final reasons = <CashWithdrawalReason>[].obs;
  final users = <CashierUser>[].obs;
  final isLoading = false.obs;
  final isAdmin = false.obs;
  final userId = ''.obs;

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  CashWithdrawalReason? selectedReason;
  String? selectedUserId;
  final isExporting = false.obs;

  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    final user = await _storageService.getUser();
    final roles = user?.roles ?? <String>[];
    userId.value = user?.id ?? '';
    isAdmin.value = roles.contains('ADMINISTRADOR') || roles.contains('SUPER');
    await loadFilters();
    await loadHistory();
  }

  Future<void> loadFilters() async {
    try {
      final results = await Future.wait([
        _withdrawalRepository.getReasons(),
        if (isAdmin.value) _cashierRepository.getAdminAndCashierUsers(),
        Future.value(<CashWithdrawal>[]),
      ]);
      reasons.assignAll(results[0] as List<CashWithdrawalReason>);
      if (isAdmin.value) {
        users.assignAll(results[1] as List<CashierUser>);
      }
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    }
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      await Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: () async {
          withdrawals.clear();
          final startStr = DateFormat('yyyy-MM-dd').format(startDate);
          final endStr = DateFormat('yyyy-MM-dd').format(endDate);
          final userFilter = isAdmin.value ? selectedUserId : userId.value;

          List<CashWithdrawal> result;
          if (isAdmin.value && selectedUserId == null) {
            result = await _withdrawalRepository.getWithdrawalHistory(
              startDate: startStr,
              endDate: endStr,
              reason: selectedReason?.name,
            );
          } else {
            result = await _withdrawalRepository.getWithdrawalHistory(
              startDate: startStr,
              endDate: endStr,
              reason: selectedReason?.name,
              userId: userFilter,
            );
          }
          withdrawals.addAll(result);
        },
      );
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    } finally {
      isLoading.value = false;
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    loadHistory();
  }

  void setReason(CashWithdrawalReason? reason) {
    selectedReason = reason;
    loadHistory();
  }

  void setUser(String? userId) {
    selectedUserId = userId;
    loadHistory();
  }

  Future<void> exportCsv() async {
    if (withdrawals.isEmpty) return;
    isExporting.value = true;
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);
      final bytes = await _withdrawalRepository.downloadHistoryCsv(
        startDate: startStr,
        endDate: endStr,
        reason: selectedReason?.name,
        userId: isAdmin.value ? selectedUserId : userId.value,
      );

      final dir = await getTemporaryDirectory();
      final filename =
          'egresos-caja-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Historial de egresos de caja',
      );
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    } finally {
      isExporting.value = false;
    }
  }
}
