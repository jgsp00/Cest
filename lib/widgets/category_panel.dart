import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CategoryPanel extends StatefulWidget {
  final List<String> categorias;
  final String categoriaActiva;
  final String busqueda;
  final Function(String) onCategoriaSeleccionada;
  final Function(String) onBusquedaCambiada;

  const CategoryPanel({
    super.key,
    required this.categorias,
    required this.categoriaActiva,
    required this.busqueda,
    required this.onCategoriaSeleccionada,
    required this.onBusquedaCambiada,
  });

  @override
  State<CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<CategoryPanel>
    with SingleTickerProviderStateMixin {
  bool _panelAbierto = false;
  late AnimationController _panelCtrl;
  late Animation<double> _panelAnim;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _panelAnim = CurvedAnimation(
      parent: _panelCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _panelAbierto = !_panelAbierto);
    if (_panelAbierto)
      _panelCtrl.forward();
    else
      _panelCtrl.reverse();
  }

  void _cerrarPanel() {
    setState(() => _panelAbierto = false);
    _panelCtrl.reverse();
  }

  String _emojiCategoria(String cat) {
    final map = {
      'granos': '🌾',
      'lácteos': '🥛',
      'lacteos': '🥛',
      'proteínas': '🥩',
      'proteinas': '🥩',
      'panadería': '🍞',
      'panaderia': '🍞',
      'aceites': '🫙',
      'frutas': '🍎',
      'verduras': '🥦',
      'limpieza': '🧹',
      'higiene': '🧴',
      'bebidas': '🧃',
      'snacks': '🍫',
      'condimentos': '🧂',
    };
    return map[cat.toLowerCase()] ?? '🏷️';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _panelAnim,
      builder: (_, __) {
        final expanded = _panelAnim.value;
        const panelWidth = 180.0;

        return Stack(
          children: [
            // Overlay oscuro
            if (_panelAbierto)
              GestureDetector(
                onTap: _cerrarPanel,
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),

            // Panel + pestaña
            Positioned(
              left: -panelWidth * (1 - expanded),
              top: 0,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Panel de categorías
                  Container(
                    width: panelWidth,
                    margin: const EdgeInsets.symmetric(vertical: 60),
                    decoration: BoxDecoration(
                      color: kCard.withOpacity(0.97),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(20),
                      ),
                      border: Border.all(color: kAccent.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(color: kText, fontSize: 13),
                            onChanged: widget.onBusquedaCambiada,
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: const TextStyle(
                                color: kTextSub,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: kTextSub,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: kCard2,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: kAccent,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Categorías',
                              style: TextStyle(
                                color: kTextSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: widget.categorias.length,
                            itemBuilder: (_, i) {
                              final cat = widget.categorias[i];
                              final isActive = widget.categoriaActiva == cat;
                              return GestureDetector(
                                onTap: () {
                                  widget.onCategoriaSeleccionada(cat);
                                  _cerrarPanel();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? kAccent.withOpacity(0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isActive
                                          ? kAccent.withOpacity(0.4)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        cat == 'Todos'
                                            ? '📦'
                                            : _emojiCategoria(cat),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            color: isActive ? kAccent : kText,
                                            fontSize: 13,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isActive)
                                        const Icon(
                                          Icons.check_rounded,
                                          color: kAccent,
                                          size: 14,
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

                  // Pestaña colapsada
                  GestureDetector(
                    onTap: _togglePanel,
                    child: Container(
                      width: 24,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _panelAbierto
                            ? kAccent.withOpacity(0.75)
                            : const Color.fromARGB(
                                255,
                                142,
                                150,
                                161,
                              ).withOpacity(0.25),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: _panelAbierto
                              ? kAccent.withOpacity(0.5)
                              : const Color.fromARGB(
                                  255,
                                  67,
                                  73,
                                  82,
                                ).withOpacity(0.6),
                        ),
                      ),
                      child: Icon(
                        _panelAbierto
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: _panelAbierto ? kAccent : kTextSub,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
