import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/printer_zone_model.dart';

class PrinterZoneRepository {
  final BaseHttpClient _client;

  PrinterZoneRepository(this._client);

  Future<List<PrinterZoneModel>> getAll() async {
    try {
      final response = await _client.get(UrlPaths.getPrintZones);
      return (response as List)
          .map((e) => PrinterZoneModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PrinterZoneModel> create({
    required String name,
    required String ip,
    required int port,
  }) async {
    try {
      final response = await _client.post(
        UrlPaths.createPrintZone,
        body: {'name': name, 'ip': ip, 'port': port},
      );
      return PrinterZoneModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<PrinterZoneModel> update({
    required String id,
    required String name,
    required String ip,
    required int port,
  }) async {
    try {
      final response = await _client.put(
        '${UrlPaths.updatePrintZone}/$id',
        body: {'name': name, 'ip': ip, 'port': port},
      );
      return PrinterZoneModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.delete('${UrlPaths.deletePrintZone}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
