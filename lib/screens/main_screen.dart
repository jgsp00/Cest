import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/producto.dart';
import '../models/compra.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/product_form.dart';
import '../data/inventario_default.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class PantallaPrincipal extends StatefulWidget {
  final String familyId;
  final double presupuestoInicial;
  final List<Producto> productosIniciales;
  final List<Compra> comprasIniciales;

  const PantallaPrincipal({
    super.key,
    required this.familyId,
    required this.presupuestoInicial,
    required this.productosIniciales,
    required this.comprasIniciales,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 1);
  int _paginaActual = 1;
  late double presupuestoTotal;
  late List<Producto> productos;
  late List<Compra> compras;
  String _lastModifiedBy = '';

  StreamSubscription? _streamSub;
  bool _actualizandoDesdeStream = false;

  String get _nombreUsuario =>
      AuthService.currentUser?.displayName ?? 'Desconocido';

  @override
  void initState() {
    super.initState();
    presupuestoTotal = widget.presupuestoInicial;

    final esUsuarioNuevo = widget.productosIniciales.isEmpty;

    // Si es usuario nuevo (sin productos), carga el inventario default
    productos = esUsuarioNuevo
        ? List.from(inventarioDefault)
        : widget.productosIniciales;

    compras = widget.comprasIniciales;

    productos.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );

    // Si es usuario nuevo, guardar el inventario default en Firestore
    // para que el stream no lo sobreescriba con lista vacía
    if (esUsuarioNuevo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _guardar();
      });
    }

    _streamSub = FirestoreService.stream(widget.familyId).listen((data) {
      if (!mounted || _actualizandoDesdeStream) return;
      setState(() {
        presupuestoTotal = data['presupuesto'];
        productos = data['productos'];
        compras = data['compras'];
        _lastModifiedBy = data['lastModifiedBy'] ?? '';
        productos.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
      });
    });
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    _actualizandoDesdeStream = true;
    await FirestoreService.guardar(
      familyId: widget.familyId,
      presupuesto: presupuestoTotal,
      productos: productos,
      compras: compras,
      modificadoPor: _nombreUsuario,
    );
    _actualizandoDesdeStream = false;
  }

  double get saldoOcupado =>
      productos.fold(0, (s, p) => s + (p.precio * p.cantidad));
  int get totalUnidades => productos.fold(0, (s, p) => s + p.cantidad);
  int get capacidadTotal => productos.fold(0, (s, p) => s + p.capacidad);

  void _agregarProducto(Producto p) {
    setState(() {
      productos.add(p);
      productos.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    });
    if (p.cantidad > 0) {
      compras.add(
        Compra(
          nombre: p.nombre,
          emoji: p.emoji,
          monto: p.precio * p.cantidad,
          cantidad: p.cantidad,
          fecha: DateTime.now(),
          categoria: p.categoria,
        ),
      );
    }
    _guardar();
  }

  void _editarProducto(int i, Producto p) {
    setState(() => productos[i] = p);
    _guardar();
  }

  void _eliminarProducto(int i) {
    setState(() => productos.removeAt(i));
    _guardar();
  }

  void _cambiarCantidad(int i, int delta) {
    final p = productos[i];
    final nueva = (p.cantidad + delta).clamp(0, p.capacidad);
    if (nueva == p.cantidad) return;
    setState(() => productos[i].cantidad = nueva);
    if (delta > 0) {
      compras.add(
        Compra(
          nombre: p.nombre,
          emoji: p.emoji,
          monto: p.precio * delta,
          cantidad: delta,
          fecha: DateTime.now(),
          categoria: p.categoria,
        ),
      );
    }
    _guardar();
  }

  void _editarPresupuesto(double v) {
    setState(() => presupuestoTotal = v);
    _guardar();
  }

  void _irAInventarioYAgregar() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        ProductForm.mostrar(
          context: context,
          editar: null,
          index: -1,
          onAgregar: _agregarProducto,
          onEditar: _editarProducto,
          categoriasExistentes: productos
              .map((p) => p.categoria)
              .toSet()
              .toList(),
        );
      }
    });
  }

  static const _navItems = [
    (icon: Icons.bar_chart_rounded, label: 'Stats'),
    (icon: Icons.home_rounded, label: 'Inicio'),
    (icon: Icons.inventory_2_outlined, label: 'Stock'),
    (icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          ClipRect(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (i) => setState(() => _paginaActual = i),
              children: [
                PantallaEstadisticas(compras: compras),
                PantallaInicio(
                  presupuesto: presupuestoTotal,
                  saldoOcupado: saldoOcupado,
                  totalUnidades: totalUnidades,
                  capacidadTotal: capacidadTotal,
                  productos: productos,
                  familyId: widget.familyId,
                  lastModifiedBy: _lastModifiedBy,
                  onEditarPresupuesto: _editarPresupuesto,
                  onAgregarRapido: _irAInventarioYAgregar,
                ),
                PantallaInventario(
                  productos: productos,
                  onAgregar: _agregarProducto,
                  onEliminar: _eliminarProducto,
                  onEditar: _editarProducto,
                  onCambiarCantidad: _cambiarCantidad,
                ),
                const PantallaPerfil(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [kBg, kBg.withOpacity(0.95), kBg.withOpacity(0)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _navItems.length,
                  (i) => _navItem(i, _navItems[i].icon, _navItems[i].label),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icono, String label) {
    final isActive = _paginaActual == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? kAccent.withOpacity(0.18) : kCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? kAccent : kCard2,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive ? kAccent.withOpacity(0.35) : Colors.transparent,
              blurRadius: isActive ? 16 : 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              color: isActive ? kAccent : kTextSub,
              size: isActive ? 22 : 18,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: kAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
