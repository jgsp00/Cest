import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/iconos.dart';
import '../models/producto.dart';

class ProductForm {
  static void mostrar({
    required BuildContext context,
    required Producto? editar,
    required int index,
    required Function(Producto) onAgregar,
    required Function(int, Producto) onEditar,
    List<String> categoriasExistentes = const [],
  }) {
    final nombreCtrl = TextEditingController(text: editar?.nombre ?? '');
    final precioCtrl = TextEditingController(
      text: editar != null ? editar.precio.toStringAsFixed(0) : '',
    );
    final catCtrl = TextEditingController(text: editar?.categoria ?? '');
    final capCtrl = TextEditingController(
      text: editar != null ? editar.capacidad.toString() : '10',
    );

    String iconoSel = editar?.emoji ?? kIconoDefault;
    final esEditar = editar != null;
    const categoriasDefault = [
      'Frutas',
      'Verduras',
      'Lácteos',
      'Huevos',
      'Congelados',
      'Embutidos',
      'Despensa',
      'Carnes y Pescados',
      'Panadería y Pastelería',
      'Licores, Bebidas y Aguas',
      'Snacks',
      'Limpieza',
    ];
    final categoriasOrdenadas = {
      ...categoriasDefault,
      ...categoriasExistentes,
    }.toList()..sort();
    final iconoKeys = kIconosProducto.keys.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final filtradas = categoriasOrdenadas
              .where(
                (c) => c.toLowerCase().contains(catCtrl.text.toLowerCase()),
              )
              .toList();

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kCard2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  esEditar ? 'Editar Producto' : 'Nuevo Producto',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de iconos
                const Text(
                  'Ícono',
                  style: TextStyle(color: kTextSub, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: iconoKeys.length,
                    itemBuilder: (_, i) {
                      final key = iconoKeys[i];
                      final isSelected = iconoSel == key;
                      final color = esEditar ? kAccent : kGreen;
                      return GestureDetector(
                        onTap: () => setS(() => iconoSel = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.2) : kCard2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            getIcono(key),
                            color: isSelected ? color : kTextSub,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                _campo(nombreCtrl, 'Nombre', null),
                const SizedBox(height: 10),

                // Campo categoría con filtro
                TextField(
                  controller: catCtrl,
                  style: const TextStyle(color: kText),
                  onChanged: (_) => setS(() {}),
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: const TextStyle(color: kTextSub, fontSize: 13),
                    filled: true,
                    fillColor: kCard2,
                    suffixIcon: catCtrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setS(() => catCtrl.clear()),
                            child: const Icon(
                              Icons.close_rounded,
                              color: kTextSub,
                              size: 18,
                            ),
                          )
                        : null,
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

                // Chips de categorías filtradas
                if (categoriasOrdenadas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filtradas.map((cat) {
                      final isSelected = catCtrl.text == cat;
                      return GestureDetector(
                        onTap: () => setS(() => catCtrl.text = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kAccent.withOpacity(0.2)
                                : kCard2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? kAccent : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? kAccent : kText,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        precioCtrl,
                        'Precio unitario',
                        TextInputType.number,
                        prefix: '\$ ',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _campo(
                        capCtrl,
                        'Capacidad máx',
                        TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: esEditar ? kAccent : kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (nombreCtrl.text.isEmpty) return;
                      final p = Producto(
                        nombre: nombreCtrl.text,
                        cantidad: esEditar ? editar.cantidad : 0,
                        capacidad: int.tryParse(capCtrl.text) ?? 10,
                        precio: double.tryParse(precioCtrl.text) ?? 0,
                        categoria: catCtrl.text.isEmpty
                            ? 'General'
                            : catCtrl.text,
                        emoji: iconoSel,
                      );
                      if (esEditar) {
                        onEditar(index, p);
                      } else {
                        onAgregar(p);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      esEditar ? 'Guardar Cambios' : 'Agregar Producto',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _campo(
    TextEditingController ctrl,
    String label,
    TextInputType? tipo, {
    String? prefix,
  }) => TextField(
    controller: ctrl,
    keyboardType: tipo,
    style: const TextStyle(color: kText),
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefix,
      prefixStyle: const TextStyle(color: kAccent),
      labelStyle: const TextStyle(color: kTextSub, fontSize: 13),
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
  );
}
