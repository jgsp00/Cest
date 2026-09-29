import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/producto.dart';
import '../widgets/animated_card.dart';
import '../widgets/product_card.dart';
import '../widgets/category_panel.dart';
import '../widgets/product_form.dart';

class PantallaInventario extends StatefulWidget {
  final List<Producto> productos;
  final Function(Producto) onAgregar;
  final Function(int) onEliminar;
  final Function(int, Producto) onEditar;
  final Function(int, int) onCambiarCantidad;

  const PantallaInventario({
    super.key,
    required this.productos,
    required this.onAgregar,
    required this.onEliminar,
    required this.onEditar,
    required this.onCambiarCantidad,
  });

  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  String _categoriaActiva = 'Todos';
  String _busqueda = '';

  List<String> get _categorias {
    final cats = widget.productos.map((p) => p.categoria).toSet().toList();
    cats.sort();
    return ['Todos', ...cats];
  }

  List<Producto> get _productosFiltrados {
    return widget.productos.where((p) {
      final coincideCategoria =
          _categoriaActiva == 'Todos' || p.categoria == _categoriaActiva;
      final coincideBusqueda =
          _busqueda.isEmpty ||
          p.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          p.categoria.toLowerCase().contains(_busqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _productosFiltrados;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventario',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filtrados.length} productos${_categoriaActiva != 'Todos' ? ' · $_categoriaActiva' : ''}',
                          style: const TextStyle(color: kTextSub, fontSize: 13),
                        ),
                      ],
                    ),
                    AnimatedCard(
                      onTap: () => ProductForm.mostrar(
                        categoriasExistentes: _categorias
                            .where((c) => c != 'Todos')
                            .toList(),
                        context: context,
                        editar: null,
                        index: -1,
                        onAgregar: widget.onAgregar,
                        onEditar: widget.onEditar,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kGreen.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_rounded, color: kGreen, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Agregar',
                              style: TextStyle(
                                color: kGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_outlined,
                              color: kTextSub,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _busqueda.isNotEmpty ||
                                      _categoriaActiva != 'Todos'
                                  ? 'Sin resultados'
                                  : 'No hay productos aún',
                              style: const TextStyle(color: kTextSub),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(36, 0, 20, 100),
                        itemCount: filtrados.length,
                        itemBuilder: (_, i) {
                          final p = filtrados[i];
                          final indexReal = widget.productos.indexOf(p);
                          return ProductCard(
                            producto: p,
                            onEditar: () => ProductForm.mostrar(
                              categoriasExistentes: _categorias
                                  .where((c) => c != 'Todos')
                                  .toList(),
                              context: context,
                              editar: p,
                              index: indexReal,
                              onAgregar: widget.onAgregar,
                              onEditar: widget.onEditar,
                            ),
                            onEliminar: () => widget.onEliminar(indexReal),
                            onSumar: () =>
                                widget.onCambiarCantidad(indexReal, 1),
                            onRestar: () =>
                                widget.onCambiarCantidad(indexReal, -1),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Panel lateral de categorías
          CategoryPanel(
            categorias: _categorias,
            categoriaActiva: _categoriaActiva,
            busqueda: _busqueda,
            onCategoriaSeleccionada: (cat) =>
                setState(() => _categoriaActiva = cat),
            onBusquedaCambiada: (v) => setState(() => _busqueda = v),
          ),
        ],
      ),
    );
  }
}
