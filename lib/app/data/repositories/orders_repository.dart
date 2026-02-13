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

  Future<void> createOrder(Map<String, dynamic> data) async {
    await _client.post(UrlPaths.createOrder, body: data);
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

  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final response = await _client.get('${UrlPaths.getOrdersByStatus}/$status');
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

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.put(
      '${UrlPaths.updateOrderStatus}/$orderId',
      parameters: {'status': status},
    );
  }
}
