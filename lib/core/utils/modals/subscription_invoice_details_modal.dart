import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/subscription_invoice_model.dart';

class SubscriptionInvoiceDetailsModal extends StatelessWidget {
  final SubscriptionInvoiceModel invoice;

  const SubscriptionInvoiceDetailsModal({
    super.key,
    required this.invoice,
  });

  static void show({required SubscriptionInvoiceModel invoice}) {
    Get.dialog(SubscriptionInvoiceDetailsModal(invoice: invoice));
  }

  String _formatDate(DateTime? d) =>
      d == null ? '' : DateFormat('dd/MM/yyyy').format(d);

  String _money(int? v) =>
      v == null ? '\$0' : NumberFormat('#,##0').format(v);

  String _statusLabel(String? s) {
    switch (s) {
      case 'PENDING':
        return 'Pendiente';
      case 'PAID':
        return 'Pagada';
      case 'OVERDUE':
        return 'Vencida';
      case 'VOID':
        return 'Anulada';
      default:
        return s ?? '';
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'PENDING':
        return Colors.orange;
      case 'PAID':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final planName = invoice.planName;
    final hasDetail = invoice.hasDetail;
    final proratedDays = invoice.proratedDays ?? 0;
    final proratedAmount = invoice.prorationAmount ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Color(0xFF0D47A1)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Detalle de factura',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color: Colors.red[800],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _row('Periodo',
                  '${_formatDate(invoice.periodStart)} → ${_formatDate(invoice.periodEnd)}'),
              _row('Vence', _formatDate(invoice.dueAt)),
              _row('Emitida', _formatDate(invoice.issuedAt)),
              _row('Estado', _statusLabel(invoice.status),
                  valueColor: _statusColor(invoice.status)),
              const Divider(height: 24),
              if (!hasDetail)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Información detallada no disponible para esta factura (generada antes de la actualización).',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (hasDetail) ...[
                const Text(
                  'Desglose',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _row(
                  'Plan base${planName != null ? ' ($planName)' : ''}',
                  _money(invoice.baseAmount),
                  bold: true,
                ),
                if ((invoice.extraUserCount ?? 0) > 0)
                  _row(
                    'Usuarios adicionales (${invoice.extraUserCount})',
                    _money(invoice.extraUserAmount),
                  ),
                if ((invoice.extraBranchCount ?? 0) > 0)
                  _row(
                    'Sedes adicionales (${invoice.extraBranchCount})',
                    _money(invoice.extraBranchAmount),
                  ),
                if (invoice.isProrated)
                  _row(
                    'Prorrateo ($proratedDays días)',
                    _money(proratedAmount),
                  ),
                const Divider(height: 24),
                _row('Total', _money(invoice.totalAmount), bold: true, large: true),
                const SizedBox(height: 16),
                if (invoice.branchNames.isNotEmpty) ...[
                  _listSection('Sedes', invoice.branchNames),
                  const SizedBox(height: 12),
                ],
                if (invoice.activeUserNames.isNotEmpty) ...[
                  _listSection(
                    'Usuarios activos del mes',
                    invoice.activeUserNames,
                  ),
                ],
              ] else ...[
                const SizedBox(height: 8),
                _row('Total', _money(invoice.totalAmount), bold: true, large: true),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, bool large = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: Text(label, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: large ? 18 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(child: Text(e, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}