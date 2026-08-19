/// Configuración de una impresora térmica conectada por red (TCP/IP).
class NetworkPrinterModel {
  final String name;
  final String ip;
  final int port;

  const NetworkPrinterModel({
    required this.name,
    required this.ip,
    required this.port,
  });

  factory NetworkPrinterModel.fromJson(Map<String, dynamic> json) {
    return NetworkPrinterModel(
      name: json['name'] as String,
      ip: json['ip'] as String,
      port: json['port'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'ip': ip,
        'port': port,
      };

  // Igualdad basada en IP, puerto y nombre para que funcione como clave de Map.
  // Incluir `name` permite distinguir varias zonas con la misma IP:puerto
  // (util durante pruebas con una sola impresora fisica), generando un
  // ticket por zona en lugar de colapsarlos en uno solo.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkPrinterModel &&
          other.ip == ip &&
          other.port == port &&
          other.name == name;

  @override
  int get hashCode => Object.hash(ip, port, name);

  @override
  String toString() => 'NetworkPrinterModel($name, $ip:$port)';
}
