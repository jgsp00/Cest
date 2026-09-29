import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto.dart';
import '../models/compra.dart';

class StorageService {
  static Future<void> guardar({
    required double presupuesto,
    required List<Producto> productos,
    required List<Compra> compras,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('presupuesto', presupuesto);
    await prefs.setString(
      'productos',
      jsonEncode(productos.map((p) => p.toJson()).toList()),
    );
    await prefs.setString(
      'compras',
      jsonEncode(compras.map((c) => c.toJson()).toList()),
    );
  }

  static Future<Map<String, dynamic>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final presupuesto = prefs.getDouble('presupuesto') ?? 150000;

    List<Producto> productos = [];
    final ps = prefs.getString('productos');
    if (ps != null) {
      productos = (jsonDecode(ps) as List)
          .map((e) => Producto.fromJson(e))
          .toList();
    }

    List<Compra> compras = [];
    final cs = prefs.getString('compras');
    if (cs != null) {
      compras = (jsonDecode(cs) as List)
          .map((e) => Compra.fromJson(e))
          .toList();
    }

    return {
      'presupuesto': presupuesto,
      'productos': productos,
      'compras': compras,
    };
  }
}
