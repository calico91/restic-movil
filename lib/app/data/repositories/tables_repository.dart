import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/table_model.dart';

class TablesRepository {
  final BaseHttpClient _client;

  TablesRepository(this._client);

  Future<List<TableModel>> getAvailableTables() async {
    final response = await _client.get(UrlPaths.getAvailableTables);
    return (response as List).map((e) => TableModel.fromJson(e)).toList();
  }
}
