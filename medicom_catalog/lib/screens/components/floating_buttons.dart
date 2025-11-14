import 'package:flutter/material.dart';

class CustomSpeedDial extends StatefulWidget {
  final List<SpeedDialButton> verticalButtons;
  final List<SpeedDialButton> horizontalButtons;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double buttonSpacing;

  const CustomSpeedDial({
    Key? key,
    required this.verticalButtons,
    required this.horizontalButtons,
    this.backgroundColor,
    this.foregroundColor,
    this.buttonSpacing = 72.0,
  }) : super(key: key);

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Overlay
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

        // Vertical buttons (above FAB)
        ..._buildVerticalButtons(colorScheme, isRTL),

        // Horizontal buttons (to the left/right of FAB)
        ..._buildHorizontalButtons(colorScheme, isRTL),

        // Main FAB
        _buildMainFab(colorScheme),
      ],
    );
  }

  List<Widget> _buildVerticalButtons(ColorScheme colorScheme, bool isRTL) {
    return List<Widget>.generate(
      widget.verticalButtons.length,
      (index) => _buildVerticalButton(
        widget.verticalButtons[index],
        index,
        colorScheme,
        isRTL,
      ),
    );
  }

  List<Widget> _buildHorizontalButtons(ColorScheme colorScheme, bool isRTL) {
    return List<Widget>.generate(
      widget.horizontalButtons.length,
      (index) => _buildHorizontalButton(
        widget.horizontalButtons[index],
        index,
        colorScheme,
        isRTL,
      ),
    );
  }

  Widget _buildVerticalButton(
    SpeedDialButton button,
    int index,
    ColorScheme colorScheme,
    bool isRTL,
  ) {
    final offset = (index + 1) * widget.buttonSpacing;

    return Positioned(
      right: 16,
      bottom: 80 + offset,
      child: ScaleTransition(
        scale: _animation,
        child: FadeTransition(
          opacity: _animation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isRTL && button.label != null) ...[
                _buildLabel(button.label!, colorScheme),
                const SizedBox(width: 12),
              ],
              FloatingActionButton(
                mini: true,
                backgroundColor: button.backgroundColor ?? colorScheme.primary,
                foregroundColor:
                    button.foregroundColor ?? colorScheme.onPrimary,
                heroTag: 'vertical_$index',
                onPressed: () {
                  button.onTap?.call();
                  _toggle();
                },
                child: button.icon,
              ),
              if (isRTL && button.label != null) ...[
                const SizedBox(width: 12),
                _buildLabel(button.label!, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalButton(
    SpeedDialButton button,
    int index,
    ColorScheme colorScheme,
    bool isRTL,
  ) {
    final offset = (index + 1) * widget.buttonSpacing;
    final horizontalOffset = 80 + offset;

    return Positioned(
      right: isRTL ? null : horizontalOffset,
      left: isRTL ? horizontalOffset : null,
      bottom: 16,
      child: ScaleTransition(
        scale: _animation,
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (button.label != null) ...[
                _buildLabel(button.label!, colorScheme),
                const SizedBox(height: 8),
              ],
              FloatingActionButton(
                mini: true,
                backgroundColor: button.backgroundColor ?? colorScheme.primary,
                foregroundColor:
                    button.foregroundColor ?? colorScheme.onPrimary,
                heroTag: 'horizontal_$index',
                onPressed: () {
                  button.onTap?.call();
                  _toggle();
                },
                child: button.icon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab(ColorScheme colorScheme) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        backgroundColor: widget.backgroundColor ?? colorScheme.primary,
        foregroundColor: widget.foregroundColor ?? colorScheme.onPrimary,
        onPressed: _toggle,
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animation,
        ),
      ),
    );
  }

  Widget _buildLabel(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SpeedDialButton {
  final Widget icon;
  final String? label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialButton({
    required this.icon,
    this.label,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });
}

// Example usage with improved implementation
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom SpeedDial'),
      ),
      body: const Center(
        child: Text('Your content here'),
      ),
      floatingActionButton: CustomSpeedDial(
        verticalButtons: [
          SpeedDialButton(
            icon: const Icon(Icons.shopping_basket),
            label: 'Orders',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orders tapped')),
              );
            },
          ),
          SpeedDialButton(
            icon: const Icon(Icons.shopping_cart),
            label: 'Cart',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart tapped')),
              );
            },
          ),
        ],
        horizontalButtons: [
          SpeedDialButton(
            icon: const Icon(Icons.add),
            label: 'Add Product',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Product tapped')),
              );
            },
          ),
          SpeedDialButton(
            icon: const Icon(Icons.qr_code_scanner),
            label: 'Scan',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scan tapped')),
              );
            },
          ),
        ],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        buttonSpacing: 70.0,
      ),
    );
  }
}
