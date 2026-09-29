import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../services/family_service.dart';
import '../services/firestore_service.dart';
import 'main_screen.dart';
import 'auth_screen.dart';
import 'family_screen.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga>
    with TickerProviderStateMixin {
  late AnimationController _ctrlLogo;
  late AnimationController _ctrlTexto;
  late AnimationController _ctrlSlogan;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textoOpacity;
  late Animation<Offset> _textoSlide;
  late Animation<double> _sloganOpacity;
  late Animation<Offset> _sloganSlide;

  @override
  void initState() {
    super.initState();

    _ctrlLogo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrlLogo, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrlLogo, curve: Curves.easeIn));

    _ctrlTexto = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrlTexto, curve: Curves.easeIn));
    _textoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrlTexto, curve: Curves.easeOutCubic));

    _ctrlSlogan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sloganOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrlSlogan, curve: Curves.easeIn));
    _sloganSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrlSlogan, curve: Curves.easeOutCubic));

    _iniciarAnimaciones();
  }

  Future<void> _iniciarAnimaciones() async {
    await _ctrlLogo.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _ctrlTexto.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _ctrlSlogan.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _navegar();
  }

  Future<void> _navegar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _ir(const PantallaAuth());
      return;
    }

    final familyId = await FamilyService.obtenerFamilyId(user.uid);
    if (!mounted) return;

    if (familyId == null) {
      _ir(const PantallaFamilia());
      return;
    }

    final data = await FirestoreService.cargar(familyId);
    if (!mounted) return;

    _ir(
      PantallaPrincipal(
        familyId: familyId,
        presupuestoInicial: data['presupuesto'],
        productosIniciales: data['productos'],
        comprasIniciales: data['compras'],
      ),
    );
  }

  void _ir(Widget pantalla) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => pantalla,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _ctrlLogo.dispose();
    _ctrlTexto.dispose();
    _ctrlSlogan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [kAccent.withOpacity(0.08), kBg],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrlLogo,
              builder: (_, child) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(scale: _logoScale.value, child: child),
              ),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(44),
                  border: Border.all(
                    color: kAccent.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.15),
                      blurRadius: 400,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(44),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _ctrlTexto,
              builder: (_, child) => Opacity(
                opacity: _textoOpacity.value,
                child: SlideTransition(position: _textoSlide, child: child),
              ),
              child: const Text(
                'Cest',
                style: TextStyle(
                  fontSize: 100,
                  color: kText,
                  fontFamily: 'Billabong',
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _ctrlSlogan,
              builder: (_, child) => Opacity(
                opacity: _sloganOpacity.value,
                child: SlideTransition(position: _sloganSlide, child: child),
              ),
              child: const Text(
                'Inventario de despensa para el hogar',
                style: TextStyle(
                  color: kTextSub,
                  fontSize: 20,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: kAccent.withOpacity(0.6),
                strokeWidth: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
