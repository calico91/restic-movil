import 'package:collection/collection.dart';

enum ShiftStatus {
  open('OPEN', 'Abierto'),
  closed('CLOSED', 'Cerrado'),
  reconciled('RECONCILED', 'Conciliado');

  final String name;
  final String description;

  const ShiftStatus(this.name, this.description);

  static ShiftStatus? fromString(String? value) {
    if (value == null) return null;
    return ShiftStatus.values.firstWhereOrNull((e) => e.name == value);
  }
}
