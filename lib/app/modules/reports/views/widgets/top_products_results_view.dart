import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/product_sales_report_response.dart';

class TopProductsResultsView extends StatelessWidget {
  const TopProductsResultsView({super.key, required this.data});
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
        _TopSummary(data: data),
        const SizedBox(height: 16),
        if (products.isEmpty)
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('No se encontraron ventas en el período seleccionado'),
            ),
          ),
        ...List.generate(products.length, (i) {
          final p = products[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RankedProductCard(
              rank: i + 1,
              summary: p,
              currency: oCcy,
              color: color,
            ),
          );
        }),
      ],
    );
  }
}

class _TopSummary extends StatelessWidget {
  const _TopSummary({required this.data});
  final ProductSalesReportResponse data;

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
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
                _stat(context, 'Transacciones', '${data.totalTransactions ?? 0}', Icons.receipt_long, color),
                _stat(context, 'Productos vendidos', '${data.totalProducts ?? 0}', Icons.inventory, color),
                _stat(context, 'Unidades', '${data.totalUnitsSold ?? 0}', Icons.shopping_bag, color),
                _stat(context, 'Ingreso total', oCcy.format(data.totalRevenue ?? 0), Icons.payments, color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _RankedProductCard extends StatelessWidget {
  const _RankedProductCard({
    required this.rank,
    required this.summary,
    required this.currency,
    required this.color,
  });
  final int rank;
  final ProductSalesSummary summary;
  final NumberFormat currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final rankColor = switch (rank) {
      1 => const Color(0xFFFFC107),
      2 => const Color(0xFFB0BEC5),
      3 => const Color(0xFFB08653),
      _ => color,
    };

    return Card(
      elevation: isTop3 ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTop3
            ? BorderSide(color: rankColor, width: 1.2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: rankColor,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isTop3 ? Colors.white : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.productName ?? 'Sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (summary.categoryName != null || summary.subcategoryName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        [
                          summary.subcategoryName,
                          summary.categoryName,
                        ].where((s) => (s ?? '').isNotEmpty).join(' · '),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip('${summary.totalQuantity ?? 0} uds', Icons.shopping_bag),
                      const SizedBox(width: 6),
                      _chip('${summary.timesSold ?? 0} veces', Icons.repeat),
                      if (summary.percentage != null) ...[
                        const SizedBox(width: 6),
                        _chip(
                          '${summary.percentage!.toStringAsFixed(1)}%',
                          Icons.percent,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currency.format(summary.totalRevenue ?? 0),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
