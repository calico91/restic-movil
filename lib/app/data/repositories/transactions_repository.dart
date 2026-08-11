import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/create_transaction_request.dart';
import 'package:restic_movil/app/data/models/transaction_type_model.dart';

class TransactionsRepository {
  final BaseHttpClient _client;

  TransactionsRepository(this._client);

  Future<List<TransactionTypeModel>> getTransactionTypes() async {
    final response = await _client.get(UrlPaths.getTransactionTypes);

    final List<TransactionTypeModel> types = (response as List)
        .map((e) => TransactionTypeModel.fromJson(e))
        .toList();

    return types;
  }

  Future<Map<String, dynamic>> createTransaction(
    CreateTransactionRequest request,
  ) async {
    final response = await _client.post(
      UrlPaths.createTransaction,
      body: request.toJson(),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTransactionInvoice(String transactionId) async {
    final response = await _client.get(
      '${UrlPaths.getTransactionInvoice}/$transactionId/invoice',
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> changePaymentDetails(
    String transactionId,
    List<Map<String, dynamic>> paymentDetails, {
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'paymentDetails': paymentDetails,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };
    final response = await _client.put(
      '${UrlPaths.changeTransactionPayment}/$transactionId/payment-details',
      body: body,
    );
    return response as Map<String, dynamic>;
  }
}
