import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/annulled_orders_report_response.dart';

class AnnulledOrdersResultsView extends StatelessWidget {
  const AnnulledOrdersResultsView({super.key, required this.data});
  final AnnulledOrdersReportResponse data;

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final items = data.items ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Summary(data: data, currency: oCcy),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('No se encontraron anulaciones en el período seleccionado'),
            ),
          ),
        ...List.generate(items.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CancelledCard(item: items[i], currency: oCcy),
          );
        }),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.data, required this.currency});
  final AnnulledOrdersReportResponse data;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF0D47A1);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del período',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _stat(context, 'Total anuladas', '${data.totalOrders ?? 0}',
                    Icons.block, color),
                _stat(context, 'Ventas pagadas',
                    '${data.totalPaidAnnulled ?? 0}',
                    Icons.receipt_long, color),
                _stat(context, 'Canceladas pre-pago',
                    '${data.totalPrePaidCancelled ?? 0}',
                    Icons.cancel_schedule_send, color),
                _stat(context, 'Valor total',
                    currency.format(data.totalValue ?? 0),
                    Icons.payments, color),
                _stat(context, 'Propinas',
                    currency.format(data.totalTipAmount ?? 0),
                    Icons.attach_money, color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final width = (MediaQuery.of(context).size.width / 2) - 32;
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  const _CancelledCard({required this.item, required this.currency});
  final AnnulledOrderSummary item;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final isPaid = item.isPaidSale;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Orden #${item.orderNumber ?? '-'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.red.withValues(alpha: 0.12)
                        : Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPaid ? 'Venta pagada' : 'Anulada pre-pago',
                    style: TextStyle(
                      color: isPaid ? Colors.red[800] : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              currency.format(item.totalValue ?? 0),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (item.cancellationReason != null &&
                item.cancellationReason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.cancellationReason!,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
            const SizedBox(height: 8),
            _detailRow('Anulado por', item.cancelledByName),
            if (item.cancelledAt != null)
              _detailRow('Fecha', DateFormat('dd/MM/yy HH:mm').format(item.cancelledAt!)),
            if (item.waiterName != null)
              _detailRow('Mesero', item.waiterName),
            if (item.customerName != null)
              _detailRow('Cliente', item.customerName),
            if (item.originType != null) _detailRow('Origen', item.originType!),
            if (item.transactionNumber != null)
              _detailRow('Factura', item.transactionNumber!),
            if (item.shiftNumber != null)
              _detailRow('Turno', item.shiftNumber!),
            if (item.cashierName != null)
              _detailRow('Cajero', item.cashierName!),
            if (item.tipAmount != null && item.tipAmount! > 0)
              _detailRow('Propina', currency.format(item.tipAmount!)),
            if (item.paymentMethods != null && item.paymentMethods!.isNotEmpty)
              _paymentMethodsRow(),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodsRow() {
    final methods = item.paymentMethods!;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: methods
            .map(
              (p) => Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.08),
                side: BorderSide(
                    color:
                        const Color(0xFF0D47A1).withValues(alpha: 0.3)),
                label: Text(
                  '${p.paymentMethod ?? '-'}  ${currency.format(p.amount ?? 0)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF0D47A1)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
