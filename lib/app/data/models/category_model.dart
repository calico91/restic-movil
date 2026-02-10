import 'package:restic_movil/app/data/models/subcategory_model.dart';
export 'package:restic_movil/app/data/models/subcategory_model.dart';
export 'package:restic_movil/app/data/models/product_model.dart';
export 'package:restic_movil/app/data/models/price_model.dart';
export 'package:restic_movil/app/data/models/combo_group_model.dart';
export 'package:restic_movil/app/data/models/combo_option_model.dart';

class CategoryModel {
  final String? id;
  final String? name;
  final List<SubcategoryModel>? subcategories;

  CategoryModel({this.id, this.name, this.subcategories});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
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
      'subcategories': subcategories?.map((e) => e.toJson()).toList(),
    };
  }
}
