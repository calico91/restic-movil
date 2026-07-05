import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';

class CombosRepository {
  final BaseHttpClient _client;

  CombosRepository(this._client);

  Future<void> addOption(String groupId, String productId) async {
    await _client.post(
      '${UrlPaths.addComboOption}/$groupId/options',
      body: {'productId': productId},
    );
  }

  Future<void> removeOption(String optionId) async {
    await _client.delete('${UrlPaths.removeComboOption}/$optionId');
  }

  Future<void> toggleOption(String optionId) async {
    await _client.patch('${UrlPaths.toggleComboOption}/$optionId/toggle');
  }
}
