import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/fiscal_data_model.dart';

class FiscalDataRepository {
  final BaseHttpClient _client;

  FiscalDataRepository(this._client);

  Future<FiscalDataModel?> getActiveFiscalData() async {
    try {
      final response = await _client.get(
        UrlPaths.fiscalDataActive,
      );
      if (response != null) {
        return FiscalDataModel.fromJson(response);
      }
      return null;
    } catch (e) {
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  Future<FiscalDataModel> createFiscalData(FiscalDataModel data) async {
    try {
      final response = await _client.post(
        UrlPaths.fiscalDataCreate,
        body: data.toJson(),
      );
      return FiscalDataModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FiscalDataModel> updateFiscalData(
    String id,
    FiscalDataModel data,
  ) async {
    try {
      final response = await _client.put(
        '${UrlPaths.fiscalDataUpdate}/$id',
        body: data.toJson(),
      );
      return FiscalDataModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
