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

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final response = await _client.post(
        UrlPaths.createCustomer,
        body: customer.toJson(),
      );
      return CustomerModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final response = await _client.put(
        '${UrlPaths.updateCustomer}/${customer.id}',
        body: customer.toJson(),
      );
      return CustomerModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _client.delete('${UrlPaths.deleteCustomer}/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final response = await _client.get('${UrlPaths.getCustomerById}/$id');
      return CustomerModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
