import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/product_sales_report_response.dart';
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

  /// Reporte de ventas por productos seleccionados en un rango de fecha-hora.
  /// Devuelve el detalle por producto, incluyendo el listado de eventos de venta
  /// con la hora exacta de cada uno.
  Future<ProductSalesReportResponse> getProductSalesReport(
    String startDateTime,
    String endDateTime,
    List<String> productIds,
  ) async {
    final parameters = <String, String>{
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'productIds': productIds.join(','),
    };

    final response = await _httpClient.get(
      UrlPaths.getProductSalesReport,
      parameters: parameters,
    );

    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return ProductSalesReportResponse.fromJson(data);
  }

  /// Reporte ranking de productos mas vendidos en un rango de fecha-hora.
  /// Solo incluye productos con ventas, ordenados por unidades descendente.
  Future<ProductSalesReportResponse> getTopProductsReport(
    String startDateTime,
    String endDateTime,
  ) async {
    final response = await _httpClient.get(
      UrlPaths.getTopProductsReport,
      parameters: {
        'startDateTime': startDateTime,
        'endDateTime': endDateTime,
      },
    );

    final Map<String, dynamic> data =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;

    return ProductSalesReportResponse.fromJson(data);
  }
}
