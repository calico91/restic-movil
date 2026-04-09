import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';

class PaymentMethodsRepository {
  final BaseHttpClient _client;

  PaymentMethodsRepository(this._client);

  Future<List<PaymentMethodModel>> getPaymentMethodsActive() async {
    final response = await _client.get(UrlPaths.getPaymentMethodsActive);

    final List<PaymentMethodModel> methods = (response as List)
        .map((e) => PaymentMethodModel.fromJson(e))
        .toList();

    return methods;
  }

  Future<List<PaymentMethodModel>> getPaymentMethodsAll() async {
    final response = await _client.get(UrlPaths.getPaymentMethodsAll);

    final List<PaymentMethodModel> methods = (response as List)
        .map((e) => PaymentMethodModel.fromJson(e))
        .toList();

    return methods;
  }

  Future<PaymentMethodModel> updatePaymentMethod(String methodKey, Map<String, dynamic> data) async {
    final response = await _client.put('${UrlPaths.updatePaymentMethod}/$methodKey', body: data);
    return PaymentMethodModel.fromJson(response);
  }
}
