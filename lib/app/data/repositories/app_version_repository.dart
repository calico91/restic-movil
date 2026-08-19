import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/app_version_info.dart';

class AppVersionRepository {
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  AppVersionRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Descarga el JSON central de version probando una lista de URLs en orden.
  /// La primera URL viene de `APP_VERSION_CHECK_URL` (CDN primario, recomendado
  /// jsDelivr) y la(s) siguiente(s) de `APP_VERSION_CHECK_URL_FALLBACK`
  /// (CDNs secundarios como raw.githubusercontent.com). Si todas fallan o
  /// ninguna esta configurada, lanza una excepcion. El splash trata cualquier
  /// excepcion como fail-open (no bloquea la app).
  Future<AppVersionInfo> getAppVersionInfo() async {
    final urls = <String>[
      dotenv.env['APP_VERSION_CHECK_URL'] ?? '',
      dotenv.env['APP_VERSION_CHECK_URL_FALLBACK'] ?? '',
    ].where((u) => u.isNotEmpty).toList();

    debugPrint('version check urls cargadas: ${urls.length}');
    if (urls.isEmpty) {
      throw Exception('APP_VERSION_CHECK_URL no esta configurada');
    }

    Object? lastError;
    for (final url in urls) {
      try {
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
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Version check fallo para todas las URLs');
  }
}