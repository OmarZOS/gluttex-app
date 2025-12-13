import 'package:flutter/material.dart';

class CartFloatingMenu extends StatefulWidget {
  final VoidCallback onCheckout;
  final VoidCallback onSaveQuote;
  final VoidCallback onEmailReceipt;
  final VoidCallback onPrintReceipt;

  const CartFloatingMenu({
    super.key,
    required this.onCheckout,
    required this.onSaveQuote,
    required this.onEmailReceipt,
    required this.onPrintReceipt,
  });

  @override
  State<CartFloatingMenu> createState() => _CartFloatingMenuState();
}

class _CartFloatingMenuState extends State<CartFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _toggleMenu() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Expanded menu items
        if (_isExpanded) ...[
          _buildMenuItem(
            icon: Icons.email,
            label: 'Email Receipt',
            onTap: widget.onEmailReceipt,
            index: 3,
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            icon: Icons.print,
            label: 'Print Receipt',
            onTap: widget.onPrintReceipt,
            index: 2,
            colorScheme: colorScheme,
          ),
          _buildMenuItem(
            icon: Icons.save_alt,
            label: 'Save Quote',
            onTap: widget.onSaveQuote,
            index: 1,
            colorScheme: colorScheme,
          ),
        ],

        // Main button
        FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 6,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int index,
    required ColorScheme colorScheme,
  }) {
    return Positioned(
      right: 16,
      bottom: 72 + (index * 64),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
