import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/order_model.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';

class OrdersRepository {
  final BaseHttpClient _client;

  OrdersRepository(this._client);

  Future<List<OriginType>> getOriginTypes() async {
    final response = await _client.get(UrlPaths.getOriginTypes);
    return (response as List).map((e) => OriginType.fromJson(e)).toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final response = await _client.post(UrlPaths.createOrder, body: data);
    return OrderModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> addOrderItems(
    String orderId,
    List<Map<String, dynamic>> products,
  ) async {
    await _client.put(
      '${UrlPaths.addProductsToOrder}/$orderId/add-products',
      body: {'products': products},
    );
  }

  Future<List<OrderModel>> getOrdersByStatuses(
    List<String> statuses, {
    String? date,
  }) async {
    final Map<String, String> params = {'statuses': statuses.join(',')};
    if (date != null) params['date'] = date;
    final response = await _client.get(
      UrlPaths.getOrdersByStatuses,
      parameters: params,
    );
    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getOrderStatuses() async {
    final response = await _client.get(UrlPaths.getOrderStatuses);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getOrderDetailStatuses() async {
    final response = await _client.get(UrlPaths.getOrderDetailStatuses);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateOrderDetailsStatus(
    List<Map<String, dynamic>> items,
    String status,
  ) async {
    final data = {'details': items, 'status': status};
    await _client.put(UrlPaths.updateOrderDetailStatus, body: data);
  }

  Future<void> updateOrderSurcharges(String orderId, List<Map<String, dynamic>> surcharges) async {
    await _client.put(
      'orders/$orderId/surcharges',
      body: surcharges,
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.put(
      '${UrlPaths.updateOrderStatus}/$orderId',
      parameters: {'status': status},
    );
  }
}
