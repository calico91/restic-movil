// Modelo con la información básica del usuario que creó la orden (mesero)
class UserSummaryModel {
  final String? id;
  final String? name;
  final String? lastName;

  const UserSummaryModel({
    this.id,
    this.name,
    this.lastName,
  });

  // Retorna el nombre completo del usuario
  String get fullName {
    final String first = name ?? '';
    final String last = lastName ?? '';
    return '$first $last'.trim();
  }

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: json['id']?.toString(),
      name: json['name'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
    };
  }
}
