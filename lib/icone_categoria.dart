import 'package:flutter/material.dart';

IconData iconeCategoria(String categoria) {
  switch (categoria.trim()) {
    case 'Eletrônicos':
      return Icons.devices_rounded;
    case 'Periféricos':
      return Icons.keyboard_rounded;
    case 'Informática':
      return Icons.computer_rounded;
    case 'Celulares':
      return Icons.smartphone_rounded;
    case 'Áudio':
      return Icons.headphones_rounded;
    case 'Games':
      return Icons.sports_esports_rounded;
    case 'Casa e Decoração':
      return Icons.home_rounded;
    case 'Escritório':
      return Icons.business_center_rounded;
    case 'Moda':
      return Icons.checkroom_rounded;
    case 'Beleza':
      return Icons.face_retouching_natural_rounded;
    case 'Esportes':
      return Icons.sports_soccer_rounded;
    case 'Alimentos':
      return Icons.restaurant_rounded;
    case 'Bebidas':
      return Icons.local_drink_rounded;
    case 'Automotivo':
      return Icons.directions_car_rounded;
    case 'Ferramentas':
      return Icons.handyman_rounded;
    case 'Pet Shop':
      return Icons.pets_rounded;
    case 'Infantil':
      return Icons.child_care_rounded;
    case 'Livros':
      return Icons.menu_book_rounded;
    case 'Saúde':
      return Icons.health_and_safety_rounded;
    default:
      return Icons.inventory_2_rounded;
  }
}
