import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSpeedDial extends StatefulWidget {
  final List<SpeedDialButton> verticalButtons;
  final List<SpeedDialButton> horizontalButtons;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double buttonSpacing;
  final double buttonSize;
  final bool showLabels;
  final IconData? mainIcon;
  final String? mainButtonTooltip;
  final String uniqueId;

  const CustomSpeedDial({
    Key? key,
    required this.verticalButtons,
    required this.horizontalButtons,
    this.backgroundColor,
    this.foregroundColor,
    this.buttonSpacing = 72.0,
    this.buttonSize = 56.0,
    this.showLabels = true,
    this.mainIcon,
    this.mainButtonTooltip,
    this.uniqueId = 'default',
  })  : assert(buttonSize >= 40.0, 'buttonSize must be at least 40.0'),
        super(key: key);

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250), // Reduced from 400ms
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(CustomSpeedDial oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.verticalButtons.length != oldWidget.verticalButtons.length ||
        widget.horizontalButtons.length != oldWidget.horizontalButtons.length) {
      _animationController.value = 0;
      if (_isOpen) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!mounted) return;

    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onButtonTap(SpeedDialButton button) {
    if (!mounted) return;

    if (_isOpen) {
      _toggle();
    }

    // Reduced delay to match faster animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (button.onTap != null && mounted) {
        button.onTap!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Semi-transparent overlay with blur effect - Fixed positioning
        if (_isOpen)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggle,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150), // Faster
                opacity: _isOpen ? 1.0 : 0.0,
                child: Container(
                  color: Colors.transparent,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 1.5, sigmaY: 1.5), // Reduced blur
                    child: SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),

        // Main FAB - Fixed positioning
        Positioned(
          right: isRTL ? null : 16, // Right for LTR, null for RTL
          left: isRTL ? 16 : null, // Left for RTL, null for LTR
          bottom: 16 + safeAreaBottom,
          child: _buildMainFab(colorScheme),
        ),

        // Vertical buttons (above main FAB) - Fixed positioning
        for (var i = 0; i < widget.verticalButtons.length; i++)
          _buildVerticalButton(
            widget.verticalButtons[i],
            i,
            colorScheme,
            textTheme,
            isRTL,
            safeAreaBottom,
            screenHeight,
          ),

        // Horizontal buttons (to the left/right of main FAB) - Fixed positioning
        for (var i = 0; i < widget.horizontalButtons.length; i++)
          _buildHorizontalButton(
            widget.horizontalButtons[i],
            i,
            colorScheme,
            textTheme,
            isRTL,
            safeAreaBottom,
          ),
      ],
    );
  }

  Widget _buildVerticalButton(
    SpeedDialButton button,
    int index,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isRTL,
    double safeAreaBottom,
    double screenHeight,
  ) {
    final offset = (index + 1) * widget.buttonSpacing;
    final staggerDelay = index * 0.05;

    return Positioned(
      right: isRTL ? null : 16, // Use right for LTR, null for RTL
      left: isRTL ? 16 : null, // Use left for RTL, null for LTR
      bottom: 16 + safeAreaBottom + widget.buttonSize + 12 + offset,
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final animationValue = _animationController.value;
            final delayedValue =
                (animationValue - staggerDelay).clamp(0.0, 1.0);

            return Opacity(
              opacity: delayedValue,
              child: Transform.translate(
                offset: Offset(0, (1 - delayedValue) * 16),
                child: Transform.scale(
                  scale: delayedValue,
                  child: child,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (button.label != null && widget.showLabels) ...[
                _buildLabel(button.label!, colorScheme, textTheme, isRTL),
                const SizedBox(width: 8),
              ],
              _buildActionButton(
                button: button,
                colorScheme: colorScheme,
                uniqueKey: '${widget.uniqueId}_vertical_$index',
                index: index,
              ),
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
    TextTheme textTheme,
    bool isRTL,
    double safeAreaBottom,
  ) {
    final offset = (index + 1) * widget.buttonSpacing;
    final staggerDelay = index * 0.05; // Reduced from 0.08

    return Positioned(
      right: isRTL
          ? null
          : 16 + widget.buttonSize + 12 + offset, // Consistent spacing
      left: isRTL ? 16 + widget.buttonSize + 12 + offset : null,
      bottom: 16 + safeAreaBottom,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final animationValue = _animationController.value;
          final delayedValue = (animationValue - staggerDelay).clamp(0.0, 1.0);

          return Opacity(
            opacity: delayedValue,
            child: Transform.translate(
              offset: Offset((1 - delayedValue) * (isRTL ? -16 : 16),
                  0), // Reduced from 20
              child: Transform.scale(
                scale: delayedValue,
                child: child,
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (button.label != null && widget.showLabels) ...[
              _buildLabel(button.label!, colorScheme, textTheme, isRTL),
              const SizedBox(height: 8), // Reduced from 12
            ],
            _buildActionButton(
              button: button,
              colorScheme: colorScheme,
              uniqueKey: '${widget.uniqueId}_horizontal_$index',
              index: index,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required SpeedDialButton button,
    required ColorScheme colorScheme,
    required String uniqueKey,
    required int index,
  }) {
    return Material(
      key: ValueKey(uniqueKey),
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Tooltip(
        message: button.label ?? '',
        waitDuration: const Duration(milliseconds: 300), // Reduced from 500
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.buttonSize / 2),
          onTap: () => _onButtonTap(button),
          splashColor:
              (button.foregroundColor ?? colorScheme.onPrimaryContainer)
                  .withOpacity(0.3),
          highlightColor:
              (button.foregroundColor ?? colorScheme.onPrimaryContainer)
                  .withOpacity(0.1),
          child: Container(
            width: widget.buttonSize,
            height: widget.buttonSize,
            decoration: BoxDecoration(
              gradient: button.gradient ??
                  LinearGradient(
                    colors: [
                      button.backgroundColor ?? colorScheme.primaryContainer,
                      (button.backgroundColor ?? colorScheme.primaryContainer)
                          .withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // Reduced opacity
                  blurRadius: 8, // Reduced from 12
                  offset: const Offset(0, 3), // Fixed offset - was too large
                  spreadRadius: -1, // Reduced from -2
                ),
                BoxShadow(
                  color:
                      (button.backgroundColor ?? colorScheme.primaryContainer)
                          .withOpacity(0.2), // Reduced opacity
                  blurRadius: 6, // Reduced from 8
                  offset: const Offset(0, 1.5), // Fixed offset - was too large
                ),
              ],
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color:
                      button.foregroundColor ?? colorScheme.onPrimaryContainer,
                  size: 22, // Reduced from 24 for better balance
                ),
                child: button.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab(ColorScheme colorScheme) {
    return Material(
      key: const ValueKey('main_speed_dial_fab'),
      color: Colors.transparent,
      shape: const CircleBorder(),
      elevation: 0,
      child: Tooltip(
        message: widget.mainButtonTooltip ?? 'More options',
        waitDuration: const Duration(milliseconds: 300), // Reduced from 500
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.buttonSize / 2),
          onTap: _toggle,
          onLongPress: () {
            HapticFeedback.mediumImpact();
          },
          splashColor: (widget.foregroundColor ?? colorScheme.onPrimary)
              .withOpacity(0.3),
          highlightColor: (widget.foregroundColor ?? colorScheme.onPrimary)
              .withOpacity(0.1),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: widget.buttonSize,
                height: widget.buttonSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.backgroundColor ?? colorScheme.primary,
                      (widget.backgroundColor ?? colorScheme.primary)
                          .withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Reduced opacity
                      blurRadius: _isOpen ? 16 : 12, // Reduced
                      offset: Offset(
                          0, _isOpen ? 6 : 4), // Fixed offset - was too large
                      spreadRadius: -2, // Reduced from -4
                    ),
                    BoxShadow(
                      color: (widget.backgroundColor ?? colorScheme.primary)
                          .withOpacity(0.3), // Reduced opacity
                      blurRadius: _isOpen ? 12 : 8, // Reduced
                      offset: Offset(0, _isOpen ? 3 : 2), // Fixed offset
                    ),
                  ],
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: IconTheme(
                      data: IconThemeData(
                        color: widget.foregroundColor ?? colorScheme.onPrimary,
                        size: 24, // Reduced from 28 for better balance
                      ),
                      child: Icon(
                        widget.mainIcon ?? Icons.add_rounded,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String label,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isRTL,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180), // Reduced from 200
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10), // Reduced from 12
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Reduced opacity
              blurRadius: 6, // Reduced from 10
              offset: const Offset(0, 2), // Fixed offset - was too large
              spreadRadius: -1, // Reduced from -2
            ),
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08), // Reduced opacity
              blurRadius: 4, // Reduced from 6
              offset: const Offset(0, 1), // Fixed offset
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15), // Reduced opacity
            width: 0.5, // Reduced from 1
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500, // Reduced from 600
            fontSize: 12, // Reduced from 13
            letterSpacing: -0.05, // Reduced from -0.1
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
  final Gradient? gradient;

  const SpeedDialButton({
    required this.icon,
    this.label,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
  });

  SpeedDialButton copyWith({
    Widget? icon,
    String? label,
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
  }) {
    return SpeedDialButton(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      onTap: onTap ?? this.onTap,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeedDialButton &&
        other.label == label &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.gradient == gradient;
  }

  @override
  int get hashCode {
    return Object.hash(
      label,
      backgroundColor,
      foregroundColor,
      gradient,
    );
  }
}
