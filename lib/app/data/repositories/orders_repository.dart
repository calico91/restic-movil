import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';

class OrdersRepository {
  final BaseHttpClient _client;

  OrdersRepository(this._client);

  Future<List<OriginType>> getOriginTypes() async {
    final response = await _client.get(UrlPaths.getOriginTypes);
    return (response as List).map((e) => OriginType.fromJson(e)).toList();
  }
}
