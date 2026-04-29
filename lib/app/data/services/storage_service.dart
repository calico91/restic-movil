import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/customer_model.dart';
import '../models/login_response.dart';
import '../models/network_printer_model.dart';

class StorageService extends GetxService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _branchIdKey = 'branch_id';
  static const _userKey = 'user_info';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveBranchId(String branchId) async {
    await _storage.write(key: _branchIdKey, value: branchId);
  }

  Future<String?> getBranchId() async {
    return await _storage.read(key: _branchIdKey);
  }

  Future<void> deleteBranchId() async {
    await _storage.delete(key: _branchIdKey);
  }

  Future<void> saveOrderOrigins(List<dynamic> origins) async {
    await _storage.write(key: 'order_origins', value: jsonEncode(origins));
  }

  Future<List<dynamic>?> getOrderOrigins() async {
    final originsStr = await _storage.read(key: 'order_origins');
    if (originsStr != null) {
      return jsonDecode(originsStr);
    }
    return null;
  }

  Future<void> deleteOrderOrigins() async {
    await _storage.delete(key: 'order_origins');
  }

  Future<void> saveOrderStatuses(List<dynamic> statuses) async {
    await _storage.write(key: 'order_statuses', value: jsonEncode(statuses));
  }

  Future<List<dynamic>?> getOrderStatuses() async {
    final str = await _storage.read(key: 'order_statuses');
    if (str != null) return jsonDecode(str);
    return null;
  }

  Future<void> deleteOrderStatuses() async {
    await _storage.delete(key: 'order_statuses');
  }

  Future<void> saveOrderDetailStatuses(List<dynamic> statuses) async {
    await _storage.write(
      key: 'order_detail_statuses',
      value: jsonEncode(statuses),
    );
  }

  Future<List<dynamic>?> getOrderDetailStatuses() async {
    final str = await _storage.read(key: 'order_detail_statuses');
    if (str != null) return jsonDecode(str);
    return null;
  }

  Future<void> deleteOrderDetailStatuses() async {
    await _storage.delete(key: 'order_detail_statuses');
  }

  Future<void> savePaymentMethods(List<dynamic> methods) async {
    await _storage.write(key: 'payment_methods', value: jsonEncode(methods));
  }

  Future<List<dynamic>?> getPaymentMethods() async {
    final str = await _storage.read(key: 'payment_methods');
    if (str != null) return jsonDecode(str);
    return null;
  }

  Future<void> deletePaymentMethods() async {
    await _storage.delete(key: 'payment_methods');
  }

  Future<void> saveTransactionTypes(List<dynamic> types) async {
    await _storage.write(key: 'transaction_types', value: jsonEncode(types));
  }

  Future<List<dynamic>?> getTransactionTypes() async {
    final str = await _storage.read(key: 'transaction_types');
    if (str != null) return jsonDecode(str);
    return null;
  }

  Future<void> deleteTransactionTypes() async {
    await _storage.delete(key: 'transaction_types');
  }

  Future<void> saveUser(LoginResponse user) async {
    final userMap = user.toJson();
    userMap.remove('token');
    await _storage.write(key: _userKey, value: jsonEncode(userMap));
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> savePrinterSize(String size) async {
    await _storage.write(key: 'printer_size', value: size);
  }

  Future<String> getPrinterSize() async {
    return await _storage.read(key: 'printer_size') ?? '58mm';
  }

  Future<LoginResponse?> getUser() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr != null) {
      return LoginResponse.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  Future<void> savePrinterDevice(String name, String address) async {
    final device = {'name': name, 'address': address};
    await _storage.write(key: 'printer_device', value: jsonEncode(device));
  }

  Future<Map<String, String>?> getPrinterDevice() async {
    final str = await _storage.read(key: 'printer_device');
    if (str != null) {
      final decoded = jsonDecode(str) as Map<String, dynamic>;
      return {
        'name': decoded['name'].toString(),
        'address': decoded['address'].toString(),
      };
    }
    return null;
  }

  // --------------- Impresora de red ---------------

  Future<void> saveNetworkPrinter(NetworkPrinterModel printer) async {
    await _storage.write(
      key: 'network_printer',
      value: jsonEncode(printer.toJson()),
    );
  }

  Future<NetworkPrinterModel?> getNetworkPrinter() async {
    final str = await _storage.read(key: 'network_printer');
    if (str != null) {
      return NetworkPrinterModel.fromJson(
        jsonDecode(str) as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> deleteNetworkPrinter() async {
    await _storage.delete(key: 'network_printer');
  }

  Future<void> saveConnectionType(String type) async {
    await _storage.write(key: 'printer_connection_type', value: type);
  }

  Future<String?> getConnectionType() async {
    return await _storage.read(key: 'printer_connection_type');
  }

  Future<void> saveDefaultTipPercentage(String percentage) async {
    await _storage.write(key: 'default_tip_percentage', value: percentage);
  }

  Future<String?> getDefaultTipPercentage() async {
    return await _storage.read(key: 'default_tip_percentage');
  }

  Future<void> saveServerUrl(String url) async {
    await _storage.write(key: 'server_url', value: url);
  }

  Future<String?> getServerUrl() async {
    return await _storage.read(key: 'server_url');
  }

  Future<void> deleteServerUrl() async {
    await _storage.delete(key: 'server_url');
  }

  Future<void> saveDefaultCustomer(CustomerModel customer) async {
    await _storage.write(
      key: 'default_customer',
      value: jsonEncode(customer.toJson()),
    );
  }

  Future<CustomerModel?> getDefaultCustomer() async {
    final str = await _storage.read(key: 'default_customer');
    if (str != null) return CustomerModel.fromJson(jsonDecode(str));
    return null;
  }

  Future<void> deleteDefaultCustomer() async {
    await _storage.delete(key: 'default_customer');
  }
}
