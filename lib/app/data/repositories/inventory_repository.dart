import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/associated_product_model.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/data/models/product_recipe_model.dart';
import 'package:restic_movil/app/data/models/stock_movement_model.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InventoryRepository {
  final BaseHttpClient _client;

  InventoryRepository(this._client);

  Future<List<InventoryItemModel>> getItems() async {
    try {
      final response = await _client.get(UrlPaths.inventoryItems);
      return (response as List)
          .map((e) => InventoryItemModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InventoryItemModel>> getAlerts() async {
    try {
      final response = await _client.get(UrlPaths.inventoryAlerts);
      return (response as List)
          .map((e) => InventoryItemModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    try {
      await _client.post(UrlPaths.inventoryItems, body: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _client.put('${UrlPaths.inventoryItems}/$id', body: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _client.delete('${UrlPaths.inventoryItems}/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AssociatedProductModel>> getAssociatedProducts(String itemId) async {
    try {
      final response = await _client.get('${UrlPaths.inventoryItemProducts}/$itemId/products');
      return (response as List)
          .map((e) => AssociatedProductModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductRecipeModel>> getRecipesForProduct(String productId) async {
    try {
      final response = await _client.get('${UrlPaths.inventoryRecipes}/$productId');
      return (response as List)
          .map((e) => ProductRecipeModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveRecipe(String productId, Map<String, dynamic> data) async {
    try {
      await _client.post('${UrlPaths.inventoryRecipes}/$productId', body: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveAllRecipes(String productId, List<Map<String, dynamic>> recipes) async {
    try {
      await _client.post(
        '${UrlPaths.inventoryRecipes}/$productId/bulk',
        body: {'recipes': recipes},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRecipe(String productId, {String? priceVariantId}) async {
    try {
      await _client.delete(
        '${UrlPaths.inventoryRecipes}/$productId',
        parameters: priceVariantId == null ? null : {'priceVariantId': priceVariantId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StockMovementModel>> getMovements({
    String? inventoryItemId,
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await _client.get(
        UrlPaths.inventoryMovements,
        parameters: {
          if (inventoryItemId != null && inventoryItemId.isNotEmpty) 'inventoryItemId': inventoryItemId,
          if (type != null && type.isNotEmpty) 'type': type,
          if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
          if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
        },
      );
      return (response as List)
          .map((e) => StockMovementModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createManualMovement(Map<String, dynamic> data) async {
    try {
      await _client.post(UrlPaths.inventoryMovements, body: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> downloadItemsCsv() async {
    try {
      final storageService = Get.find<StorageService>();
      final serverUrl = await storageService.getServerUrl() ?? '';
      final cleanUrl = serverUrl.startsWith('http') ? serverUrl : 'http://$serverUrl';
      final cleanBase = cleanUrl.endsWith('/')
          ? cleanUrl.substring(0, cleanUrl.length - 1)
          : cleanUrl;

      final uri = Uri.parse('$cleanBase/api/${UrlPaths.exportInventoryItems}');

      final headers = <String, String>{
        'Accept': 'text/csv; charset=UTF-8',
      };
      final apiKey = dotenv.env['APP_API_KEY'] ?? '';
      if (apiKey.isNotEmpty) headers['X-App-Key'] = apiKey;
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final branchId = await storageService.getBranchId();
      if (branchId != null && branchId.isNotEmpty) {
        headers['X-Branch-Id'] = branchId;
      }

      final response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        final errorBody = _decodeBody(response.body);
        String errorMessage = 'Error downloading items CSV';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['error'] ?? errorBody['message'] ?? errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error downloading items CSV: $e');
    }
  }

  Future<List<int>> downloadMovementsCsv({
    String? inventoryItemId,
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final storageService = Get.find<StorageService>();
      final serverUrl = await storageService.getServerUrl() ?? '';
      final cleanUrl = serverUrl.startsWith('http') ? serverUrl : 'http://$serverUrl';
      final cleanBase = cleanUrl.endsWith('/')
          ? cleanUrl.substring(0, cleanUrl.length - 1)
          : cleanUrl;

      final queryParams = <String, String>{};
      if (inventoryItemId != null && inventoryItemId.isNotEmpty) queryParams['inventoryItemId'] = inventoryItemId;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (fromDate != null && fromDate.isNotEmpty) queryParams['fromDate'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) queryParams['toDate'] = toDate;

      final uri = Uri.parse('$cleanBase/api/${UrlPaths.exportInventoryMovements}')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final headers = <String, String>{
        'Accept': 'text/csv; charset=UTF-8',
      };
      final apiKey = dotenv.env['APP_API_KEY'] ?? '';
      if (apiKey.isNotEmpty) headers['X-App-Key'] = apiKey;
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final branchId = await storageService.getBranchId();
      if (branchId != null && branchId.isNotEmpty) {
        headers['X-Branch-Id'] = branchId;
      }

      final response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        final errorBody = _decodeBody(response.body);
        String errorMessage = 'Error downloading movements CSV';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['error'] ?? errorBody['message'] ?? errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error downloading movements CSV: $e');
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return json.decode(body);
    } catch (e) {
      return body;
    }
  }
}
