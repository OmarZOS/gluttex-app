// lib/screens/product_details/shared_widgets.dart

import 'package:flutter/material.dart';

/// The small rounded handle at the top of the sliding panel.
class PanelHandle extends StatelessWidget {
  const PanelHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
