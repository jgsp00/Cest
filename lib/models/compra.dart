class Compra {
  String nombre, emoji, categoria;
  double monto;
  int cantidad;
  DateTime fecha;

  Compra({
    required this.nombre,
    required this.emoji,
    required this.monto,
    required this.cantidad,
    required this.fecha,
    required this.categoria,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'emoji': emoji,
    'monto': monto,
    'cantidad': cantidad,
    'fecha': fecha.toIso8601String(),
    'categoria': categoria,
  };

  factory Compra.fromJson(Map<String, dynamic> j) => Compra(
    nombre: j['nombre'],
    emoji: j['emoji'] ?? '📦',
    monto: (j['monto'] as num).toDouble(),
    cantidad: j['cantidad'],
    fecha: DateTime.parse(j['fecha']),
    categoria: j['categoria'] ?? '',
  );
}
