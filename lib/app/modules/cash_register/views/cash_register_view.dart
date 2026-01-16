import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cash_register_controller.dart';

class CashRegisterView extends GetView<CashRegisterController> {
  const CashRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Opciones de caja',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
