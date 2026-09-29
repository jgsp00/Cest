import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';
import '../models/compra.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> guardar({
    required String familyId,
    required double presupuesto,
    required List<Producto> productos,
    required List<Compra> compras,
    String? modificadoPor,
  }) async {
    final familyRef = _db.collection('families').doc(familyId);

    await familyRef.collection('data').doc('pantry').set({
      'presupuesto': presupuesto,
      'productos': productos.map((p) => p.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastModifiedBy': modificadoPor ?? 'Desconocido',
    });

    await familyRef.collection('data').doc('historial').set({
      'compras': compras.map((c) => c.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>> cargar(String familyId) async {
    final familyRef = _db.collection('families').doc(familyId);
    final pantryDoc = await familyRef.collection('data').doc('pantry').get();
    final historialDoc = await familyRef
        .collection('data')
        .doc('historial')
        .get();
    return _parsear(pantryDoc.data(), historialDoc.data());
  }

  static Stream<Map<String, dynamic>> stream(String familyId) {
    final familyRef = _db.collection('families').doc(familyId);
    return familyRef.collection('data').doc('pantry').snapshots().asyncMap((
      pantrySnap,
    ) async {
      final historialSnap = await familyRef
          .collection('data')
          .doc('historial')
          .get();
      return _parsear(pantrySnap.data(), historialSnap.data());
    });
  }

  static Map<String, dynamic> _parsear(
    Map<String, dynamic>? pantry,
    Map<String, dynamic>? historial,
  ) {
    double presupuesto = 150000;
    List<Producto> productos = [];
    List<Compra> compras = [];
    String lastModifiedBy = '';

    if (pantry != null) {
      presupuesto = (pantry['presupuesto'] as num?)?.toDouble() ?? 150000;
      final lista = pantry['productos'] as List<dynamic>? ?? [];
      productos = lista
          .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      lastModifiedBy = pantry['lastModifiedBy'] ?? '';
    }

    if (historial != null) {
      final lista = historial['compras'] as List<dynamic>? ?? [];
      compras = lista
          .map((e) => Compra.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return {
      'presupuesto': presupuesto,
      'productos': productos,
      'compras': compras,
      'lastModifiedBy': lastModifiedBy,
    };
  }
}
