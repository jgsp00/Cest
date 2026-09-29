import 'package:flutter/material.dart';

// Mapa de nombre → IconData para los productos
const Map<String, IconData> kIconosProducto = {
  'box': Icons.inventory_2_outlined,
  'grain': Icons.grass_outlined,
  'bottle': Icons.water_drop_outlined,
  'milk': Icons.local_drink_outlined,
  'bread': Icons.breakfast_dining_outlined,
  'egg': Icons.egg_outlined,
  'soap': Icons.soap_outlined,
  'clean': Icons.cleaning_services_outlined,
  'bubble': Icons.bubble_chart_outlined,
  'meat': Icons.set_meal_outlined,
  'cheese': Icons.rectangle_outlined,
  'fruit': Icons.apple_outlined,
  'vegetable': Icons.eco_outlined,
  'salt': Icons.grain_outlined,
  'chocolate': Icons.cookie_outlined,
  'juice': Icons.local_bar_outlined,
  'carrot': Icons.spa_outlined,
  'garlic': Icons.filter_vintage_outlined,
  'oil': Icons.opacity_outlined,
  'nuts': Icons.scatter_plot_outlined,
  'fish': Icons.set_meal_outlined,
  'frozen': Icons.ac_unit_outlined,
  'spice': Icons.whatshot_outlined,
  'coffee': Icons.coffee_outlined,
  'tea': Icons.emoji_food_beverage_outlined,
  'medicine': Icons.medication_outlined,
  'pet': Icons.pets_outlined,
  'baby': Icons.child_care_outlined,
  'paper': Icons.receipt_long_outlined,
  'light': Icons.lightbulb_outlined,
  'Groups': Icons.groups_outlined,
  'Search': Icons.search_outlined,
};

// Nombre por defecto
const String kIconoDefault = 'box';

// Obtener IconData por nombre
IconData getIcono(String nombre) {
  return kIconosProducto[nombre] ?? Icons.inventory_2_outlined;
}
