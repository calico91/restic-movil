import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/category_model.dart';

class CategoriesRepository {
  final BaseHttpClient _client;

  CategoriesRepository(this._client);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(UrlPaths.getCategories);
      return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    try {
      await _client.post(UrlPaths.createCategories, body: [data]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _client.put('${UrlPaths.updateCategory}/$id', body: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSubcategory(Map<String, dynamic> data) async {
    try {
      await _client.post(UrlPaths.createSubcategories, body: [data]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubcategory(String id, Map<String, dynamic> data) async {
    try {
      await _client.put('${UrlPaths.updateSubcategory}/$id', body: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await _client.post(UrlPaths.createProducts, body: [data]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _client.put('${UrlPaths.updateProduct}/$id', body: data);
    } catch (e) {
      rethrow;
    }
  }

  /* Actualizar la impresora asignada a una categoria; enviar ip=null para eliminarla */
  Future<CategoryModel> updateCategoryPrinter(
    String id, {
    required String? printerIp,
    required int? printerPort,
  }) async {
    try {
      final response = await _client.patch(
        '${UrlPaths.updateCategoryPrinter}/$id/printer',
        body: {'printerIp': printerIp, 'printerPort': printerPort},
      );
      return CategoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
