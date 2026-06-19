import 'package:flutter/material.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:store/components/selling_point/cart_summary/cart_summary_screen.dart';
import 'package:provider/provider.dart';

class CartFloatingMenu extends StatefulWidget {
  final VoidCallback onCheckout;
  final VoidCallback onSaveQuote;
  final VoidCallback onEmailReceipt;
  final VoidCallback onPrintReceipt;
  final VoidCallback onViewCart; // Add this callback

  const CartFloatingMenu({
    super.key,
    required this.onCheckout,
    required this.onSaveQuote,
    required this.onEmailReceipt,
    required this.onPrintReceipt,
    required this.onViewCart, // Add this
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

  // Method to show the cart summary sheet
  void _showCartSummary(BuildContext context) {
    // First close the floating menu
    if (_isExpanded) {
      _toggleMenu();
    }

    // Then show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the sheet take up most of the screen
      backgroundColor: Colors.transparent,
      builder: (context) {
        // You'll need to provide your CartChangeNotifier instance here
        // This might come from a provider, inherited widget, or passed as a parameter

        // For now, I'll show a placeholder. Replace this with your actual CartSummarySheet
        return CartSummarySheet(
          // You'll need to pass the cart instance here
          cart: context.read<
              CartChangeNotifier>(), // Replace with your actual cart instance
        );
      },
    );
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
            icon: Icons.shopping_cart,
            label: 'View Cart',
            onTap: () => _showCartSummary(context),
            index: 0,
            colorScheme: colorScheme,
          ),
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
        child: GestureDetector(
          onTap: onTap,
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
              ],
            ),
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
