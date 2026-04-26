import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Widget reutilizable para navegar entre fechas con flechas y DatePicker.
class DateNavigator extends StatelessWidget {
  const DateNavigator({
    super.key,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onDateSelected,
  });

  final Rx<DateTime> selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        final DateTime now = DateTime.now();
        final DateTime date = selectedDate.value;
        // Comparar solo por fecha (sin hora)
        final bool isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final String label = isToday
            ? 'Hoy — ${DateFormat('dd/MM/yyyy').format(date)}'
            : DateFormat('EEEE dd/MM/yyyy', 'es').format(date);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flecha izquierda — retroceder 1 día
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: Colors.blue[900],
                splashRadius: 24,
                onPressed: onPrevious,
                tooltip: 'Día anterior',
              ),

              // Fecha central tappable — abre DatePicker
              Expanded(
                child: GestureDetector(
                  onTap: () => _openDatePicker(context, date),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isToday ? Colors.blue[900] : Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),

              // Flecha derecha — avanzar 1 día (deshabilitada en hoy)
              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: isToday ? Colors.grey[400] : Colors.blue[900],
                ),
                splashRadius: 24,
                onPressed: isToday ? null : onNext,
                tooltip: isToday ? null : 'Día siguiente',
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Abre el DatePicker nativo y notifica la fecha seleccionada.
  Future<void> _openDatePicker(BuildContext context, DateTime current) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue[900]!,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
