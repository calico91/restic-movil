import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/category_model.dart';

class CategoriesRepository {
  final BaseHttpClient _client;

  CategoriesRepository(this._client);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(UrlPaths.getCategories);
      if (response != null && response is List) {
        return (response).map((e) => CategoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // In a real app, you might want to throw a custom exception or handle it better
      rethrow;
    }
  }
}
