import 'package:flutter/material.dart';

class CustomSpeedDial extends StatefulWidget {
  final List<SpeedDialButton> verticalButtons;
  final List<SpeedDialButton> horizontalButtons;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double buttonSpacing;
  final double buttonSize;
  final bool showLabels;

  const CustomSpeedDial({
    Key? key,
    required this.verticalButtons,
    required this.horizontalButtons,
    this.backgroundColor,
    this.foregroundColor,
    this.buttonSpacing = 72.0,
    this.buttonSize = 56.0,
    this.showLabels = true,
  }) : super(key: key);

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
        // Semi-transparent overlay
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),

        // Vertical buttons (above main FAB)
        ..._buildVerticalButtons(colorScheme, isRTL),

        // Horizontal buttons (to the left/right of main FAB)
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
      right: 20,
      bottom: 80 + offset,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isRTL && button.label != null && widget.showLabels) ...[
                _buildLabel(button.label!, colorScheme),
                const SizedBox(width: 16),
              ],
              _buildActionButton(
                button: button,
                colorScheme: colorScheme,
                heroTag: 'vertical_$index',
              ),
              if (isRTL && button.label != null && widget.showLabels) ...[
                const SizedBox(width: 16),
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
      bottom: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (button.label != null && widget.showLabels) ...[
                _buildLabel(button.label!, colorScheme),
                const SizedBox(height: 12),
              ],
              _buildActionButton(
                button: button,
                colorScheme: colorScheme,
                heroTag: 'horizontal_$index',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required SpeedDialButton button,
    required ColorScheme colorScheme,
    required String heroTag,
  }) {
    return Container(
      width: widget.buttonSize,
      height: widget.buttonSize,
      decoration: BoxDecoration(
        color: button.backgroundColor ?? colorScheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.buttonSize / 2),
          onTap: () {
            button.onTap?.call();
            _toggle();
          },
          child: IconTheme(
            data: IconThemeData(
              color: button.foregroundColor ?? colorScheme.onPrimaryContainer,
              size: 24,
            ),
            child: button.icon,
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab(ColorScheme colorScheme) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Container(
        width: widget.buttonSize,
        height: widget.buttonSize,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.buttonSize / 2),
            onTap: _toggle,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: IconTheme(
                data: IconThemeData(
                  color: widget.foregroundColor ?? colorScheme.onPrimary,
                  size: 24,
                ),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
