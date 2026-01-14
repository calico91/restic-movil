import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/login_response.dart';

class AuthRepository {
  final BaseHttpClient _client;

  AuthRepository(this._client);

  Future<LoginResponse> login(String username, String password) async {
    final response = await _client.post(
      UrlPaths.signIn,
      body: {'username': username, 'password': password},
    );
    return LoginResponse.fromJson(response);
  }
}
