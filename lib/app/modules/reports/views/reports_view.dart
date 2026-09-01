import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/data/models/shift_sales_report_response.dart';
import 'package:restic_movil/app/modules/reports/controllers/reports_controller.dart';
import 'package:restic_movil/app/modules/reports/views/widgets/product_sales_results_view.dart';
import 'package:restic_movil/app/modules/reports/views/widgets/product_selection_section.dart';
import 'package:restic_movil/app/modules/reports/views/widgets/top_products_results_view.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: controller.startDate.value,
      end: controller.endDate.value,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _pickerTheme,
    );

    if (picked != null) {
      controller.setDates(picked.start, picked.end);
      controller.fetchReport();
    }
  }

  Future<void> _selectSingleDate(BuildContext context) async {
    final pickedStr = await showDatePicker(
      context: context,
      initialDate: controller.singleDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _pickerTheme,
    );

    if (pickedStr != null) {
      controller.setSingleDate(pickedStr);
      controller.fetchReport();
    }
  }

  Future<void> _selectExactDateTimes(BuildContext context) async {
    DateTime? startD = await showDatePicker(
      context: context,
      initialDate: controller.startDateTime.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Seleccionar Fecha Inicio',
      builder: _pickerTheme,
    );
    if (startD == null) return;
    if (!context.mounted) return;

    TimeOfDay? startT = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.startDateTime.value),
      helpText: 'Seleccionar Hora Inicio',
      builder: _pickerTheme,
    );
    if (startT == null) return;
    if (!context.mounted) return;

    DateTime? endD = await showDatePicker(
      context: context,
      initialDate: controller.endDateTime.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Seleccionar Fecha Fin',
      builder: _pickerTheme,
    );
    if (endD == null) return;
    if (!context.mounted) return;

    TimeOfDay? endT = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.endDateTime.value),
      helpText: 'Seleccionar Hora Fin',
      builder: _pickerTheme,
    );
    if (endT == null) return;

    controller.setDateTimes(
      DateTime(startD.year, startD.month, startD.day, startT.hour, startT.minute),
      DateTime(endD.year, endD.month, endD.day, endT.hour, endT.minute),
    );
    controller.fetchReport();
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D47A1),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          secondary: Color(0xFF0D47A1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Reporte de Ventas',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            Obx(() => _buildParametersSelector(context)),
            const SizedBox(height: 16),
            Obx(() {
              final type = controller.reportType.value;
              if (type == ReportType.dateRange || type == ReportType.exactDateTimeRange) {
                final data = controller.reportData.value;
                if (data == null) {
                  return const Center(child: Text('Cargando reporte o sin datos...'));
                }
                return Column(
                  children: [
                    _buildSummaryCards(data.totalTransactions, data.totalSales, data.totalTips, data.grossRevenue),
                    const SizedBox(height: 16),
                    _buildPaymentBreakdownCard(data.paymentBreakdown ?? []),
                    const SizedBox(height: 16),
                    _buildCashierSummaryCard(data.cashierSummary ?? []),
                  ],
                );
              } else if (type == ReportType.productSales) {
                final data = controller.productReportData.value;
                if (data == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Selecciona al menos un producto y pulsa "Consultar reporte".',
                      ),
                    ),
                  );
                }
                return ProductSalesResultsView(data: data);
              } else if (type == ReportType.topProducts) {
                final data = controller.productReportData.value;
                if (data == null) {
                  return const Center(child: Text('Cargando reporte o sin datos...'));
                }
                return TopProductsResultsView(data: data);
              } else {
                final sData = controller.shiftReportData.value;
                if (sData == null) {
                  return const Center(child: Text('Cargando reporte de turno o sin datos...'));
                }
                return Column(
                  children: [
                    _buildShiftInfoCard(sData),
                    const SizedBox(height: 16),
                    _buildSummaryCards(sData.totalTransactions, sData.totalSales, sData.totalTips, sData.grossRevenue),
                    const SizedBox(height: 16),
                    _buildShiftPaymentBreakdownCard(sData.paymentBreakdown ?? []),
                    const SizedBox(height: 16),
                    _buildShiftCashierSummaryCard(sData.cashierSummary ?? []),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Obx(() => DropdownButton<ReportType>(
          value: controller.reportType.value,
          isExpanded: true,
          underline: const SizedBox(),
          onChanged: (val) {
            if (val != null) controller.onChangeReportType(val);
          },
          items: const [
            DropdownMenuItem(value: ReportType.dateRange, child: Text('Rango de Fechas')),
            DropdownMenuItem(value: ReportType.exactDateTimeRange, child: Text('Rango de Fecha-Hora Exacto')),
            DropdownMenuItem(value: ReportType.shiftById, child: Text('Turno Específico (ID)')),
            DropdownMenuItem(value: ReportType.shiftByDate, child: Text('Fecha de Apertura de Turno')),
            DropdownMenuItem(value: ReportType.productSales, child: Text('Ventas por Producto (selección)')),
            DropdownMenuItem(value: ReportType.topProducts, child: Text('Top de Productos Vendidos')),
          ],
        )),
      ),
    );
  }

  Widget _buildParametersSelector(BuildContext context) {
    switch (controller.reportType.value) {
      case ReportType.dateRange:
        return _buildDateSelector(context);
      case ReportType.exactDateTimeRange:
        return _buildExactDateTimeSelector(context);
      case ReportType.shiftById:
        return _buildShiftIdInput();
      case ReportType.shiftByDate:
        return _buildSingleDateSelector(context);
      case ReportType.productSales:
        return Column(
          children: [
            const ProductSelectionSection(),
            const SizedBox(height: 12),
            _buildExactDateTimeSelector(context),
          ],
        );
      case ReportType.topProducts:
        return _buildExactDateTimeSelector(context);
    }
  }

  Widget _buildDateSelector(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.date_range, color: Color(0xFF0D47A1)),
        title: Obx(() {
          final startStr = DateFormat('dd/MM/yyyy').format(controller.startDate.value);
          final endStr = DateFormat('dd/MM/yyyy').format(controller.endDate.value);
          return Text(
            'Rango de Fechas: $startStr - $endStr',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        trailing: const Icon(Icons.edit, size: 20),
        onTap: () => _selectDateRange(context),
      ),
    );
  }

  Widget _buildExactDateTimeSelector(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Color(0xFF0D47A1)),
        title: Obx(() {
          final startStr = DateFormat('dd/MM/yyyy HH:mm').format(controller.startDateTime.value);
          final endStr = DateFormat('dd/MM/yyyy HH:mm').format(controller.endDateTime.value);
          return Text(
            'Tiempo: $startStr a $endStr',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          );
        }),
        trailing: const Icon(Icons.edit, size: 20),
        onTap: () => _selectExactDateTimes(context),
      ),
    );
  }

  Widget _buildSingleDateSelector(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.today, color: Color(0xFF0D47A1)),
        title: Obx(() {
          final dateStr = DateFormat('dd/MM/yyyy').format(controller.singleDate.value);
          return Text(
            'Fecha Turno: $dateStr',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        trailing: const Icon(Icons.edit, size: 20),
        onTap: () => _selectSingleDate(context),
      ),
    );
  }

  Widget _buildShiftIdInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.shiftIdController,
                decoration: const InputDecoration(
                  labelText: 'ID o Número de Turno',
                  border: InputBorder.none,
                  icon: Icon(Icons.numbers, color: Color(0xFF0D47A1)),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
              onPressed: () => controller.fetchReport(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShiftInfoCard(ShiftSalesReportResponse data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.work, color: Color(0xFF0D47A1)),
                const SizedBox(width: 8),
                Text('Turno #${data.shiftNumber ?? data.shiftId ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            _infoRow('Cajero', data.cashierName ?? 'N/A'),
            _infoRow('Terminal', data.terminalName ?? 'N/A'),
            _infoRow('Estado', data.shiftStatus ?? 'N/A'),
            _infoRow('Apertura', data.openedAt ?? 'N/A'),
            _infoRow('Cierre', data.closedAt ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int? totalTx, double? sales, double? tips, double? gross) {
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _summaryItem(
          'Transacciones',
          '${totalTx ?? 0}',
          Icons.receipt_long,
          Colors.blue,
        ),
        _summaryItem(
          'Ventas',
          oCcy.format(sales ?? 0),
          Icons.attach_money,
          Colors.green,
        ),
        _summaryItem(
          'Propinas',
          oCcy.format(tips ?? 0),
          Icons.monetization_on_outlined,
          Colors.orange,
        ),
        _summaryItem(
          'Ingreso Bruto',
          oCcy.format(gross ?? 0),
          Icons.account_balance,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _summaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      width: (Get.width / 2) - 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownCard(List<PaymentBreakdown> breakdown) {
    if (breakdown.isEmpty) return const SizedBox();
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desglose por Medios de Pago',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const Divider(),
            ...breakdown.map(
              (b) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payment, color: Colors.blueGrey),
                title: Text(b.description ?? 'Desconocido'),
                subtitle: Text(
                  '${b.percentage?.toStringAsFixed(1)}% (${b.transactionCount} tx)',
                ),
                trailing: Text(
                  oCcy.format(b.totalAmount ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftPaymentBreakdownCard(List<dynamic> breakdown) {
    if (breakdown.isEmpty) return const SizedBox();
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desglose por Medios de Pago',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const Divider(),
            ...breakdown.map(
              (b) {
                final map = b as Map<String, dynamic>;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.payment, color: Colors.blueGrey),
                  title: Text((map['description'] ?? 'Desconocido').toString()),
                  subtitle: Text(
                    '${(map['percentage'] as num?)?.toStringAsFixed(1) ?? '0.0'}% (${map['transactionCount'] ?? 0} tx)',
                  ),
                  trailing: Text(
                    oCcy.format((map['totalAmount'] as num?)?.toDouble() ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashierSummaryCard(List<CashierSummary> summary) {
    if (summary.isEmpty) return const SizedBox();
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por Cajero',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const Divider(),
            ...summary.map(
              (c) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.cashierName ?? 'Desconocido'),
                subtitle: Text('${c.transactionCount} Transacciones'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      oCcy.format(c.totalSales ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Propinas: ${oCcy.format(c.totalTips ?? 0)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCashierSummaryCard(List<dynamic> summary) {
    if (summary.isEmpty) return const SizedBox();
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por Cajero',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const Divider(),
            ...summary.map(
              (c) {
                final map = c as Map<String, dynamic>;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text((map['cashierName'] ?? 'Desconocido').toString()),
                  subtitle: Text('${map['transactionCount'] ?? 0} Transacciones'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        oCcy.format((map['totalSales'] as num?)?.toDouble() ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Propinas: ${oCcy.format((map['totalTips'] as num?)?.toDouble() ?? 0)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
