import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyService {
  static final _db = FirebaseFirestore.instance;

  static const _timeout = Duration(seconds: 12);

  static Future<void> crearUsuario({
    required String uid,
    required String nombre,
    required String email,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .set({'name': nombre, 'email': email, 'familyId': null})
        .timeout(_timeout);
  }

  static Future<String?> obtenerFamilyId(String uid) async {
    final doc = await _db.collection('users').doc(uid).get().timeout(_timeout);
    return doc.data()?['familyId'] as String?;
  }

  static Future<void> crearFamilia({
    required String uid,
    required String nombreFamilia,
  }) async {
    final codigo = _generarCodigo();
    final ref = _db.collection('families').doc();
    await ref
        .set({
          'name': nombreFamilia,
          'createdBy': uid,
          'inviteCode': codigo,
          'members': [uid],
        })
        .timeout(_timeout);
    await _db
        .collection('users')
        .doc(uid)
        .update({'familyId': ref.id})
        .timeout(_timeout);
  }

  static Future<String?> unirseConCodigo({
    required String uid,
    required String codigo,
  }) async {
    final query = await _db
        .collection('families')
        .where('inviteCode', isEqualTo: codigo.toUpperCase())
        .limit(1)
        .get()
        .timeout(_timeout);

    if (query.docs.isEmpty) return 'Código no encontrado.';

    final familyDoc = query.docs.first;
    final members = List<String>.from(familyDoc['members']);
    if (members.contains(uid)) return 'Ya eres miembro de esta familia.';

    members.add(uid);
    await familyDoc.reference.update({'members': members}).timeout(_timeout);
    await _db
        .collection('users')
        .doc(uid)
        .update({'familyId': familyDoc.id})
        .timeout(_timeout);
    return null;
  }

  static Future<Map<String, dynamic>?> obtenerFamilia(String familyId) async {
    final doc = await _db
        .collection('families')
        .doc(familyId)
        .get()
        .timeout(_timeout);
    return doc.data();
  }

  static Future<void> salirDeFamilia({
    required String uid,
    required String familyId,
  }) async {
    final familyRef = _db.collection('families').doc(familyId);
    final familyDoc = await familyRef.get().timeout(_timeout);
    final members = List<String>.from(familyDoc['members']);
    members.remove(uid);
    await familyRef.update({'members': members}).timeout(_timeout);
    await _db
        .collection('users')
        .doc(uid)
        .update({'familyId': null})
        .timeout(_timeout);
  }

  static Future<void> eliminarMiembro({
    required String uidMiembro,
    required String familyId,
  }) async {
    final familyRef = _db.collection('families').doc(familyId);
    final familyDoc = await familyRef.get().timeout(_timeout);
    final members = List<String>.from(familyDoc['members']);
    members.remove(uidMiembro);
    await familyRef.update({'members': members}).timeout(_timeout);
    await _db
        .collection('users')
        .doc(uidMiembro)
        .update({'familyId': null})
        .timeout(_timeout);
  }

  static Future<void> transferirLiderazgo({
    required String nuevoLiderUid,
    required String familyId,
  }) async {
    await _db
        .collection('families')
        .doc(familyId)
        .update({'createdBy': nuevoLiderUid})
        .timeout(_timeout);
  }

  static Future<void> eliminarFamilia({required String familyId}) async {
    final familyRef = _db.collection('families').doc(familyId);
    final familyDoc = await familyRef.get().timeout(_timeout);

    final members = List<String>.from(familyDoc['members'] ?? []);
    for (final uid in members) {
      await _db
          .collection('users')
          .doc(uid)
          .update({'familyId': null})
          .timeout(_timeout);
    }

    await familyRef.collection('data').doc('pantry').delete().timeout(_timeout);
    await familyRef
        .collection('data')
        .doc('historial')
        .delete()
        .timeout(_timeout);

    await familyRef.delete().timeout(_timeout);
  }

  static String _generarCodigo() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    final codigo = List.generate(
      4,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'CEST-$codigo';
  }
}
