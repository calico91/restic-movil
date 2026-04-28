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
}
