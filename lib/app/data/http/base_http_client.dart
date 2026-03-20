import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/data/models/api_error.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';

class BaseHttpClient {
  static const String _baseUrl = 'http://192.168.0.103:8093/api/';
  final StorageService _storageService = Get.find<StorageService>();

  BaseHttpClient();

  Future<dynamic> get(String path, {Map<String, String>? parameters}) async {
    return _executeRequest(() async {
      final uri = _buildUri(path, parameters);
      final headers = await _getHeaders();
      return http.get(uri, headers: headers);
    });
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? parameters,
  }) async {
    debugPrint(
      'POST request to $path with body: $body and parameters: $parameters',
    );

    return _executeRequest(() async {
      final uri = _buildUri(path, parameters);
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
    debugPrint(
      'PUT request to $path with body: $body and parameters: $parameters',
    );

    return _executeRequest(() async {
      final uri = _buildUri(path, parameters);
      final headers = await _getHeaders();
      return http.put(
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
      final uri = _buildUri(path, parameters);
      final headers = await _getHeaders();
      return http.delete(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    });
  }

  Uri _buildUri(String path, Map<String, String>? parameters) {
    if (path.startsWith('http')) {
      return Uri.parse(path).replace(queryParameters: parameters);
    }

    final String cleanUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final String cleanPath = path.startsWith('/') ? path : '/$path';

    final baseUri = Uri.parse(cleanUrl + cleanPath);
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
        'El servidor tardó demasiado en responder',
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
