import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'map_locations_screen.dart';

class SwipeFloatingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: Container(
        // Widget to display when panel is fully visible
        child: Center(
          child: Text('Panel Content'),
        ),
      ),
      collapsed: Container(
        // Widget to display when panel is collapsed
        child: Center(
          child: Text('Collapsed Panel'),
        ),
      ),
      minHeight: MediaQuery.of(context).size.height *
          0.2, // Minimum height of the panel
      maxHeight: MediaQuery.of(context).size.height *
          0.7, // Maximum height of the panel
      body: Container(
        // Main content of the screen
        child: Center(
          child: MapScreen(),
        ),
      ),
    );
  }
}
