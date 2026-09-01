import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/product_sales_report_response.dart';

class ProductSalesResultsView extends StatelessWidget {
  const ProductSalesResultsView({super.key, required this.data});
  final ProductSalesReportResponse data;

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    const color = Color(0xFF0D47A1);
    final products = data.products ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(data: data, currency: oCcy),
        const SizedBox(height: 16),
        if (products.isEmpty)
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('No se encontraron ventas de los productos seleccionados en el período'),
            ),
          ),
        ...products.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProductCard(
                summary: p,
                currency: oCcy,
                color: color,
              ),
            )),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.currency});
  final ProductSalesReportResponse data;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryStat('Productos', '${data.totalProducts ?? 0}', Icons.inventory),
                _summaryStat('Unidades', '${data.totalUnitsSold ?? 0}', Icons.shopping_bag),
                _summaryStat(
                  'Ingreso total',
                  currency.format(data.totalRevenue ?? 0),
                  Icons.payments,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryStat(String label, String value, IconData icon) {
    const color = Color(0xFF0D47A1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.summary,
    required this.currency,
    required this.color,
  });
  final ProductSalesSummary summary;
  final NumberFormat currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasSales = (summary.totalQuantity ?? 0) > 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_basket, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.productName ?? 'Sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (summary.productType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      summary.productType!,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (summary.categoryName != null || summary.subcategoryName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  [
                    summary.subcategoryName,
                    summary.categoryName,
                  ].where((s) => (s ?? '').isNotEmpty).join(' · '),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            if (!hasSales)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.do_not_disturb, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Sin ventas en el período',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat('Veces vendido', '${summary.timesSold ?? 0}'),
                  _stat('Unidades', '${summary.totalQuantity ?? 0}'),
                  _stat('Ingreso', currency.format(summary.totalRevenue ?? 0)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    const color = Color(0xFF0D47A1);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
