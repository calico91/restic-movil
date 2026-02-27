import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/cashier_user_model.dart';
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
}
