import 'package:firebase_auth/firebase_auth.dart';
import 'family_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static const _timeout = Duration(seconds: 12);

  static User? get currentUser => _auth.currentUser;

  static Future<String?> registrar({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(_timeout);
      await cred.user!.updateDisplayName(nombre).timeout(_timeout);
      await FamilyService.crearUsuario(
        uid: cred.user!.uid,
        nombre: nombre,
        email: email,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    } catch (_) {
      return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
    }
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(_timeout);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    } catch (_) {
      return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static String _mensajeError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'Correo inválido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      default:
        return 'Ocurrió un error. Intenta de nuevo.';
    }
  }
}
