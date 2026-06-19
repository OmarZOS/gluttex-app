import 'package:flutter/material.dart';

Icon getProviderTypeIcon(int categoryId) {
  switch (categoryId) {
    case 1:
      return const Icon(Icons.restaurant_menu_rounded);
    case 2:
      return const Icon(Icons.factory_outlined);
    case 3:
      return const Icon(Icons.delivery_dining_sharp);
    case 4:
      return const Icon(Icons.shopping_basket_rounded);
    default:
      return const Icon(Icons.question_mark_rounded);
  }
}
