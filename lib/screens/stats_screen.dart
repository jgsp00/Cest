import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/colors.dart';
import '../models/compra.dart';
import '../widgets/animated_card.dart';

class PantallaEstadisticas extends StatelessWidget {
  final List<Compra> compras;

  const PantallaEstadisticas({super.key, required this.compras});

  @override
  Widget build(BuildContext context) {
    const mesesNombres = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    const mesesCortos = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final now = DateTime.now();

    List<Map<String, dynamic>> meses = [];
    for (int i = 5; i >= 0; i--) {
      final fecha = DateTime(now.year, now.month - i, 1);
      final cm = compras
          .where(
            (c) => c.fecha.year == fecha.year && c.fecha.month == fecha.month,
          )
          .toList();
      meses.add({
        'nombre': mesesNombres[fecha.month - 1],
        'corto': mesesCortos[fecha.month - 1],
        'mes': fecha.month,
        'anio': fecha.year,
        'total': cm.fold(0.0, (s, c) => s + c.monto),
        'compras': cm,
        'esActual': fecha.month == now.month && fecha.year == now.year,
      });
    }

    final maxTotal = meses.map((m) => m['total'] as double).fold(0.0, math.max);
    final totalGeneral = meses.fold(0.0, (s, m) => s + (m['total'] as double));

    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Últimos 6 meses',
              style: TextStyle(color: kTextSub, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Resumen total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPurple.withOpacity(0.15),
                    kAccent.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kPurple.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total 6 meses',
                    style: TextStyle(color: kTextSub, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: totalGeneral),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Text(
                      '\$${_fmt(v)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: kText,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Text(
                    'en ${compras.length} compras registradas',
                    style: const TextStyle(color: kTextSub, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gráfico barras
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kCard2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gasto mensual',
                    style: TextStyle(
                      color: kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: meses.map((m) {
                        final pct = maxTotal > 0
                            ? (m['total'] as double) / maxTotal
                            : 0.0;
                        final isActual = m['esActual'] as bool;
                        return GestureDetector(
                          onTap: () => _detalle(context, m),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isActual)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'hoy',
                                    style: TextStyle(
                                      color: kAccent,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 3),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: pct),
                                duration: Duration(
                                  milliseconds: 700 + (meses.indexOf(m) * 80),
                                ),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 38,
                                  height: math.max(6.0, v * 80),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isActual
                                          ? [kPurple, kAccent]
                                          : [kCard2.withOpacity(0.8), kCard2],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: isActual
                                        ? [
                                            BoxShadow(
                                              color: kAccent.withOpacity(0.4),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m['corto'] as String,
                                style: TextStyle(
                                  color: isActual ? kAccent : kTextSub,
                                  fontSize: 11,
                                  fontWeight: isActual
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Toca un mes para ver detalles',
              style: TextStyle(color: kTextSub, fontSize: 12),
            ),
            const SizedBox(height: 12),

            ...meses.reversed.map((m) {
              final isActual = m['esActual'] as bool;
              final total = m['total'] as double;
              final pct = maxTotal > 0 ? total / maxTotal : 0.0;

              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () => _detalle(context, m),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActual ? kAccent.withOpacity(0.35) : kCard2,
                      width: isActual ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                m['nombre'] as String,
                                style: TextStyle(
                                  color: isActual ? kAccent : kText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (isActual) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Actual',
                                    style: TextStyle(
                                      color: kAccent,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '\$${_fmt(total)}',
                                style: TextStyle(
                                  color: total > 0 ? kGold : kTextSub,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: kTextSub,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (total > 0) ...[
                        const SizedBox(height: 10),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pct),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: v,
                              minHeight: 7,
                              backgroundColor: kCard2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isActual ? kAccent : kGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(m['compras'] as List).length} compras',
                              style: const TextStyle(
                                color: kTextSub,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${(pct * 100).toStringAsFixed(0)}% del máximo',
                              style: const TextStyle(
                                color: kTextSub,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Sin compras registradas',
                            style: TextStyle(color: kTextSub, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _detalle(BuildContext context, Map<String, dynamic> mes) {
    final cm = mes['compras'] as List<Compra>;
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kCard2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mes['nombre']} ${mes['anio']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kText,
                        ),
                      ),
                      Text(
                        '${cm.length} compras',
                        style: const TextStyle(color: kTextSub, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '\$${_fmt(mes['total'] as double)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cm.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📭', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 12),
                          const Text(
                            'Sin compras este mes',
                            style: TextStyle(color: kTextSub),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: cm.length,
                      itemBuilder: (_, i) {
                        final c = cm[i];
                        return AnimatedCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kCard2,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  c.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.nombre,
                                        style: const TextStyle(
                                          color: kText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'x${c.cantidad} · ${c.categoria} · ${c.fecha.day}/${c.fecha.month}',
                                        style: const TextStyle(
                                          color: kTextSub,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${_fmt(c.monto)}',
                                  style: const TextStyle(
                                    color: kGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1] ?? ""}.',
      );
}
