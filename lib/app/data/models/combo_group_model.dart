import 'package:restic_movil/app/data/models/combo_option_model.dart';

class ComboGroupModel {
  final String? id;
  final String? name;
  final int? displayOrder;
  final int? minSelections;
  final int? maxSelections;
  final bool? required;
  final List<ComboOptionModel>? options;

  ComboGroupModel({
    this.id,
    this.name,
    this.displayOrder,
    this.minSelections,
    this.maxSelections,
    this.required,
    this.options,
  });

  factory ComboGroupModel.fromJson(Map<String, dynamic> json) {
    return ComboGroupModel(
      id: json['id'],
      name: json['name'],
      displayOrder: json['displayOrder'],
      minSelections: json['minSelections'],
      maxSelections: json['maxSelections'],
      required: json['required'],
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => ComboOptionModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayOrder': displayOrder,
      'minSelections': minSelections,
      'maxSelections': maxSelections,
      'required': required,
      'options': options?.map((e) => e.toJson()).toList(),
    };
  }
}
