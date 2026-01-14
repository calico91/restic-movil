class ApiError {
  final String? code;
  final String? error;
  final String? recommendation;
  final int? status;

  ApiError({
    this.code,
    this.error,
    this.recommendation,
    this.status,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      error: json['error'],
      recommendation: json['recommendation'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'recommendation': recommendation,
      'status': status,
    };
  }
}
