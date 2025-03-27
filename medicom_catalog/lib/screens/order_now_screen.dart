import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';

class OrderNowScreen extends StatefulWidget {
  final Product product;

  const OrderNowScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _OrderNowScreenState createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  final TextEditingController _quantityController =
      TextEditingController(text: "1");
  final _formKey = GlobalKey<FormState>();
  double taxRate = 0.19;
  double discount = 0.0;
  bool _isSubmitting = false;

  int get quantity => int.tryParse(_quantityController.text) ?? 1;
  double get unitPrice => widget.product.product_price ?? 0.0;
  double get subtotal => unitPrice * quantity;
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount - discount;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int increment) {
    final newQuantity = (quantity + increment).clamp(1, 100);
    _quantityController.text = newQuantity.toString();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;
    final userNotifier = Provider.of<AppUserNotifier>(context, listen: false);

    try {
      final orderData = Cart.buildSingleOrderData(
        product: widget.product,
        quantity: quantity,
        orderingUserId: userNotifier.appUser!.id_app_user!,
        discount: discount,
        taxRate: taxRate,
      );

      // TODO: Replace with your actual order submission logic
      // final success = await OrderService.submitOrder(orderData);
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call
      const success = true;

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(localizations.putSuccess),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${localizations.putFailure}'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${localizations.serverError}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.orderNowTxt),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product header
              Text(
                widget.product.product_name ??
                    "localizations.missingProductName",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Quantity selector
              _buildQuantitySelector(localizations),
              const Divider(height: 32),

              // Price breakdown
              _buildPriceDetails(localizations),
              const Divider(height: 32),

              // Total price
              _buildTotalPrice(localizations, theme),
              const Spacer(),

              // Order button
              _buildOrderButton(localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.productQuantity,
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _updateQuantity(-1),
            ),
            SizedBox(
              width: 60,
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final qty = int.tryParse(value ?? '');
                  if (qty == null || qty < 1) {
                    return "localizations.invalidQuantity";
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _updateQuantity(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetails(AppLocalizations localizations) {
    return Column(
      children: [
        _buildPriceRow(
          label: localizations.subtotalTxt,
          value: subtotal,
        ),
        const SizedBox(height: 8),
        _buildPriceRow(
          label: localizations.taxTxt,
          value: taxAmount,
        ),
        if (discount > 0) ...[
          const SizedBox(height: 8),
          _buildPriceRow(
            label: localizations.discountText,
            value: -discount,
            isDiscount: true,
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double value,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '${isDiscount && value > 0 ? '-' : ''}${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPrice(AppLocalizations localizations, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.totalTxt,
          style: theme.textTheme.titleLarge,
        ),
        Text(
          total.toStringAsFixed(2),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                localizations.confirmOrderTxt,
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
