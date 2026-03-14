import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_payment_source.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_reason.dart';
import 'package:restic_movil/app/data/models/create_cash_withdrawal_request.dart';

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
}
