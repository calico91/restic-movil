class TableStatusDTO {
  final String name;
  final String description;

  TableStatusDTO({
    required this.name,
    required this.description,
  });

  factory TableStatusDTO.fromJson(Map<String, dynamic> json) {
    return TableStatusDTO(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
