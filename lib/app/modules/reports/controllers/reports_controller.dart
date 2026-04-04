import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/repositories/reports_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class ReportsController extends GetxController {
  final ReportsRepository _repository;

  ReportsController(this._repository);

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  final Rx<SalesReportResponse?> reportData = Rx<SalesReportResponse?>(null);

  @override
  void onReady() {
    super.onReady();
    // Default: fetch today's report
    fetchSalesReport();
  }

  void setDates(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
  }

  /* Consume el servicio para obtener el reporte de ventas dadas las fechas */
  Future<void> fetchSalesReport() async {
    final startStr = DateFormat('yyyy-MM-dd').format(startDate.value);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate.value);

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final data = await _repository.getSalesReport(startStr, endStr);
          reportData.value = data;
        } catch (e) {
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
