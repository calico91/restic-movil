import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/user_model.dart';

class UsersRepository {
  final BaseHttpClient _httpClient;

  UsersRepository(this._httpClient);

  Future<List<UserModel>> getUsers() async {
    final response = await _httpClient.get(UrlPaths.getUsers);

    // The response could be a map wrapping the list or the list itself
    final List<dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<List<UserRole>> getRoles() async {
    final response = await _httpClient.get(UrlPaths.getRoles);
    final List<dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return data.map((item) => UserRole.fromJson(item)).toList();
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await _httpClient.post(
      UrlPaths.createUser,
      body: userData,
    );
    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return UserModel.fromJson(data);
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await _httpClient.put(
      '${UrlPaths.updateUser}/$id',
      body: userData,
    );
    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return UserModel.fromJson(data);
  }
}
