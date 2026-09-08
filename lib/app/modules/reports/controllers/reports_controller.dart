import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/app/data/models/product_sales_report_response.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/models/shift_sales_report_response.dart';
import 'package:restic_movil/app/data/repositories/categories_repository.dart';
import 'package:restic_movil/app/data/repositories/reports_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';

enum ReportType {
  dateRange,
  exactDateTimeRange,
  shiftById,
  shiftByDate,
  productSales,
  topProducts,
}

class ReportsController extends GetxController {
  final ReportsRepository _repository;
  final CategoriesRepository _categoriesRepository;

  ReportsController(this._repository, this._categoriesRepository);

  final Rx<ReportType> reportType = ReportType.dateRange.obs;

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  final Rx<DateTime> startDateTime = DateTime.now().obs;
  final Rx<DateTime> endDateTime = DateTime.now().obs;

  final TextEditingController shiftIdController = TextEditingController();

  final Rx<DateTime> singleDate = DateTime.now().obs;

  final Rx<SalesReportResponse?> reportData = Rx<SalesReportResponse?>(null);
  final Rx<ShiftSalesReportResponse?> shiftReportData = Rx<ShiftSalesReportResponse?>(null);
  final Rx<ProductSalesReportResponse?> productReportData = Rx<ProductSalesReportResponse?>(null);

  // Estado para el reporte "Ventas por Producto" (seleccion).
  final RxList<String> selectedProductIds = <String>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchReport();
  }

  void onChangeReportType(ReportType type) {
    reportType.value = type;
    reportData.value = null;
    shiftReportData.value = null;
    productReportData.value = null;
    if (type == ReportType.productSales) {
      loadCategoriesForSelection();
    }
    if (type == ReportType.topProducts) {
      fetchTopProductsReport();
    }
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

  /* Consume el servicio correspondiente para obtener el reporte segun el tipo seleccionado */
  Future<void> fetchReport() async {
    reportData.value = null;
    shiftReportData.value = null;
    productReportData.value = null;

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
              final startStr = DateFormat("yyyy-MM-dd'T'HH:mm:00").format(startDateTime.value);
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
            case ReportType.productSales:
              await fetchProductSalesReport();
              break;
            case ReportType.topProducts:
              await fetchTopProductsReport();
              break;
          }
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /* Carga las categorias (con subcategorias y productos) para alimentar el checklist */
  Future<void> loadCategoriesForSelection() async {
    if (categories.isNotEmpty || isLoadingCategories.value) return;
    isLoadingCategories.value = true;
    try {
      final loaded = await _categoriesRepository.getCategories();
      categories.assignAll(loaded);
    } catch (e) {
      ErrorHandler.showErrorDialog(e);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /* Agrega o quita un producto del set de seleccionados */
  void toggleProduct(String productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
  }

  /* Marca/desmarca todos los productos de una subcategoria */
  void toggleSubcategory(String? subcategoryId, List<String> productIdsInGroup) {
    final allSelected =
        productIdsInGroup.every((id) => selectedProductIds.contains(id));
    if (allSelected && productIdsInGroup.isNotEmpty) {
      for (final id in productIdsInGroup) {
        selectedProductIds.remove(id);
      }
    } else {
      for (final id in productIdsInGroup) {
        if (!selectedProductIds.contains(id)) selectedProductIds.add(id);
      }
    }
  }

  /* Limpia la seleccion actual de productos */
  void clearProductSelection() {
    selectedProductIds.clear();
  }

  /* Consulta el reporte de ventas por productos seleccionados en el rango fecha-hora */
  Future<void> fetchProductSalesReport() async {
    if (selectedProductIds.isEmpty) {
      ErrorHandler.showErrorDialog(
        Exception('Selecciona al menos un producto para generar el reporte'),
      );
      return;
    }
    if (startDateTime.value.isAfter(endDateTime.value)) {
      ErrorHandler.showErrorDialog(
        Exception('La hora de inicio debe ser anterior a la hora de fin'),
      );
      return;
    }
    productReportData.value = null;
    final startStr =
        DateFormat("yyyy-MM-dd'T'HH:mm:00").format(startDateTime.value);
    final endStr =
        DateFormat("yyyy-MM-dd'T'HH:mm:00").format(endDateTime.value);
    final data = await _repository.getProductSalesReport(
      startStr,
      endStr,
      selectedProductIds.toList(),
    );
    productReportData.value = data;
  }

  /* Consulta el ranking de productos mas vendidos en el rango fecha-hora */
  Future<void> fetchTopProductsReport() async {
    if (startDateTime.value.isAfter(endDateTime.value)) {
      ErrorHandler.showErrorDialog(
        Exception('La hora de inicio debe ser anterior a la hora de fin'),
      );
      return;
    }
    productReportData.value = null;
    final startStr =
        DateFormat("yyyy-MM-dd'T'HH:mm:00").format(startDateTime.value);
    final endStr =
        DateFormat("yyyy-MM-dd'T'HH:mm:00").format(endDateTime.value);
    final data = await _repository.getTopProductsReport(startStr, endStr);
    productReportData.value = data;
  }

  /* Helpers para el producto seleccionado dentro del widget */
  bool isProductSelected(String productId) =>
      selectedProductIds.contains(productId);

  bool isSubcategoryFullySelected(List<String> productIdsInGroup) =>
      productIdsInGroup.isNotEmpty &&
      productIdsInGroup.every((id) => selectedProductIds.contains(id));

  bool isSubcategoryPartiallySelected(List<String> productIdsInGroup) =>
      productIdsInGroup.any((id) => selectedProductIds.contains(id));

  /* Total de productos disponibles en el catalogo cargado (activos en subcategorias) */
  int get totalAvailableProducts {
    int total = 0;
    for (final cat in categories) {
      for (final sub in cat.subcategories ?? <SubcategoryModel>[]) {
        total += sub.products?.length ?? 0;
      }
    }
    return total;
  }

}
