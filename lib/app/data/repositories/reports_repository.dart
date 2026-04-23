import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/models/shift_sales_report_response.dart';

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

  Future<SalesReportResponse> getSalesReportByDateTime(
    String startDateTime,
    String endDateTime,
  ) async {
    final response = await _httpClient.get(UrlPaths.getSalesReportByDateTime, parameters: {
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    });
    
    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return SalesReportResponse.fromJson(data);
  }

  Future<ShiftSalesReportResponse> getSalesReportByShiftId(String shiftId) async {
    final response = await _httpClient.get('${UrlPaths.getSalesReportByShift}/$shiftId');
    
    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return ShiftSalesReportResponse.fromJson(data);
  }

  Future<ShiftSalesReportResponse> getSalesReportByShiftDate(String openDate) async {
    final response = await _httpClient.get(UrlPaths.getSalesReportByShift, parameters: {
      'openDate': openDate,
    });
    
    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return ShiftSalesReportResponse.fromJson(data);
  }
}
