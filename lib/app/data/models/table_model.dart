class TableModel {
  final String? id;
  final String? name;
  final String? status;
  final String? location;
  final String? branchId;
  final int? tableNumber;

  TableModel({
    this.id,
    this.name,
    this.status,
    this.location,
    this.branchId,
    this.tableNumber,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      location: json['location'],
      branchId: json['branch_id'],
      tableNumber: json['tableNumber'] ?? json['table_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'location': location,
      'branch_id': branchId,
      'tableNumber': tableNumber,
    };
  }
}
