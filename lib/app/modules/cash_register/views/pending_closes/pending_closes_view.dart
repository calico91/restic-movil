import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/cashier_shift.dart';
import 'package:restic_movil/app/data/models/shift_summary.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/pending_closes/pending_closes_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class PendingClosesView extends GetView<PendingClosesController> {
  const PendingClosesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Cierres de Caja',
      showBackButton: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadShifts,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.openShifts.isNotEmpty) ...[
                _buildSectionHeader('Sin Cerrar', Icons.lock_open, Colors.orange),
                const SizedBox(height: 8),
                ...controller.openShifts
                    .map((s) => _buildShiftCard(s, context)),
                const SizedBox(height: 24),
              ],
              if (controller.closedShifts.isNotEmpty) ...[
                _buildSectionHeader(
                    'Pendientes de Conciliar', Icons.pending_actions, Colors.blue),
                const SizedBox(height: 8),
                ...controller.closedShifts
                    .map((s) => _buildShiftCard(s, context)),
              ],
              if (controller.openShifts.isEmpty &&
                  controller.closedShifts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay turnos pendientes',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildShiftCard(CashierShift shift, BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shift.shiftNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                _buildStatusChip(shift.status),
              ],
            ),
            const Divider(),
            _infoRow('Cajero', shift.cashierName),
            _infoRow('Terminal', '${shift.terminalCode} - ${shift.terminalName}'),
            _infoRow('Apertura', _formatDate(shift.openedAt, dateFormat)),
            _infoRow(
              'Monto Inicial',
              currencyFormat.format(shift.initialAmount),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showShiftSummary(shift.id, context),
                    icon: const Icon(Icons.assessment, size: 18),
                    label: const Text('Ver Arqueo'),
                  ),
                ),
                if (controller.isAdmin.value && shift.status == 'CLOSED') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmReconcile(shift, context),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Conciliar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'OPEN':
        color = Colors.orange;
        break;
      case 'CLOSED':
        color = Colors.blue;
        break;
      case 'RECONCILED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  String _formatDate(String iso, DateFormat format) {
    try {
      return format.format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Future<void> _showShiftSummary(String shiftId, BuildContext context) async {
    final summary = await controller.getShiftSummary(shiftId);
    if (summary == null) return;
    if (!context.mounted) return;
    _displaySummaryDialog(context, summary);
  }

  void _displaySummaryDialog(BuildContext context, ShiftSummary summary) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Arqueo: ${summary.shiftNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Cajero', summary.cashierName),
              _infoRow('Terminal', summary.terminalName),
              _infoRow('Estado', summary.status),
              _infoRow('Apertura', _formatDate(summary.openedAt, dateFormat)),
              if (summary.closedAt != null)
                _infoRow('Cierre', _formatDate(summary.closedAt!, dateFormat)),
              const Divider(),
              _infoRow('Monto Inicial',
                  currencyFormat.format(summary.initialAmount)),
              _infoRow('Total Ventas',
                  currencyFormat.format(summary.totalSales)),
              _infoRow('Total Egresos',
                  currencyFormat.format(summary.totalWithdrawals)),
              _infoRow('Total Egresos Efectivo',
                  currencyFormat.format(summary.totalCashWithdrawals)),
              _infoRow('Total Egresos Bancarios',
                  currencyFormat.format(summary.totalBankWithdrawals)),
              _infoRow('Propinas',
                  currencyFormat.format(summary.totalTips)),
              const Divider(),
              _infoRow('Efectivo Disponible',
                  currencyFormat.format(summary.availableCash)),
              _infoRow('Efectivo Esperado',
                  currencyFormat.format(summary.expectedCashAmount)),
              if (summary.declaredCashAmount != null)
                _infoRow('Efectivo Declarado',
                    currencyFormat.format(summary.declaredCashAmount)),
              if (summary.difference != null)
                _infoRow('Diferencia',
                    currencyFormat.format(summary.difference),
                    color: summary.difference! < 0 ? Colors.red : Colors.green),
              if (summary.remarks != null && summary.remarks!.isNotEmpty) ...[
                const Divider(),
                _infoRow('Observaciones', summary.remarks!),
              ],
              if (summary.paymentSummary != null &&
                  summary.paymentSummary!.isNotEmpty) ...[
                const Divider(),
                const Text('Desglose por Metodo de Pago:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                ...summary.paymentSummary!.map(
                  (p) => _infoRow(p.description,
                      currencyFormat.format(p.totalCollected)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReconcile(
      CashierShift shift, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conciliar Turno'),
        content: Text(
          'Esta accion marcara el turno ${shift.shiftNumber} como conciliado. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Conciliar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.reconcileShift(shift.id);
    }
  }
}
