import 'package:restic_movil/app/data/models/printer_zone_model.dart';
import 'package:restic_movil/app/data/models/subcategory_model.dart';
export 'package:restic_movil/app/data/models/subcategory_model.dart';
export 'package:restic_movil/app/data/models/product_model.dart';
export 'package:restic_movil/app/data/models/price_model.dart';
export 'package:restic_movil/app/data/models/combo_group_model.dart';
export 'package:restic_movil/app/data/models/combo_option_model.dart';

class CategoryModel {
  final String? id;
  final String? name;
  final String? description;
  final PrinterZoneModel? printerZone;
  final List<SubcategoryModel>? subcategories;

  CategoryModel({this.id, this.name, this.description, this.printerZone, this.subcategories});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      printerZone: json['printerZone'] != null
          ? PrinterZoneModel.fromJson(json['printerZone'])
          : null,
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
                .map((e) => SubcategoryModel.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'printerZone': printerZone?.toJson(),
      'subcategories': subcategories?.map((e) => e.toJson()).toList(),
    };
  }
}
