import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_payment_source.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_reason.dart';
import 'package:restic_movil/app/data/models/create_cash_withdrawal_request.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CashWithdrawalsRepository {
  final BaseHttpClient _client;

  CashWithdrawalsRepository(this._client);

  /// Obtiene los motivos de retiro de caja
  Future<List<CashWithdrawalReason>> getReasons() async {
    try {
      final response = await _client.get(UrlPaths.getCashWithdrawalReasons);
      return (response as List)
          .map((e) => CashWithdrawalReason.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene las fuentes de pago
  Future<List<CashWithdrawalPaymentSource>> getPaymentSources() async {
    try {
      final response = await _client.get(
        UrlPaths.getCashWithdrawalPaymentSources,
      );
      return (response as List)
          .map((e) => CashWithdrawalPaymentSource.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Registra un nuevo retiro de caja (Egreso)
  Future<void> createWithdrawal(CreateCashWithdrawalRequest request) async {
    try {
      await _client.post(UrlPaths.createCashWithdrawal, body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashWithdrawal>> getWithdrawalsByShift(String shiftId) async {
    try {
      final response =
          await _client.get('${UrlPaths.getCashWithdrawalsByShift}/$shiftId');
      return (response as List)
          .map((e) => CashWithdrawal.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashWithdrawal>> getAllWithdrawals() async {
    try {
      final response = await _client.get(UrlPaths.getAllCashWithdrawals);
      return (response as List)
          .map((e) => CashWithdrawal.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CashWithdrawal>> getWithdrawalHistory({
    String? startDate,
    String? endDate,
    String? reason,
    String? userId,
  }) async {
    try {
      final params = <String, String>{};
      if (startDate != null) params['startDate'] = startDate;
      if (endDate != null) params['endDate'] = endDate;
      if (reason != null) params['reason'] = reason;
      if (userId != null) params['userId'] = userId;

      final response = await _client.get(
        UrlPaths.getCashWithdrawalHistory,
        parameters: params,
      );
      return (response as List)
          .map((e) => CashWithdrawal.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> downloadHistoryCsv({
    String? startDate,
    String? endDate,
    String? reason,
    String? userId,
  }) async {
    try {
      final storageService = Get.find<StorageService>();
      final serverUrl = await storageService.getServerUrl() ?? '';
      final cleanUrl = serverUrl.startsWith('http') ? serverUrl : 'http://$serverUrl';
      final cleanBase = cleanUrl.endsWith('/')
          ? cleanUrl.substring(0, cleanUrl.length - 1)
          : cleanUrl;
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (reason != null) queryParams['reason'] = reason;
      if (userId != null) queryParams['userId'] = userId;

      final uri = Uri.parse('$cleanBase/api/${UrlPaths.exportCashWithdrawals}')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final headers = <String, String>{
        'Accept': 'text/csv; charset=UTF-8',
      };
      final apiKey = dotenv.env['APP_API_KEY'] ?? '';
      if (apiKey.isNotEmpty) headers['X-App-Key'] = apiKey;
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final branchId = await storageService.getBranchId();
      if (branchId != null && branchId.isNotEmpty) {
        headers['X-Branch-Id'] = branchId;
      }

      final response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        final errorBody = _decodeBody(response.body);
        String errorMessage = 'Error descargando CSV';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['error'] ?? errorBody['message'] ?? errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error descargando CSV: $e');
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return json.decode(body);
    } catch (e) {
      return body;
    }
  }
}
