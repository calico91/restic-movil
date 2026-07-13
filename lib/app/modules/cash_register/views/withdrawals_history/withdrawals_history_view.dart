import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_reason.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/withdrawals_history/withdrawals_history_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class WithdrawalsHistoryView extends GetView<WithdrawalsHistoryController> {
  const WithdrawalsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Historial de Egresos',
      showBackButton: true,
      body: Column(
        children: [
          _buildFilters(context),
          const Divider(height: 1),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              _buildDateRangeRow(context),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildReasonDropdown()),
                  if (controller.isAdmin.value) ...[
                    const SizedBox(width: 8),
                    Expanded(child: _buildUserDropdown()),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.loadHistory,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Buscar'),
                    ),
                  ),
                  if (controller.isAdmin.value) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isExporting.value ||
                                controller.withdrawals.isEmpty
                            ? null
                            : controller.exportCsv,
                        icon: controller.isExporting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download, size: 18),
                        label: Text(controller.isExporting.value
                            ? 'Exportando...'
                            : 'Exportar CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildDateRangeRow(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: DateTimeRange(
            start: controller.startDate,
            end: controller.endDate,
          ),
        );
        if (picked != null) {
          controller.setDateRange(picked.start, picked.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              '${dateFormat.format(controller.startDate)} - ${dateFormat.format(controller.endDate)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return Obx(() => DropdownButtonFormField<CashWithdrawalReason?>(
          initialValue: controller.selectedReason,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<CashWithdrawalReason?>(
              value: null,
              child: Text('Todos'),
            ),
            ...controller.reasons.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.description, overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: controller.setReason,
        ));
  }

  Widget _buildUserDropdown() {
    return Obx(() => DropdownButtonFormField<String?>(
          initialValue: controller.selectedUserId,
          decoration: const InputDecoration(
            labelText: 'Usuario',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos'),
            ),
            ...controller.users.map((u) => DropdownMenuItem(
                  value: u.id,
                  child: Text(
                    u.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
          onChanged: controller.setUser,
        ));
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.withdrawals.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No hay egresos en el periodo seleccionado',
              style: TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.withdrawals.length,
        itemBuilder: (context, index) {
          return _buildWithdrawalCard(controller.withdrawals[index]);
        },
      );
    });
  }

  Widget _buildWithdrawalCard(CashWithdrawal w) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(w.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
                _buildSourceChip(w.paymentSource, w.paymentSourceDescription),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              w.concept,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Motivo', w.reasonDescription),
                      _detailRow('Turno', w.shiftNumber),
                      _detailRow('Registrado por', w.registeredByName),
                      if (w.voucherReference != null &&
                          w.voucherReference!.isNotEmpty)
                        _detailRow('Referencia', w.voucherReference!),
                      if (w.bankAccountName != null &&
                          w.bankAccountName!.isNotEmpty)
                        _detailRow('Cuenta', w.bankAccountName!),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(w.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (w.alertTriggered)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.warning_amber,
                            color: Colors.orange, size: 18),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceChip(String source, String description) {
    final isCash = source == 'CASH';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCash
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCash ? Colors.green : Colors.blue),
      ),
      child: Text(
        description,
        style: TextStyle(
          color: isCash ? Colors.green : Colors.blue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
