import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/commands_controller.dart';

class CommandsView extends GetView<CommandsController> {
  const CommandsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Opciones de Comandos',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
