class Terminal {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String? location;
  final bool active;

  Terminal({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.location,
    required this.active,
  });

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      active: json['active'] ?? false,
    );
  }
}
