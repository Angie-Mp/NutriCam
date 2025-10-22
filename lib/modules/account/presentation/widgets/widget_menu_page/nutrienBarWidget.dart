import 'package:flutter/material.dart';

class NutrientBarWidget extends StatelessWidget {
  final String nombre;
  final double valorActual;
  final double? valorMeta;
  final Color color;
  final double fontSize;

  const NutrientBarWidget({
    Key? key,
    required this.nombre,
    required this.valorActual,
    this.valorMeta,
    required this.color,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progreso = valorMeta! > 0
        ? (valorActual / valorMeta!).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${valorActual.toStringAsFixed(1)} / ${valorMeta?.toStringAsFixed(1)}g",
          style: const TextStyle(
              fontSize: 11,
              color: Colors.black45
          ),
        ),
      ],
    );
  }
}
