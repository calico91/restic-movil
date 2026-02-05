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
}
