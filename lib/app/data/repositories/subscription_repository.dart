import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/subscription_invoice_model.dart';
import 'package:restic_movil/app/data/models/subscription_model.dart';
import 'package:restic_movil/app/data/models/subscription_status_model.dart';

class SubscriptionRepository {
  final BaseHttpClient _client;

  SubscriptionRepository(this._client);

  Future<SubscriptionStatusModel?> getStatus() async {
    try {
      final response = await _client.get(UrlPaths.getSubscriptionStatus);
      if (response is Map<String, dynamic>) {
        return SubscriptionStatusModel.fromJson(response);
      }
      return null;
    } catch (e) {
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  Future<SubscriptionModel> startTrial({String billingCycle = 'MONTHLY'}) async {
    final response = await _client.post(
      UrlPaths.startTrial,
      body: {'billingCycle': billingCycle},
    );
    return SubscriptionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<SubscriptionInvoiceModel>> getInvoices() async {
    final response = await _client.get(UrlPaths.getSubscriptionInvoices);
    if (response is List) {
      return response
          .map((e) => SubscriptionInvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<SubscriptionInvoiceModel> getInvoiceById(String id) async {
    final response = await _client.get('${UrlPaths.getSubscriptionInvoices}/$id');
    return SubscriptionInvoiceModel.fromJson(response as Map<String, dynamic>);
  }

  bool isSubscriptionRequiredError(Object error) =>
      error is SubscriptionRequiredException;

  bool isSubscriptionSuspendedError(Object error) =>
      error is SubscriptionSuspendedException;
}