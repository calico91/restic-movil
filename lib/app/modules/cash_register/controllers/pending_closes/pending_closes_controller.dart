import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/cashier_shift.dart';
import 'package:restic_movil/app/data/models/shift_summary.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';

class PendingClosesController extends GetxController {
  final CashierRepository _repository;
  final StorageService _storageService = Get.find<StorageService>();

  PendingClosesController(this._repository);

  final openShifts = <CashierShift>[].obs;
  final closedShifts = <CashierShift>[].obs;
  final isLoading = false.obs;
  final isAdmin = false.obs;
  final userId = ''.obs;

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
    await loadShifts();
  }

  Future<void> loadShifts() async {
    isLoading.value = true;
    try {
      await Get.showOverlay(
        loadingWidget: const LoadingCharging(),
        asyncFunction: () async {
          openShifts.clear();
          closedShifts.clear();

          if (isAdmin.value) {
            final openList = await _repository.getShiftsByStatus('OPEN');
            final closedList = await _repository.getShiftsByStatus('CLOSED');
            openShifts.addAll(openList);
            closedShifts.addAll(closedList);
          } else {
            final allShifts = await _repository.getShiftsByCashier(userId.value);
            openShifts.addAll(
              allShifts.where((s) => s.status == 'OPEN').toList(),
            );
            closedShifts.addAll(
              allShifts.where((s) => s.status == 'CLOSED').toList(),
            );
          }
        },
      );
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ShiftSummary?> getShiftSummary(String shiftId) async {
    try {
      return await _repository.getShiftSummary(shiftId);
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
      return null;
    }
  }

  Future<bool> reconcileShift(String shiftId) async {
    try {
      await _repository.reconcileShift(shiftId);
      await loadShifts();
      return true;
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
      return false;
    }
  }
}
