import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';

class PaymentMethodsRepository {
  final BaseHttpClient _client;

  PaymentMethodsRepository(this._client);

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _client.get(UrlPaths.getPaymentMethods);

    final List<PaymentMethodModel> methods = (response as List)
        .map((e) => PaymentMethodModel.fromJson(e))
        .toList();

    return methods;
  }
}
