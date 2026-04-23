import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/models/shift_sales_report_response.dart';
import 'package:restic_movil/app/data/repositories/reports_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

enum ReportType {
  dateRange,
  exactDateTimeRange,
  shiftById,
  shiftByDate,
}

class ReportsController extends GetxController {
  final ReportsRepository _repository;

  ReportsController(this._repository);

  final Rx<ReportType> reportType = ReportType.dateRange.obs;

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  final Rx<DateTime> startDateTime = DateTime.now().obs;
  final Rx<DateTime> endDateTime = DateTime.now().obs;

  final TextEditingController shiftIdController = TextEditingController();

  final Rx<DateTime> singleDate = DateTime.now().obs;

  final Rx<SalesReportResponse?> reportData = Rx<SalesReportResponse?>(null);
  final Rx<ShiftSalesReportResponse?> shiftReportData = Rx<ShiftSalesReportResponse?>(null);

  @override
  void onReady() {
    super.onReady();
    fetchReport();
  }

  void onChangeReportType(ReportType type) {
    reportType.value = type;
    reportData.value = null;
    shiftReportData.value = null;
    fetchReport();
  }

  void setDates(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
  }

  void setDateTimes(DateTime start, DateTime end) {
    startDateTime.value = start;
    endDateTime.value = end;
  }

  void setSingleDate(DateTime date) {
    singleDate.value = date;
  }

  /* Consume el servicio correspondiente para obtener el reporte según el tipo seleccionado */
  Future<void> fetchReport() async {
    reportData.value = null;
    shiftReportData.value = null;

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          switch (reportType.value) {
            case ReportType.dateRange:
              final startStr = DateFormat('yyyy-MM-dd').format(startDate.value);
              final endStr = DateFormat('yyyy-MM-dd').format(endDate.value);
              final data = await _repository.getSalesReport(startStr, endStr);
              reportData.value = data;
              break;
            case ReportType.exactDateTimeRange:
              final startStr = DateFormat("yyyy-MM-dd'T'HH:mm:00").format(startDateTime.value); // Use T literal
              final endStr = DateFormat("yyyy-MM-dd'T'HH:mm:00").format(endDateTime.value);
              final data = await _repository.getSalesReportByDateTime(startStr, endStr);
              reportData.value = data;
              break;
            case ReportType.shiftById:
              if (shiftIdController.text.trim().isEmpty) return;
              final data = await _repository.getSalesReportByShiftId(shiftIdController.text.trim());
              shiftReportData.value = data;
              break;
            case ReportType.shiftByDate:
              final dateStr = DateFormat('yyyy-MM-dd').format(singleDate.value);
              final data = await _repository.getSalesReportByShiftDate(dateStr);
              shiftReportData.value = data;
              break;
          }
        } catch (e) {
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
