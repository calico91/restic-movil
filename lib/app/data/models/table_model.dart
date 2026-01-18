class TableModel {
  final String? id;
  final String? name;
  final String? status;
  final String? location;
  final String? branchId;

  TableModel({
    this.id,
    this.name,
    this.status,
    this.location,
    this.branchId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      location: json['location'],
      branchId: json['branch_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'location': location,
      'branch_id': branchId,
    };
  }
}
