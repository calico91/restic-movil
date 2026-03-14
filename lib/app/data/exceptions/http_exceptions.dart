class HttpException implements Exception {
  const HttpException({
    required this.message,
    required this.prefix,
    required this.url,
    this.body,
  });

  final String message;
  final String prefix;
  final String url;
  final dynamic body;
}

class BadRequestException extends HttpException {
  BadRequestException([String? message, String? url, dynamic body])
    : super(
        message: message ?? '',
        prefix: 'Bad Request',
        url: url ?? '',
        body: body,
      );
}

class FetchDataException extends HttpException {
  FetchDataException([String? message, String? url, dynamic body])
    : super(
        message: message ?? '',
        prefix: 'Unable to process',
        url: url ?? '',
        body: body,
      );
}

class ApiNotRespondingException extends HttpException {
  ApiNotRespondingException([String? message, String? url, dynamic body])
    : super(
        message: message ?? '',
        prefix: 'API not responded in time',
        url: url ?? '',
        body: body,
      );
}

class UnauthorizedException extends HttpException {
  UnauthorizedException([String? message, String? url, dynamic body])
    : super(
        message: message ?? '',
        prefix: 'Unauthorized request',
        url: url ?? '',
        body: body,
      );
}

class NotFoundException extends HttpException {
  NotFoundException([String? message, String? url, dynamic body])
    : super(
        message: message ?? '',
        prefix: 'Not Found',
        url: url ?? '',
        body: body,
      );
}
