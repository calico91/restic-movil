import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';

class ProfileRepository {
  final BaseHttpClient _httpClient;

  ProfileRepository(this._httpClient);

  Future<void> changeMyPassword(String currentPassword, String newPassword) async {
    await _httpClient.patch(
      UrlPaths.changeMyPassword,
      body: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      },
    );
  }
}
