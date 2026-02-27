import 'package:flutter/widgets.dart';

/// Un IndexedStack que inicializa (renderiza) a sus hijos solo hasta 
/// el momento en que son visibles por primera vez. Esto optimiza 
/// la memoria y el rendimiento de la aplicación, ya que los controladores 
/// y widgets de las pestañas ocultas no se cargan automáticamente al inicio.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activatedList;

  @override
  void initState() {
    super.initState();
    // Inicialmente solo activamos el índice actual
    _activatedList = List.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la cantidad de hijos (roles de usuario obtenidos de Storage), reiniciamos
    if (oldWidget.children.length != widget.children.length) {
      _activatedList = List.generate(
        widget.children.length,
        (i) => i == widget.index,
      );
    } else if (oldWidget.index != widget.index) {
      // Si navegamos a una nueva pestaña, la activamos
      _activateIndex(widget.index);
    }
  }

  void _activateIndex(int index) {
    if (index >= 0 && index < _activatedList.length && !_activatedList[index]) {
      setState(() {
        _activatedList[index] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List.generate(widget.children.length, (i) {
        if (_activatedList[i]) {
          return widget.children[i];
        }
        return const SizedBox.shrink(); // Pestaña que aún no se visita
      }),
    );
  }
}
