import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/cashier_user_model.dart';
import 'package:restic_movil/app/data/models/cashier_shift.dart';
import 'package:restic_movil/app/data/models/shift_summary.dart';
import 'package:restic_movil/app/data/models/shift_status.dart';
import 'package:restic_movil/app/data/models/terminal_model.dart';

class CashierRepository {
  final BaseHttpClient _client;

  CashierRepository(this._client);

  Future<List<CashierUser>> getAdminAndCashierUsers() async {
    try {
      final response = await _client.get(UrlPaths.getAdminAndCashierUsers);
      return (response as List).map((e) => CashierUser.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Terminal>> getTerminals() async {
    try {
      final response = await _client.get(UrlPaths.getTerminals);
      return (response as List).map((e) => Terminal.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> openShift({
    required String cashierId,
    required double initialAmount,
    required String terminalId,
    String? remarks,
  }) async {
    try {
      await _client.post(
        UrlPaths.openCashierShift,
        body: {
          'cashierId': cashierId,
          'initialAmount': initialAmount,
          'terminalId': terminalId,
          'remarks': remarks,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> closeShift({
    required String cashierId,
    required double declaredCashAmount,
    String? remarks,
  }) async {
    try {
      final response = await _client.put(
        '${UrlPaths.closeCashierShift}/$cashierId',
        body: {
          "declaredCashAmount": declaredCashAmount,
          if (remarks != null && remarks.isNotEmpty) "remarks": remarks,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierShift> getShiftById(String shiftId) async {
    try {
      final response = await _client.get('${UrlPaths.getCashierShift}/$shiftId');
      return CashierShift.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashierShift>> getAllShifts() async {
    try {
      final response = await _client.get(UrlPaths.getAllCashierShifts);
      return (response as List).map((e) => CashierShift.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashierShift>> getShiftsByStatus(String status) async {
    try {
      final response =
          await _client.get('${UrlPaths.getCashierShiftsByStatus}/$status');
      return (response as List).map((e) => CashierShift.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashierShift>> getShiftsByCashier(String cashierId) async {
    try {
      final response =
          await _client.get('${UrlPaths.getCashierShiftsByCashier}/$cashierId');
      return (response as List).map((e) => CashierShift.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierShift> getActiveShiftByTerminal(String terminalId) async {
    try {
      final response =
          await _client.get('${UrlPaths.getActiveShiftByTerminal}/$terminalId');
      return CashierShift.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ShiftSummary> getShiftSummary(String shiftId) async {
    try {
      final response =
          await _client.get('${UrlPaths.getCashierShiftSummary}/$shiftId/summary');
      return ShiftSummary.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ShiftStatus>> getShiftStatuses() async {
    try {
      final response = await _client.get(UrlPaths.getCashierShiftStatuses);
      return (response as List)
          .map((e) => ShiftStatus.fromString(e['name']))
          .whereType<ShiftStatus>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CashierShift> reconcileShift(String shiftId) async {
    try {
      final response =
          await _client.put('${UrlPaths.reconcileCashierShift}/$shiftId/reconcile');
      return CashierShift.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
