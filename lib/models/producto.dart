class Producto {
  String nombre, categoria, emoji;
  int cantidad, capacidad;
  double precio;

  Producto({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.categoria,
    this.emoji = '📦',
    this.capacidad = 10,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'cantidad': cantidad,
    'capacidad': capacidad,
    'precio': precio,
    'categoria': categoria,
    'emoji': emoji,
  };

  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
    nombre: j['nombre'],
    cantidad: j['cantidad'],
    capacidad: j['capacidad'] ?? 10,
    precio: (j['precio'] as num).toDouble(),
    categoria: j['categoria'],
    emoji: j['emoji'] ?? '📦',
  );
}
