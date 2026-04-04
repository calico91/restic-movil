import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';

class ReportsRepository {
  final BaseHttpClient _httpClient;

  ReportsRepository(this._httpClient);

  Future<SalesReportResponse> getSalesReport(
    String startDate,
    String endDate,
  ) async {
    final response = await _httpClient.get(UrlPaths.getSalesReport, parameters: {
      'startDate': startDate,
      'endDate': endDate,
    });
    
    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return SalesReportResponse.fromJson(data);
  }
}
