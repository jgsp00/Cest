import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../constants/iconos.dart';
import '../models/producto.dart';
import '../services/family_service.dart';
import '../widgets/animated_card.dart';

class PantallaInicio extends StatefulWidget {
  final double presupuesto, saldoOcupado;
  final int totalUnidades, capacidadTotal;
  final List<Producto> productos;
  final String familyId;
  final String lastModifiedBy;
  final Function(double) onEditarPresupuesto;
  final VoidCallback onAgregarRapido;

  const PantallaInicio({
    super.key,
    required this.presupuesto,
    required this.saldoOcupado,
    required this.totalUnidades,
    required this.capacidadTotal,
    required this.productos,
    required this.familyId,
    required this.lastModifiedBy,
    required this.onEditarPresupuesto,
    required this.onAgregarRapido,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  String _nombreFamilia = '';
  List<String> _nombresMiembros = [];

  @override
  void initState() {
    super.initState();
    _cargarFamilia();
  }

  Future<void> _cargarFamilia() async {
    final familia = await FamilyService.obtenerFamilia(widget.familyId);
    if (familia == null || !mounted) return;

    final members = List<String>.from(familia['members'] ?? []);
    final nombres = <String>[];
    for (final uid in members) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        nombres.add(doc.data()?['name'] ?? 'Miembro');
      }
    }

    if (mounted) {
      setState(() {
        _nombreFamilia = familia['name'] ?? '';
        _nombresMiembros = nombres;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.presupuesto > 0
        ? (widget.saldoOcupado / widget.presupuesto).clamp(0.0, 1.0)
        : 0.0;
    final restante = widget.presupuesto - widget.saldoOcupado;
    final barColor = pct > 0.8
        ? kOrange
        : pct > 0.5
        ? kGold
        : kGreen;

    final stockBajos = widget.productos
        .where((p) => p.capacidad > 0 && (p.cantidad / p.capacidad) < 0.3)
        .toList();

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Título ──
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'C e sT',
                          style: TextStyle(
                            fontSize: 54,
                            color: kText,
                            fontFamily: 'Billabong',
                          ),
                        ),
                        Text(
                          'inventario de despensa para el hogar',
                          style: TextStyle(color: kTextSub, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Mini cards ──
                Row(
                  children: [
                    _miniCard(
                      'Disponible',
                      restante,
                      kGreen,
                      Icons.savings_rounded,
                    ),
                    const SizedBox(width: 12),
                    _miniCard(
                      'Gastado',
                      widget.saldoOcupado,
                      kOrange,
                      Icons.arrow_upward_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Presupuesto compacto ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kCard2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Presupuesto mensual',
                              style: TextStyle(color: kTextSub, fontSize: 17),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: widget.presupuesto),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Text(
                                '\$${_fmt(v)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kText,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: pct),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) => LinearProgressIndicator(
                                  value: v,
                                  minHeight: 6,
                                  backgroundColor: kCard2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    barColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(pct * 100).toStringAsFixed(1)}% usado',
                              style: TextStyle(color: barColor, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _dialogo(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kCard2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kAccent.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: kAccent,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Stock bajo ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kCard2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stock bajo',
                            style: TextStyle(
                              color: kText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${stockBajos.length} productos',
                              style: TextStyle(
                                color: kOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (stockBajos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Stock normal',
                              style: TextStyle(color: kTextSub, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: stockBajos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final p = stockBajos[i];
                              final pct = p.capacidad > 0
                                  ? (p.cantidad / p.capacidad).clamp(0.0, 1.0)
                                  : 0.0;
                              final color = pct < 0.15 ? kOrange : kGold;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kCard2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: kAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(
                                        getIcono(p.emoji),
                                        color: kAccent,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.nombre,
                                            style: const TextStyle(
                                              color: kText,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 4,
                                              backgroundColor: kCard2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    color,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${p.cantidad}/${p.capacidad}',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Card familia ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kCard2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.home_outlined,
                                color: kAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _nombreFamilia.isEmpty
                                    ? 'Mi familia'
                                    : _nombreFamilia,
                                style: const TextStyle(
                                  color: kText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_nombresMiembros.length} miembros',
                              style: const TextStyle(
                                color: kAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Miembros
                      if (_nombresMiembros.isEmpty)
                        const Text(
                          'Cargando...',
                          style: TextStyle(color: kTextSub, fontSize: 12),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _nombresMiembros.map((nombre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kCard2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: kAccent.withOpacity(0.2),
                                    child: Text(
                                      nombre.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: kAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    nombre,
                                    style: const TextStyle(
                                      color: kText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      // Última modificación
                      if (widget.lastModifiedBy.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: kCard2, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: kTextSub,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Última modificación: ',
                              style: const TextStyle(
                                color: kTextSub,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              widget.lastModifiedBy,
                              style: const TextStyle(
                                color: kText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Agregar producto ──
                AnimatedCard(
                  onTap: widget.onAgregarRapido,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kGreen.withOpacity(0.15),
                          kAccent.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: kGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agregar producto',
                                style: TextStyle(
                                  color: kText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Acceso rápido al inventario',
                                style: TextStyle(color: kTextSub, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: kGreen,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String titulo, double valor, Color color, IconData icon) =>
      Expanded(
        child: AnimatedCard(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.35)),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.08), kCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: const TextStyle(color: kTextSub, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_fmt(valor)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _dialogo(BuildContext context) {
    final ctrl = TextEditingController(
      text: widget.presupuesto.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Presupuesto', style: TextStyle(color: kText)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: kText),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: const TextStyle(color: kAccent),
            labelText: 'Monto mensual',
            labelStyle: const TextStyle(color: kTextSub),
            filled: true,
            fillColor: kCard2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: kTextSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0) {
                widget.onEditarPresupuesto(v);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
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
