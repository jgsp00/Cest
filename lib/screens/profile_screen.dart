import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/family_service.dart';
import 'auth_screen.dart';
import 'family_screen.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  Map<String, dynamic>? _familia;
  List<Map<String, dynamic>> _miembros = [];
  String? _familyId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final user = AuthService.currentUser;
    if (user == null) return;

    final familyId = await FamilyService.obtenerFamilyId(user.uid);

    if (familyId == null) {
      if (mounted)
        setState(() {
          _familia = null;
          _familyId = null;
          _cargando = false;
        });
      return;
    }

    final familia = await FamilyService.obtenerFamilia(familyId);
    if (familia == null) {
      if (mounted)
        setState(() {
          _familia = null;
          _familyId = null;
          _cargando = false;
        });
      return;
    }

    final members = List<String>.from(familia['members'] ?? []);
    final miembros = <Map<String, dynamic>>[];
    for (final uid in members) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) miembros.add({...doc.data()!, 'uid': uid});
    }

    if (mounted) {
      setState(() {
        _familia = familia;
        _familyId = familyId;
        _miembros = miembros;
        _cargando = false;
      });
    }
  }

  bool get _esLider =>
      _familia != null &&
      _familia!['createdBy'] == AuthService.currentUser?.uid;

  Future<void> _cerrarSesion() async {
    final confirmar = await _confirmar(
      titulo: 'Cerrar sesión',
      mensaje: '¿Estás seguro que quieres salir?',
      boton: 'Salir',
    );
    if (confirmar != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PantallaAuth()),
      (_) => false,
    );
  }

  Future<void> _salirDeFamilia() async {
    final confirmar = await _confirmar(
      titulo: 'Salir de la familia',
      mensaje: 'Dejarás de tener acceso a la despensa compartida.',
      boton: 'Salir',
    );
    if (confirmar != true || _familyId == null) return;
    await FamilyService.salirDeFamilia(
      uid: AuthService.currentUser!.uid,
      familyId: _familyId!,
    );
    await _cargarDatos();
  }

  Future<void> _eliminarMiembro(Map<String, dynamic> miembro) async {
    final confirmar = await _confirmar(
      titulo: 'Eliminar miembro',
      mensaje: '¿Quieres sacar a ${miembro['name']} de la familia?',
      boton: 'Eliminar',
    );
    if (confirmar != true || _familyId == null) return;
    await FamilyService.eliminarMiembro(
      uidMiembro: miembro['uid'],
      familyId: _familyId!,
    );
    await _cargarDatos();
  }

  Future<void> _transferirLiderazgo(Map<String, dynamic> miembro) async {
    final confirmar = await _confirmar(
      titulo: 'Transferir liderazgo',
      mensaje: '${miembro['name']} pasará a ser el líder de la familia.',
      boton: 'Transferir',
    );
    if (confirmar != true || _familyId == null) return;
    await FamilyService.transferirLiderazgo(
      nuevoLiderUid: miembro['uid'],
      familyId: _familyId!,
    );
    await _cargarDatos();
  }

  Future<void> _eliminarFamilia() async {
    final confirmar = await _confirmar(
      titulo: 'Eliminar familia',
      mensaje:
          'Se eliminará toda la despensa y todos los miembros quedarán sin familia. Esta acción no se puede deshacer.',
      boton: 'Eliminar',
      peligroso: true,
    );
    if (confirmar != true || _familyId == null) return;
    await FamilyService.eliminarFamilia(familyId: _familyId!);
    await _cargarDatos();
  }

  Future<bool?> _confirmar({
    required String titulo,
    required String mensaje,
    required String boton,
    bool peligroso = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo, style: const TextStyle(color: kText)),
        content: Text(mensaje, style: const TextStyle(color: kTextSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: kTextSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              boton,
              style: TextStyle(
                color: peligroso ? Colors.redAccent : kAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copiarCodigo(String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código copiado al portapapeles'),
        backgroundColor: kAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarOpcionesMiembro(Map<String, dynamic> miembro) {
    final esYo = miembro['uid'] == AuthService.currentUser?.uid;
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              miembro['name'] ?? '',
              style: const TextStyle(
                color: kText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              miembro['email'] ?? '',
              style: const TextStyle(color: kTextSub, fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (!esYo && _esLider) ...[
              _opcionSheet(
                icono: Icons.star_outline_rounded,
                label: 'Transferir liderazgo',
                color: kGold,
                onTap: () {
                  Navigator.pop(context);
                  _transferirLiderazgo(miembro);
                },
              ),
              const SizedBox(height: 12),
              _opcionSheet(
                icono: Icons.person_remove_outlined,
                label: 'Eliminar de la familia',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _eliminarMiembro(miembro);
                },
              ),
            ] else
              const Text(
                'No hay acciones disponibles',
                style: TextStyle(color: kTextSub),
              ),
          ],
        ),
      ),
    );
  }

  Widget _opcionSheet({
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(
                  color: kAccent,
                  strokeWidth: 2,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Mi cuenta ──
                    _Seccion(
                      titulo: 'Mi cuenta',
                      child: Column(
                        children: [
                          _Fila(
                            icono: Icons.person_outline,
                            label: 'Nombre',
                            valor: user?.displayName ?? '—',
                          ),
                          const SizedBox(height: 12),
                          _Fila(
                            icono: Icons.email_outlined,
                            label: 'Correo',
                            valor: user?.email ?? '—',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Con familia ──
                    if (_familia != null) ...[
                      _Seccion(
                        titulo: 'Mi familia',
                        child: Column(
                          children: [
                            _Fila(
                              icono: Icons.groups_outlined,
                              label: 'Nombre',
                              valor: _familia!['name'] ?? '—',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: kAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.vpn_key_outlined,
                                    color: kAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Código de invitación',
                                          style: TextStyle(
                                            color: kTextSub,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _familia!['inviteCode'] ?? '—',
                                          style: const TextStyle(
                                            color: kAccent,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _copiarCodigo(
                                      _familia!['inviteCode'] ?? '',
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: kAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.copy_rounded,
                                        color: kAccent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Miembros ──
                      _Seccion(
                        titulo: 'Miembros (${_miembros.length})',
                        child: Column(
                          children: _miembros.map((m) {
                            final esYo = m['uid'] == user?.uid;
                            final esLiderMiembro =
                                m['uid'] == _familia!['createdBy'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: kAccent.withOpacity(0.2),
                                    radius: 20,
                                    child: Text(
                                      (m['name'] as String? ?? '?')
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: kAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              m['name'] ?? '—',
                                              style: const TextStyle(
                                                color: kText,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (esYo) ...[
                                              const SizedBox(width: 6),
                                              _badge('Tú', kAccent),
                                            ],
                                            if (esLiderMiembro) ...[
                                              const SizedBox(width: 6),
                                              _badge('Líder', kGold),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          m['email'] ?? '—',
                                          style: const TextStyle(
                                            color: kTextSub,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botón opciones (solo líder y para otros miembros)
                                  if (_esLider && !esYo)
                                    GestureDetector(
                                      onTap: () => _mostrarOpcionesMiembro(m),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: kCard2,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.more_horiz_rounded,
                                          color: kTextSub,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Acciones de familia ──
                      if (!_esLider)
                        _botonAccion(
                          label: 'Salir de la familia',
                          icono: Icons.exit_to_app_rounded,
                          color: Colors.redAccent,
                          onTap: _salirDeFamilia,
                        ),

                      if (_esLider)
                        _botonAccion(
                          label: 'Eliminar familia',
                          icono: Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          onTap: _eliminarFamilia,
                          subtitulo: 'Todos los miembros quedarán sin familia',
                        ),

                      const SizedBox(height: 12),
                    ],

                    // ── Sin familia ──
                    if (_familia == null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: kCard2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  color: kTextSub,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sin familia',
                                  style: TextStyle(
                                    color: kTextSub,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PantallaFamilia(),
                                    ),
                                  );
                                  _cargarDatos();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Crear o unirse a una familia',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Cerrar sesión ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _cerrarSesion,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _badge(String texto, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      texto,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  Widget _botonAccion({
    required String label,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
    String? subtitulo,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  if (subtitulo != null)
                    Text(
                      subtitulo,
                      style: TextStyle(
                        color: color.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: kTextSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _Fila({required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: kTextSub, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: kTextSub, fontSize: 12)),
            const SizedBox(height: 2),
            Text(valor, style: const TextStyle(color: kText, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}
