/// Representa una zona de impresion local (p. ej. "Jugos", "Caliente", "Caja").
/// Cada zona agrupa un nombre descriptivo con una IP y un puerto. Las
/// categorias se asignan a una zona en lugar de configurar IP/puerto
/// individualmente. La zona "Caja" se deriva automaticamente de la
/// configuracion de red activa y no se persiste.
class PrinterZoneModel {
  /// ID local unico (uuid corto o timestamp + indice).
  final String? id;
  final String? name;
  final String? ip;
  final int? port;

  /// Si es true, representa la zona "Caja" derivada de la impresora de red
  /// principal y NO se persiste: se construye en runtime desde el
  /// [NetworkPrinterModel] activo.
  final bool isCaja;

  const PrinterZoneModel({
    this.id,
    this.name,
    this.ip,
    this.port,
    this.isCaja = false,
  });

  factory PrinterZoneModel.fromJson(Map<String, dynamic> json) {
    return PrinterZoneModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      ip: json['ip'] as String?,
      port: json['port'] as int?,
      isCaja: json['isCaja'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ip': ip,
      'port': port,
      'isCaja': isCaja,
    };
  }

  PrinterZoneModel copyWith({
    String? id,
    String? name,
    String? ip,
    int? port,
    bool? isCaja,
  }) {
    return PrinterZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      isCaja: isCaja ?? this.isCaja,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrinterZoneModel &&
          other.id == id &&
          other.name == name &&
          other.ip == ip &&
          other.port == port &&
          other.isCaja == isCaja;

  @override
  int get hashCode =>
      Object.hash(id, name, ip, port, isCaja);

  @override
  String toString() =>
      'PrinterZoneModel(id: $id, name: $name, ip: $ip, port: $port, isCaja: $isCaja)';
}
