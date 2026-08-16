class ResetPasswordResponse {
  final String temporaryPassword;

  ResetPasswordResponse({required this.temporaryPassword});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      temporaryPassword: json['temporaryPassword'] as String? ?? '',
    );
  }
}
