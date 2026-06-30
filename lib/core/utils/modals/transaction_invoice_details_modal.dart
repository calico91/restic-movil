import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/transaction_receipt_model.dart';
import 'package:restic_movil/core/utils/formatters/currency_formatter.dart';

class TransactionInvoiceDetailsModal extends StatelessWidget {
  final TransactionReceiptModel receipt;

  const TransactionInvoiceDetailsModal({
    super.key,
    required this.receipt,
  });

  static void show({required TransactionReceiptModel receipt}) {
    Get.dialog(TransactionInvoiceDetailsModal(receipt: receipt));
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Map<String, Map<String, Object>> _buildGroupedItems() {
    final Map<String, Map<String, Object>> grouped = {};
    for (final item in receipt.items ?? []) {
      final String name = item.productName ?? 'Producto';
      final double up = item.unitPrice ?? 0;
      final String key = '$name|$up';
      if (grouped.containsKey(key)) {
        grouped[key]!['qty'] = (grouped[key]!['qty'] as int) + (item.quantity ?? 1);
        grouped[key]!['sub'] = (grouped[key]!['sub'] as double) + (item.subtotal ?? 0.0);
      } else {
        grouped[key] = {
          'name': name,
          'qty': item.quantity ?? 1,
          'unitPrice': up,
          'sub': item.subtotal ?? 0.0,
        };
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(receipt.issuedAt);
    final grouped = _buildGroupedItems();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Detalle de Factura #${receipt.transactionNumber ?? ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red[800],
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('FACTURA DE VENTA:', receipt.transactionNumber ?? '-'),
            _buildInfoRow('Fecha:', dateStr),
            if (receipt.waiterName != null)
              _buildInfoRow('Creado por:', receipt.waiterName!),
            if (receipt.customerName != null)
              _buildInfoRow('Cliente:', receipt.customerName!),
            if (receipt.tableNames != null && receipt.tableNames!.isNotEmpty)
              _buildInfoRow('Mesas:', receipt.tableNames!.join(', ')),
            const Divider(),
            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Producto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    'Cant.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subtotal',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.35),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: grouped.length,
                separatorBuilder: (_, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = grouped.values.elementAt(index);
                  final name = row['name'] as String;
                  final qty = row['qty'] as int;
                  final sub = row['sub'] as double;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(name, style: const TextStyle(fontSize: 13)),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            'x$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            CurrencyFormatter.toCurrency(sub),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            _buildTotalRow('Subtotal:', receipt.subtotal ?? 0),
            if (receipt.surcharges != null && receipt.surcharges!.isNotEmpty) ...[
              for (final s in receipt.surcharges!)
                _buildTotalRow('${s.description}:', s.amount),
            ],
            if ((receipt.tipAmount ?? 0) > 0)
              _buildTotalRow('Propina:', receipt.tipAmount!),
            _buildTotalRow(
              'TOTAL A PAGAR:',
              receipt.totalAmount ?? 0,
              isBold: true,
              color: Colors.green[700],
            ),
            const Divider(),
            _buildTotalRow('Total Pagado:', receipt.totalPaid ?? 0),
            _buildTotalRow('Cambio:', receipt.change ?? 0),
            if (receipt.paymentDetails != null && receipt.paymentDetails!.isNotEmpty) ...[
              const Divider(),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Métodos de pago:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 4),
              for (final pay in receipt.paymentDetails!)
                _buildTotalRow(
                  pay.paymentMethodDescription ?? pay.paymentMethod ?? '-',
                  pay.amount ?? 0,
                ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            CurrencyFormatter.toCurrency(amount),
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
