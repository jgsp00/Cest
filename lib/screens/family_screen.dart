import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/family_service.dart';
import '../services/firestore_service.dart';
import 'main_screen.dart';

class PantallaFamilia extends StatefulWidget {
  final bool desdePerfil;
  const PantallaFamilia({super.key, this.desdePerfil = false});

  @override
  State<PantallaFamilia> createState() => _PantallaFamiliaState();
}

class _PantallaFamiliaState extends State<PantallaFamilia> {
  bool _creando = true;
  bool _cargando = false;
  String? _error;

  final _nombreFamiliaCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreFamiliaCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final uid = AuthService.currentUser!.uid;
    String? error;

    if (_creando) {
      if (_nombreFamiliaCtrl.text.trim().isEmpty) {
        setState(() {
          _error = 'Ingresa un nombre para la familia.';
          _cargando = false;
        });
        return;
      }
      await FamilyService.crearFamilia(
        uid: uid,
        nombreFamilia: _nombreFamiliaCtrl.text.trim(),
      );
    } else {
      if (_codigoCtrl.text.trim().isEmpty) {
        setState(() {
          _error = 'Ingresa el código de invitación.';
          _cargando = false;
        });
        return;
      }
      error = await FamilyService.unirseConCodigo(
        uid: uid,
        codigo: _codigoCtrl.text.trim(),
      );
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _error = error;
        _cargando = false;
      });
      return;
    }

    final familyId = await FamilyService.obtenerFamilyId(uid);
    if (!mounted) return;

    if (familyId == null) {
      setState(() {
        _error = 'Error al obtener la familia. Intenta de nuevo.';
        _cargando = false;
      });
      return;
    }

    if (widget.desdePerfil) {
      Navigator.pop(context);
      return;
    }

    final data = await FirestoreService.cargar(familyId);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaPrincipal(
          familyId: familyId,
          presupuestoInicial: data['presupuesto'],
          productosIniciales: data['productos'],
          comprasIniciales: data['compras'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.desdePerfil)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: kText,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                if (widget.desdePerfil) const SizedBox(height: 20),

                const Icon(Icons.home_outlined, color: kAccent, size: 56),
                const SizedBox(height: 20),
                const Text(
                  'Tu familia',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crea o únete a una familia\npara compartir la despensa',
                  style: TextStyle(color: kTextSub, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _Tab(
                        texto: 'Crear familia',
                        activo: _creando,
                        onTap: () => setState(() {
                          _creando = true;
                          _error = null;
                        }),
                      ),
                      _Tab(
                        texto: 'Unirse',
                        activo: !_creando,
                        onTap: () => setState(() {
                          _creando = false;
                          _error = null;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                if (_creando)
                  TextField(
                    controller: _nombreFamiliaCtrl,
                    style: const TextStyle(color: kText),
                    decoration: _inputDecoration(
                      'Nombre de la familia',
                      'Ej: Familia García',
                      Icons.group_outlined,
                    ),
                  )
                else
                  TextField(
                    controller: _codigoCtrl,
                    style: const TextStyle(color: kText),
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDecoration(
                      'Código de invitación',
                      'Ej: CEST-4X9K',
                      Icons.vpn_key_outlined,
                    ),
                  ),

                const SizedBox(height: 24),

                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _creando ? 'Crear familia' : 'Unirme',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icono) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: kTextSub, fontSize: 13),
      labelStyle: const TextStyle(color: kTextSub),
      prefixIcon: Icon(icono, color: kTextSub, size: 20),
      filled: true,
      fillColor: kCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kAccent.withOpacity(0.6)),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  const _Tab({required this.texto, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: activo ? kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: activo ? Colors.white : kTextSub,
              fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
