import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/table_status_model.dart';

class TablesRepository {
  final BaseHttpClient _client;

  TablesRepository(this._client);

  Future<List<TableModel>> getAvailableTables() async {
    final response = await _client.get(UrlPaths.getAvailableTables);
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }

  Future<List<TableModel>> getTables() async {
    final response = await _client.get(UrlPaths.getTablesAll);
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }

  Future<TableModel> getTableById(String id) async {
    final response = await _client.get('${UrlPaths.getTableById}/$id');
    return TableModel.fromJson(response);
  }

  Future<List<TableModel>> getTablesByStatus(String status) async {
    final response = await _client.get('${UrlPaths.getTablesByStatus}/$status');
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }

  Future<List<TableModel>> getTablesByLocation(String location) async {
    final response = await _client.get('${UrlPaths.getTablesByLocation}/$location');
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }

  Future<List<TableStatusDTO>> getStatuses() async {
    final response = await _client.get(UrlPaths.getTableStatuses);
    return (response as List).map((e) => TableStatusDTO.fromJson(e)).toList();  
  }

  Future<List<TableModel>> createTables(List<Map<String, dynamic>> tables) async {
    final response = await _client.post(UrlPaths.createTables, body: tables);   
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }

  Future<TableModel> updateTable(String id, Map<String, dynamic> table) async {
    final response = await _client.put('${UrlPaths.updateTable}/$id', body: table);
    return TableModel.fromJson(response);
  }

  Future<void> deleteTable(String id) async {
    await _client.delete('${UrlPaths.deleteTable}/$id');
  }

  Future<List<TableModel>> reserveTables(List<String> tableIds) async {
    final response = await _client.put(UrlPaths.reserveTables, body: {
      'tableIds': tableIds,
    });
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }

  Future<List<TableModel>> releaseTables(List<String> tableIds) async {
    final response = await _client.put(UrlPaths.releaseTables, body: {
      'tableIds': tableIds,
    });
    return (response as List).map((e) => TableModel.fromJson(e)).toList();      
  }
}
