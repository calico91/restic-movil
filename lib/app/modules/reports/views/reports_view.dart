import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/sales_report_response.dart';
import 'package:restic_movil/app/modules/reports/controllers/reports_controller.dart';
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              secondary: Color(0xFF0D47A1),
              primaryContainer: Color(0xFFE4F0FE),
              onPrimaryContainer: Color(0xFF0D47A1),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1),
              foregroundColor: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ), // Fondo principal
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDates(picked.start, picked.end);
      controller.fetchSalesReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Reporte de Ventas',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateSelector(context),
            const SizedBox(height: 16),
            Obx(() {
              final data = controller.reportData.value;
              if (data == null) {
                return const Center(child: Text('Cargando reporte...'));
              }
              return Column(
                children: [
                  _buildSummaryCards(data),
                  const SizedBox(height: 16),
                  _buildPaymentBreakdownCard(data.paymentBreakdown ?? []),
                  const SizedBox(height: 16),
                  _buildCashierSummaryCard(data.cashierSummary ?? []),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /*construye el selector de rango de fechas, 
mostrando el rango seleccionado y permitiendo al usuario cambiarlo al hacer clic*/
  Widget _buildDateSelector(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.date_range, color: Color(0xFF0D47A1)),
        title: Obx(() {
          final startStr = DateFormat(
            'dd/MM/yyyy',
          ).format(controller.startDate.value);
          final endStr = DateFormat(
            'dd/MM/yyyy',
          ).format(controller.endDate.value);
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

  /*Construye las tarjetas de resumen para mostrar las métricas clave del reporte*/
  Widget _buildSummaryCards(SalesReportResponse data) {
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
          '${data.totalTransactions ?? 0}',
          Icons.receipt_long,
          Colors.blue,
        ),
        _summaryItem(
          'Ventas',
          oCcy.format(data.totalSales ?? 0),
          Icons.attach_money,
          Colors.green,
        ),
        _summaryItem(
          'Propinas',
          oCcy.format(data.totalTips ?? 0),
          Icons.monetization_on_outlined,
          Colors.orange,
        ),
        _summaryItem(
          'Ingreso Bruto',
          oCcy.format(data.grossRevenue ?? 0),
          Icons.account_balance,
          Colors.purple,
        ),
      ],
    );
  }

  /*Construye un widget individual para cada métrica del resumen, mostrando un ícono, título y valor formateado*/
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

  /*Construye la tarjeta de desglose por medios de pago, mostrando cada medio con su porcentaje y total*/
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

  /*Construye la tarjeta de resumen por cajero, mostrando cada cajero con sus transacciones, ventas y propinas*/
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
}
