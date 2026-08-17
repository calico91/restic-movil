import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/app_version_info.dart';

class AppVersionRepository {
  static const Duration _timeout = Duration(seconds: 5);

  final http.Client _client;

  AppVersionRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Descarga el JSON central de version desde la URL configurada en
  /// `.env` como `APP_VERSION_CHECK_URL`. Lanza una excepcion si la
  /// URL no esta configurada, si la peticion falla o si la respuesta
  /// no es un JSON valido. El splash maneja cualquier excepcion como
  /// fail-open (no bloquea la app).
  Future<AppVersionInfo> getAppVersionInfo() async {
    final url = dotenv.env['APP_VERSION_CHECK_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('APP_VERSION_CHECK_URL no esta configurada');
    }

    final response = await _client.get(Uri.parse(url)).timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Version check respondio con status ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Version check devolvio un JSON no valido');
    }

    return AppVersionInfo.fromJson(decoded);
  }
}
