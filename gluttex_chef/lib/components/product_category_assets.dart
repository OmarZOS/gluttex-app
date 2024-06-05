import 'package:flutter/material.dart';

Icon getRecipecategoryIcon(int categoryId) {
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

Colors getRecipecategoryColor(int categoryId) {
  throw UnimplementedError();
  // switch (categoryId) {
  //   case 1:
  //     return Colors.red[50];
  //   case 2:
  //     return Colors.red[50];
  //   case 3:
  //     return Colors.red[50];
  //   case 4:
  //     return Colors.red[50];
  //   default:
  //     return Colors.red[50];
  // }
}
