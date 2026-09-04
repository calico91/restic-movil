import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restic_movil/app/data/models/subscription_invoice_model.dart';
import 'package:restic_movil/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/modals/subscription_invoice_details_modal.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Suscripción y Facturación',
      showBackButton: true,
      body: Obx(() {
        switch (controller.mode) {
          case SubscriptionViewMode.loading:
            return const Center(child: LoadingCharging());
          case SubscriptionViewMode.noSubscription:
            return _buildNoSubscription(context);
          case SubscriptionViewMode.trial:
            return _buildActiveOrTrial(context, isTrial: true);
          case SubscriptionViewMode.active:
            return _buildActiveOrTrial(context, isTrial: false);
          case SubscriptionViewMode.suspended:
            return _buildSuspended(context);
        }
      }),
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.rocket_launch, size: 64, color: Color(0xFF0D47A1)),
          const SizedBox(height: 24),
          const Text(
            'Inicia tu prueba gratuita',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tienes 14 días de acceso completo sin costo. Después se facturará mensualmente según el uso real.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          Obx(() => controller.canManage
              ? CustomSubmitButton(
                  text: controller.startingTrial.value
                      ? 'Iniciando...'
                      : 'Iniciar prueba gratis',
                  onPressed: controller.startingTrial.value
                      ? null
                      : () async {
                          final ok = await controller.startTrial();
                          if (ok) {
                            Get.dialog(const ModalInfo(
                              title: 'Prueba iniciada',
                              message:
                                  'Listo! Tienes 14 días de prueba. La facturación mensual aparecerá entre los días 1-5 de cada mes.',
                            ));
                          }
                        },
                )
              : const SizedBox.shrink()),
          Obx(() => controller.errorMessage.value == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildActiveOrTrial(BuildContext context, { required bool isTrial }) {
    final status = controller.service.status.value;
    final daysLeft = status?.trialDaysRemaining;
    return RefreshIndicator(
      onRefresh: controller.refreshStatus,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isTrial ? Colors.orange.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isTrial ? Icons.timer : Icons.check_circle,
                        color: isTrial ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTrial
                            ? 'Período de prueba'
                            : 'Suscripción activa',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (isTrial && daysLeft != null) ...[
                    const SizedBox(height: 8),
                    Text(daysLeft > 0
                        ? 'Te quedan $daysLeft días de prueba.'
                        : 'Tu prueba terminó hoy.'),
                    if (status?.trialEndsAt != null)
                      Text(
                        'Finaliza: ${_fmtDate(status!.trialEndsAt!)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                  if (status?.currentPeriodEnd != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Próxima facturación: ${_fmtDate(status!.currentPeriodEnd!)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Facturas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.loadingInvoices.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingCharging()),
              );
            }
            if (controller.invoices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Sin facturas todavía.')),
              );
            }
            return Column(
              children: controller.invoices
                  .map((inv) => _invoiceCard(context, inv))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _invoiceCard(BuildContext context, SubscriptionInvoiceModel inv) {
    final dateFmt = DateFormat('yyyy-MM-dd');
    return Card(
      child: ListTile(
        onTap: () => SubscriptionInvoiceDetailsModal.show(invoice: inv),
        leading: Icon(
          inv.isPaid ? Icons.verified : Icons.receipt_long,
          color: inv.isPaid ? Colors.green : Colors.orange,
        ),
        title: Text(
          '\$${_money(inv.totalAmount)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Periodo: ${dateFmt.format(inv.periodStart!)} -> ${dateFmt.format(inv.periodEnd!)}'),
            if (inv.isProrated)
              Text('Incluye prorrateo: ${inv.proratedDays} días (\$${_money(inv.prorationAmount)})',
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text('Vence: ${dateFmt.format(inv.dueAt!)}',
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspended(BuildContext context) {
    final status = controller.service.status.value;
    final reason = status?.suspendedReason ?? 'INVOICE_OVERDUE';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.block, size: 64, color: Colors.red),
          const SizedBox(height: 24),
          const Text(
            'Suscripción suspendida',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            reason == 'INVOICE_OVERDUE'
                ? 'Hay facturas con pago pendiente. Una vez registrado el pago, el servicio se reactiva automáticamente.'
                : 'Estado: $reason',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text('Ver facturas pendientes'),
            onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String _money(int? v) => v == null ? '0' : NumberFormat('#,##0').format(v);
}