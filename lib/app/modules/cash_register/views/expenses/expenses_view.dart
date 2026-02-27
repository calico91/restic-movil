import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/cash_register/controllers/expenses/expenses_controller.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Egresos de Caja',
      showBackButton: true,
      body: const Center(
        child: Text(
          'Egresos de Caja',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
