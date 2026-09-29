import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/family_service.dart';
import '../services/firestore_service.dart';
import 'family_screen.dart';
import 'main_screen.dart';

class PantallaAuth extends StatefulWidget {
  const PantallaAuth({super.key});

  @override
  State<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends State<PantallaAuth> {
  bool _esLogin = true;
  bool _cargando = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      String? error;

      // ── Paso 1: Auth ───────────────────────────────────────────────
      debugPrint('>>> [Auth] Iniciando login...');
      if (_esLogin) {
        error = await AuthService.login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
      } else {
        if (_nombreCtrl.text.trim().isEmpty) {
          setState(() {
            _error = 'Ingresa tu nombre.';
            _cargando = false;
          });
          return;
        }
        error = await AuthService.registrar(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          nombre: _nombreCtrl.text.trim(),
        );
      }
      debugPrint('>>> [Auth] Resultado: ${error ?? 'OK'}');

      if (!mounted) return;

      if (error != null) {
        setState(() {
          _error = error;
          _cargando = false;
        });
        return;
      }

      // ── Paso 2: Obtener familyId ───────────────────────────────────
      final uid = AuthService.currentUser!.uid;
      debugPrint('>>> [Firestore] Obteniendo familyId para uid: $uid');
      final familyId = await FamilyService.obtenerFamilyId(uid).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception('timeout_family'),
      );
      debugPrint('>>> [Firestore] familyId: $familyId');

      if (!mounted) return;

      if (familyId == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaFamilia()),
        );
        return;
      }

      // ── Paso 3: Cargar datos ───────────────────────────────────────
      debugPrint('>>> [Firestore] Cargando datos para familyId: $familyId');
      final data = await FirestoreService.cargar(familyId).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception('timeout_data'),
      );
      debugPrint('>>> [Firestore] Datos cargados OK');

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
    } catch (e) {
      debugPrint('>>> [ERROR] $e');
      if (!mounted) return;
      String mensaje;
      final msg = e.toString();
      if (msg.contains('timeout_family')) {
        mensaje = 'No se pudo conectar con la base de datos. Intenta de nuevo.';
      } else if (msg.contains('timeout_data')) {
        mensaje = 'No se pudieron cargar los datos. Intenta de nuevo.';
      } else if (msg.contains('timeout')) {
        mensaje = 'La conexión tardó demasiado. Verifica tu internet.';
      } else {
        mensaje = 'Error de conexión. Verifica tu internet e intenta de nuevo.';
      }
      setState(() {
        _error = mensaje;
        _cargando = false;
      });
    }
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
                const Text(
                  'Cest',
                  style: TextStyle(
                    fontSize: 80,
                    fontFamily: 'Billabong',
                    color: kText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _esLogin ? 'Inicia sesión' : 'Crea tu cuenta',
                  style: const TextStyle(color: kTextSub, fontSize: 16),
                ),
                const SizedBox(height: 40),

                if (!_esLogin) ...[
                  _Campo(
                    ctrl: _nombreCtrl,
                    label: 'Nombre',
                    hint: 'Ej: Juan Pérez',
                    icono: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                ],

                _Campo(
                  ctrl: _emailCtrl,
                  label: 'Correo electrónico',
                  hint: 'Ej: juan@gmail.com',
                  icono: Icons.email_outlined,
                  teclado: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _Campo(
                  ctrl: _passwordCtrl,
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  icono: Icons.lock_outline,
                  esPassword: true,
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
                            _esLogin ? 'Entrar' : 'Registrarme',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => setState(() {
                    _esLogin = !_esLogin;
                    _error = null;
                  }),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: kTextSub, fontSize: 14),
                      children: [
                        TextSpan(
                          text: _esLogin
                              ? '¿No tienes cuenta? '
                              : '¿Ya tienes cuenta? ',
                        ),
                        TextSpan(
                          text: _esLogin ? 'Regístrate' : 'Inicia sesión',
                          style: const TextStyle(
                            color: kAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
}

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icono;
  final bool esPassword;
  final TextInputType teclado;

  const _Campo({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icono,
    this.esPassword = false,
    this.teclado = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: esPassword,
      keyboardType: teclado,
      style: const TextStyle(color: kText),
      decoration: InputDecoration(
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
      ),
    );
  }
}
