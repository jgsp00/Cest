import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/iconos.dart';
import '../models/producto.dart';
import 'animated_card.dart';
import 'bounce_button.dart';

class ProductCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onSumar;
  final VoidCallback onRestar;

  const ProductCard({
    super.key,
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
    required this.onSumar,
    required this.onRestar,
  });

  @override
  Widget build(BuildContext context) {
    final p = producto;
    final stockPct = p.capacidad > 0
        ? (p.cantidad / p.capacidad).clamp(0.0, 1.0)
        : 0.0;
    final stockColor = stockPct < 0.3
        ? kOrange
        : stockPct > 0.7
        ? kGreen
        : kGold;

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kCard2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(getIcono(p.emoji), color: kAccent, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: const TextStyle(
                          color: kText,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _chip(p.categoria, kPurple),
                          const SizedBox(width: 6),
                          _chip('\$${p.precio.toStringAsFixed(0)} c/u', kGold),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEditar,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: kAccent,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onEliminar,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: kOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: kOrange,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                BounceButton(
                  color: kOrange,
                  onTap: onRestar,
                  child: const Icon(
                    Icons.remove_rounded,
                    color: kOrange,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: stockPct,
                          minHeight: 7,
                          backgroundColor: kCard2,
                          valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stock',
                            style: TextStyle(color: kTextSub, fontSize: 10),
                          ),
                          Text(
                            '${p.cantidad} / ${p.capacidad}',
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                BounceButton(
                  color: kGreen,
                  onTap: onSumar,
                  child: const Icon(Icons.add_rounded, color: kGreen, size: 17),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}
