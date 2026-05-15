import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/data/models/api_error.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';

class BaseHttpClient {
  final StorageService _storageService = Get.find<StorageService>();

  BaseHttpClient();

  Future<dynamic> get(String path, {Map<String, String>? parameters}) async {
    return _executeRequest(() async {
      final uri = await _buildUriAsync(path, parameters);
      final headers = await _getHeaders();
      return http.get(uri, headers: headers);
    });
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? parameters,
  }) async {
    return _executeRequest(() async {
      final uri = await _buildUriAsync(path, parameters);
      final headers = await _getHeaders();
      return http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    });
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? parameters,
  }) async {
    return _executeRequest(() async {
      final uri = await _buildUriAsync(path, parameters);
      final headers = await _getHeaders();
      return http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    });
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? parameters,
  }) async {
    return _executeRequest(() async {
      final uri = await _buildUriAsync(path, parameters);
      final headers = await _getHeaders();
      return http.patch(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    });
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? parameters,
  }) async {
    return _executeRequest(() async {
      final uri = await _buildUriAsync(path, parameters);
      final headers = await _getHeaders();
      return http.delete(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    });
  }

  Future<Uri> _buildUriAsync(
    String path,
    Map<String, String>? parameters,
  ) async {
    if (path.startsWith('http')) {
      return Uri.parse(path).replace(queryParameters: parameters);
    }

    final serverUrl = await _storageService.getServerUrl();
    if (serverUrl == null || serverUrl.isEmpty) {
      throw FetchDataException('Debe configurar la conexión al servidor', '');
    }

    final String baseUrlStr = serverUrl.startsWith('http')
        ? serverUrl
        : 'https://$serverUrl';
    final String cleanUrl = baseUrlStr.endsWith('/')
        ? baseUrlStr.substring(0, baseUrlStr.length - 1)
        : baseUrlStr;
    final String cleanPath = path.startsWith('/') ? path : '/$path';

    final String finalUrl = '$cleanUrl/api$cleanPath';

    final baseUri = Uri.parse(finalUrl);
    if (parameters != null) {
      return baseUri.replace(queryParameters: parameters);
    }
    return baseUri;
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Clave de aplicacion que identifica el origen como la app movil
    final String apiKey = dotenv.env['APP_API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      headers['X-App-Key'] = apiKey;
    }

    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final branchId = await _storageService.getBranchId();
    if (branchId != null && branchId.isNotEmpty) {
      headers['X-Branch-Id'] = branchId;
    }

    return headers;
  }

  Future<dynamic> _executeRequest(
    Future<http.Response> Function() requestFn, {
    int retries = 2,
    Duration delayBetweenRetries = const Duration(seconds: 1),
  }) async {
    final int maxAttempts = retries + 1;
    int wakeUpAttempts = 0;
    const int maxWakeUpAttempts = 8; // Límite máximo estricto para evitar ciclos infinitos en códigos >= 500

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await requestFn().timeout(const Duration(seconds: 30));

        if (response.statusCode >= 500 && wakeUpAttempts < maxWakeUpAttempts) {
          wakeUpAttempts++;
          
          if (attempt == maxAttempts) attempt--; // Evita salir del loop normal si seguimos reintentando el 500
          
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }

        return _processResponse(response);
      } on SocketException {
        if (attempt == maxAttempts) {
          throw FetchDataException('No hay conexión a internet', '');
        }
        await Future.delayed(delayBetweenRetries);
      } on TimeoutException {
        if (attempt == maxAttempts) {
          throw ApiNotRespondingException(
            'El servidor tardó demasiado en responder',
            '',
          );
        }
        await Future.delayed(delayBetweenRetries);
      } catch (e) {
        if (e is HttpException) rethrow;
        
        if (attempt == maxAttempts) {
          throw FetchDataException('Error inesperado: $e', '');
        }
        await Future.delayed(delayBetweenRetries);
      }
    }
    
    throw FetchDataException('Error desconocido en la comunicación', '');
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final jsonResponse = _decodeBody(response.body);
    final url = response.request?.url.toString() ?? '';

    if (statusCode >= 200 && statusCode < 300) {
      return jsonResponse;
    } else {
      String errorMessage = 'Error desconocido';

      if (jsonResponse is Map<String, dynamic>) {
        // Parse custom ApiError
        try {
          final apiError = ApiError.fromJson(jsonResponse);
          errorMessage =
              apiError.error ??
              apiError.recommendation ??
              'Error en la petición';
              
          if (apiError.code == 'E2') {
            _storageService.deleteToken();
            _storageService.deleteUser();
            Get.offAllNamed(Routes.LOGIN);
          }
        } catch (_) {
          errorMessage =
              jsonResponse['error'] ?? jsonResponse['message'] ?? response.body;
        }
      }

      switch (statusCode) {
        case 400:
          throw BadRequestException(errorMessage, url, jsonResponse);
        case 401:
        case 403:
          throw UnauthorizedException(errorMessage, url, jsonResponse);
        case 404:
          throw NotFoundException(errorMessage, url, jsonResponse);
        case 500:
        default:
          throw FetchDataException(errorMessage, url, jsonResponse);
      }
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return json.decode(body);
    } catch (e) {
      return body;
    }
  }
}
