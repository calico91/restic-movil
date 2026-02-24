import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
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
}
