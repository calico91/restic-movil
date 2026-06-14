import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/data/models/product_recipe_model.dart';
import 'package:restic_movil/app/data/models/stock_movement_model.dart';

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
}
