class AppVersionInfo {
  final String? latestVersion;
  final String? minRequiredVersion;
  final String? androidStoreUrl;
  final String? iosStoreUrl;
  final String? message;

  const AppVersionInfo({
    this.latestVersion,
    this.minRequiredVersion,
    this.androidStoreUrl,
    this.iosStoreUrl,
    this.message,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: json['latestVersion'] as String?,
      minRequiredVersion: json['minRequiredVersion'] as String?,
      androidStoreUrl: json['androidStoreUrl'] as String?,
      iosStoreUrl: json['iosStoreUrl'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'minRequiredVersion': minRequiredVersion,
      'androidStoreUrl': androidStoreUrl,
      'iosStoreUrl': iosStoreUrl,
      'message': message,
    };
  }
}
