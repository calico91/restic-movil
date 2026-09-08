import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/data/models/api_error.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';

typedef SubscriptionGuardCallback = void Function(SubscriptionGuardException error);


class BaseHttpClient {
  final StorageService _storageService = Get.find<StorageService>();
  static final List<SubscriptionGuardCallback> _guardCallbacks = [];

  BaseHttpClient();

  static void addSubscriptionGuardCallback(SubscriptionGuardCallback cb) {
    _guardCallbacks.add(cb);
  }

  static void clearSubscriptionGuardCallbacks() {
    _guardCallbacks.clear();
  }

  static void _notifySubscriptionGuard(SubscriptionGuardException error) {
    for (final cb in List<SubscriptionGuardCallback>.from(_guardCallbacks)) {
      try {
        cb(error);
      } catch (_) {}
    }
  }

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
    Future<http.Response> Function() requestFn,
  ) async {
    try {
      final response = await requestFn().timeout(const Duration(seconds: 30));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No hay conexión a internet', '');
    } on TimeoutException {
      throw ApiNotRespondingException(
        'El servidor tardó demasiado en responder. ',
        '',
      );
    } catch (e) {
      if (e is HttpException) rethrow;
      throw FetchDataException('Error inesperado: $e', '');
    }
    
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
        case 402:
          _throwSubscriptionError(jsonResponse, url, errorMessage);
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

  Never _throwSubscriptionError(dynamic jsonResponse, String url, String fallbackMessage) {
    String? errorCode;
    String? suspendedReason;
    String? status;
    DateTime? trialEndsAt;
    int? graceDays;
    DateTime? tenantSince;
    String message = fallbackMessage;

    if (jsonResponse is Map<String, dynamic>) {
      errorCode = jsonResponse['error'] as String?;
      suspendedReason = jsonResponse['suspendedReason'] as String?;
      status = jsonResponse['status'] as String?;
      if (jsonResponse['trialEndsAt'] is String) {
        trialEndsAt = DateTime.tryParse(jsonResponse['trialEndsAt'] as String);
      }
      if (jsonResponse['graceDays'] is int) {
        graceDays = jsonResponse['graceDays'] as int;
      }
      if (jsonResponse['tenantSince'] is String) {
        tenantSince = DateTime.tryParse(jsonResponse['tenantSince'] as String);
      }
      if (jsonResponse['message'] is String) {
        message = jsonResponse['message'] as String;
      }
    }

    if (errorCode == 'SUBSCRIPTION_REQUIRED') {
      final error = SubscriptionRequiredException(
        message: message,
        url: url,
        body: jsonResponse,
        graceDays: graceDays ?? 0,
        tenantSince: tenantSince,
      );
      _notifySubscriptionGuard(error);
      throw error;
    }
    final suspended = SubscriptionSuspendedException(
      message: message,
      url: url,
      body: jsonResponse,
      status: status ?? 'SUSPENDED',
      suspendedReason: suspendedReason,
      trialEndsAt: trialEndsAt,
    );
    _notifySubscriptionGuard(suspended);
    throw suspended;
  }
}
