import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/customer_model.dart';

class CustomerRepository {
  final BaseHttpClient _client;

  CustomerRepository(this._client);

  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await _client.get(UrlPaths.getCustomers);
      return (response as List).map((e) => CustomerModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
