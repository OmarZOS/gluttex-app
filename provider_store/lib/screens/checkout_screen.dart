import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/views/checkout_view_model.dart';
import 'package:gluttex_core/health/blood_type.dart';
import 'package:provider_store/components/selling_point/checkout/checkout_footer.dart';
import 'package:provider_store/components/selling_point/checkout/delivery_section.dart';
import 'package:provider_store/components/selling_point/checkout/document_type_section.dart';
import 'package:provider_store/components/selling_point/checkout/notes_parameters_section.dart';
import 'package:provider_store/components/selling_point/checkout/order_items_section.dart';
import 'package:provider_store/components/selling_point/checkout/payment_section.dart';
import 'package:ui/components/document/Delivery_Type_UI_Manager.dart';
import 'package:ui/components/document/DocumentTypeManager.dart';
import 'package:ui/components/finance/Payment_Type_UI_Manager.dart';
import 'package:ui/components/search/customer_search_section.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  final int supplierId;

  const CheckoutScreen({
    super.key,
    required this.supplierId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late CheckoutViewModel _viewModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Track collapsed/expanded state for each section
  bool _customerExpanded = true;
  bool _itemsExpanded = true;
  bool _documentExpanded = false;
  bool _paymentExpanded = false;
  bool _deliveryExpanded = false;
  bool _notesExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Future<void> _processCheckout(BuildContext context) async {
  //   // Validate form
  //   if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   final cartNotifier = context.read<CartChangeNotifier>();
  //   final userNotifier = context.read<AppUserNotifier>();
  //   final productNotifier = context.read<ProductNotifier>();

  //   // Validate cart
  //   if (cartNotifier.cart.isEmpty) {
  //     _showErrorDialog(context, AppLocalizations.of(context)!.cartEmptyError);
  //     return;
  //   }

  //   // Validate customer if required (optional)
  //   final requiresCustomer = true; // Set this based on your business logic
  //   if (requiresCustomer &&
  //       _viewModel.selectedCustomer == null &&
  //       _viewModel.selectedPerson == null) {
  //     _showErrorDialog(
  //         context, AppLocalizations.of(context)!.customerRequiredError);
  //     return;
  //   }
  //   // Show confirmation dialog
  //   final confirmed = await _showConfirmationDialog(context);
  //   if (!confirmed) return;

  //   try {
  //     // Get current user info
  //     final currentUser = userNotifier.appUser;
  //     if (currentUser == null) {
  //       _showErrorDialog(
  //           context, AppLocalizations.of(context)!.loginRequiredError);
  //       return;
  //     }

  //     // Process checkout
  //     final result = await _viewModel.processCartCheckout(
  //       cart: cartNotifier.cart,
  //       sellingUserId: currentUser.idAppUser ?? 0,
  //       providerId: widget.supplierId,
  //     );

  //     if (result.isSuccess) {
  //       // Success - show success screen
  //       await _showSuccessScreen(context, result, cartNotifier.cart.subtotal);

  //       productNotifier.fetchProducts(
  //           providerId: productNotifier.currentProviderId);

  //       // Clear the cart
  //       cartNotifier.clearCart();

  //       // Reset checkout view model
  //       _viewModel.resetAfterCheckout();

  //       // Optional: Navigate back or to orders
  //       Navigator.pop(context);
  //     } else {
  //       // Failure - show error
  //       _showErrorDialog(context, result.message);
  //     }
  //   } catch (e) {
  //     _showErrorDialog(
  //         context, '${AppLocalizations.of(context)!.checkoutError}: $e');
  //   }
  // }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final cartNotifier = context.read<CartChangeNotifier>();
    final loc = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.confirmCheckout),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.checkoutSummary,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Customer
              if (_viewModel.selectedCustomer != null ||
                  _viewModel.selectedPerson != null)
                _buildSummaryRow(
                  context,
                  Icons.person,
                  loc.customer,
                  _getCustomerName(_viewModel),
                ),

              // Items
              _buildSummaryRow(
                context,
                Icons.shopping_cart,
                loc.itemsText,
                loc.itemsCount(cartNotifier.cartItemCount),
              ),

              // Total
              _buildSummaryRow(
                context,
                Icons.attach_money,
                loc.total,
                loc.price(cartNotifier.cartTotal.toStringAsFixed(2)),
                isTotal: true,
              ),

              const SizedBox(height: 8),
              Divider(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.3)),

              // Document Type
              _buildSummaryRow(
                context,
                Icons.description,
                loc.documentType,
                _getDocumentTypeName(_viewModel.documentType, loc),
              ),

              // Payment
              _buildSummaryRow(
                context,
                Icons.payment,
                loc.paymentMethod,
                _getPaymentMethodName(_viewModel.paymentMethod, loc),
              ),

              // Delivery
              _buildSummaryRow(
                context,
                Icons.local_shipping,
                loc.delivery,
                _getDeliveryTypeName(_viewModel.deliveryType, loc),
              ),

              if (_viewModel.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                _buildSummaryRow(
                  context,
                  Icons.notes,
                  loc.notes,
                  _viewModel.notes,
                  isMultiline: true,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(loc.confirmAndPay),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    bool isTotal = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon,
              size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title:',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: isTotal ? 16 : 14,
              ),
              maxLines: isMultiline ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessScreen(
    BuildContext context,
    CheckoutResult result,
    double totalAmount,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final productNotifier = context.read<ProductNotifier>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(loc.orderSuccessful),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.orderPlacedSuccessfully,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (result.orderId != null)
              Text(
                '${loc.orderId}: #${result.orderId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '${loc.total}: ${loc.currencySymbol}${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getCustomerName(_viewModel),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            // Add a loading indicator for product refresh
            const SizedBox(height: 16),
            FutureBuilder(
              future: _refreshProductsAfterOrder(context, result),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        loc.loading,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close checkout screen
              Navigator.pop(context);
            },
            child: Text(loc.continueShopping),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              // Navigate to orders screen or pop
              Navigator.pop(context);
            },
            child: Text(loc.viewOrders),
          ),
        ],
      ),
    );
  }

// Add this helper method to refresh products after order
  Future<void> _refreshProductsAfterOrder(
    BuildContext context,
    CheckoutResult result,
  ) async {
    final productNotifier = context.read<ProductNotifier>();
    final cartNotifier = context.read<CartChangeNotifier>();

    // Get list of product IDs from cart for targeted refresh
    final orderedProductIds = cartNotifier.cart.items
        .map((item) => item.product?.id_product)
        .where((id) => id != null && id > 0)
        .cast<int>()
        .toList();

    // Refresh products - use specialized method if available
    await productNotifier.fetchProducts(
      providerId: productNotifier.currentProviderId,
      reset: true, // Force reset to get fresh data
    );
  }

// Update your _processCheckout method to ensure proper refresh
  Future<void> _processCheckout(BuildContext context) async {
    // Validate form
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    final cartNotifier = context.read<CartChangeNotifier>();
    final userNotifier = context.read<AppUserNotifier>();
    final productNotifier = context.read<ProductNotifier>();

    // Validate cart
    if (cartNotifier.cart.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.cartEmptyError);
      return;
    }

    // Validate customer if required
    final requiresCustomer = true;
    if (requiresCustomer &&
        _viewModel.selectedCustomer == null &&
        _viewModel.selectedPerson == null) {
      _showErrorDialog(
          context, AppLocalizations.of(context)!.customerRequiredError);
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(context);
    if (!confirmed) return;

    try {
      // Get current user info
      final currentUser = userNotifier.appUser;
      if (currentUser == null) {
        _showErrorDialog(
            context, AppLocalizations.of(context)!.loginRequiredError);
        return;
      }

      // Process checkout
      final result = await _viewModel.processCartCheckout(
        cart: cartNotifier.cart,
        sellingUserId: currentUser.idAppUser ?? 0,
        providerId: widget.supplierId,
      );

      if (result.isSuccess) {
        // Success - show success screen
        await _showSuccessScreen(context, result, cartNotifier.cart.subtotal);

        // Clear the cart
        cartNotifier.clearCart();

        // Reset checkout view model
        _viewModel.resetAfterCheckout();

        // Optional: Navigate back
        // Navigator.pop(context);
      } else {
        // Failure - show error
        _showErrorDialog(context, result.message);
      }
    } catch (e) {
      _showErrorDialog(
          context, '${AppLocalizations.of(context)!.checkoutError}: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.checkoutError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  String _getCustomerName(CheckoutViewModel viewModel) {
    if (viewModel.selectedCustomer != null) {
      final customer = viewModel.selectedCustomer!;
      return '${customer.personFirstName} ${customer.personLastName}'.trim();
    } else if (viewModel.selectedPerson != null) {
      return viewModel.selectedPerson!.fullName;
    }
    return AppLocalizations.of(context)!.guest;
  }

  String _getDocumentTypeName(String type, AppLocalizations loc) {
    switch (type) {
      case 'invoice':
        return loc.invoice;
      case 'receipt':
        return loc.receipt;
      case 'invoice_receipt':
        return loc.invoiceReceipt;
      case 'none':
        return loc.none;
      default:
        return loc.invoiceReceipt;
    }
  }

  String _getPaymentMethodName(String method, AppLocalizations loc) {
    switch (method) {
      case 'cash':
        return loc.cash;
      case 'card':
        return loc.card;
      case 'bank':
        return loc.bankTransfer;
      case 'mobile':
        return loc.mobileMoney;
      default:
        return method;
    }
  }

  String _getDeliveryTypeName(String type, AppLocalizations loc) {
    switch (type) {
      case 'pickup':
        return loc.pickup;
      case 'delivery':
        return loc.delivery;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.checkout),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelpDialog(context, loc),
              tooltip: loc.help,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SafeArea(
            child: Stack(
              children: [
                // Main content
                _buildContent(context),

                // Loading overlay
                Selector<CheckoutViewModel, bool>(
                  selector: (_, vm) => vm.isProcessing,
                  builder: (context, isProcessing, child) {
                    if (!isProcessing) return const SizedBox.shrink();
                    return Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cartNotifier = context.read<CartChangeNotifier>();
    final hasItems = cartNotifier.cart.isNotEmpty;
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Customer Section (Collapsible)
          Consumer<CheckoutViewModel>(
            builder: (context, viewModel, child) {
              return _buildCollapsibleSection(
                title: loc.customer,
                icon: Icons.person,
                badge: (viewModel.selectedPerson != null ||
                        viewModel.selectedCustomer != null)
                    ? viewModel.getCustomerName()
                    : null,
                isExpanded: _customerExpanded,
                onToggle: () =>
                    setState(() => _customerExpanded = !_customerExpanded),
                child: CustomerSection(
                  defaultCustomer: AppUser(
                    idAppUser: 0, // ID 0 indicates guest/anonymous
                    appUserPersonId: 0,
                    appUserType: AppUserType
                        .guest, // Guest type ID (you may have a specific ID for guests)
                    appUserName: 'guest',
                    appUserPassword: '',
                    appUserPreferences: '',
                    // app_user_type_desc: loc.guestCustomer ?? 'Guest',
                    appUserImageUrl: '',
                    idPerson: 0,
                    personDetailsId: 0,
                    personFirstName: loc.guestCustomer ?? 'Guest',
                    personLastName: '',
                    personBirthDate: '',
                    appUserEmail: loc.guestEmail ?? 'guest@example.com',
                    personGender: '',
                    personCountryCode: '',
                    bloodType: "B+",
                    idLocation: 0,
                    locationLatitude: 0.0,
                    locationLongitude: 0.0,
                    locationName: loc.guestLocation ?? 'Store',
                    locationAddressId: 0,
                    addressStreet: '',
                    addressCity: '',
                    addressPostalCode: '',
                    addressCountry: '',
                    privileges: [],
                  ),
                  selectedCustomer: viewModel.selectedCustomer,
                  selectedPerson: viewModel.selectedPerson,
                  onCustomerChanged: (customer) {
                    viewModel.setSelectedCustomer(customer, null);
                  },
                  onPersonChanged: (person) {
                    viewModel.setSelectedCustomer(null, person);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Order Items (Collapsible)
          _buildCollapsibleSection(
            title: loc.itemsText,
            icon: Icons.shopping_cart,
            isExpanded: _itemsExpanded,
            onToggle: () => setState(() => _itemsExpanded = !_itemsExpanded),
            badge: hasItems
                ? loc.items(
                    cartNotifier.cartItemCount,
                    cartNotifier.productItemCount,
                    cartNotifier.serviceItemCount)
                : null,
            child: const OrderItemsSection(),
          ),

          const SizedBox(height: 8),

          // Document Type (Collapsible)

          Consumer<CheckoutViewModel>(
            builder: (context, viewModel, child) {
              return _buildCollapsibleSection(
                title: loc.documentType,
                icon: Icons.description,
                isExpanded: _documentExpanded,
                badge: DocumentTypeManager.getDocumentTypeOptions(context)
                    .where((t) => t.id == viewModel.documentType)
                    .first
                    .label,
                onToggle: () =>
                    setState(() => _documentExpanded = !_documentExpanded),
                child: DocumentTypeSection(
                  selectedType: viewModel.documentType,
                  onChanged: viewModel.setDocumentType,
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Payment Sections (Collapsible)
          Consumer<CheckoutViewModel>(
            builder: (context, viewModel, child) {
              return _buildCollapsibleSection(
                title: loc.payment,
                icon: Icons.payment,
                isExpanded: _paymentExpanded,
                badge: PaymentTypeUIManager.getPaymentTypeById(
                        viewModel.paymentType, loc)!
                    .label,
                onToggle: () =>
                    setState(() => _paymentExpanded = !_paymentExpanded),
                child: PaymentSection(
                  paymentType: viewModel.paymentType,
                  paymentMethod: viewModel.paymentMethod,
                  onPaymentTypeChanged: viewModel.setPaymentType,
                  onPaymentMethodChanged: viewModel.setPaymentMethod,
                  onInstallmentDateChanged: viewModel.setInstallmentDate,
                  onDepositChanged: viewModel.setDepositAmount,
                  onCardDetailsChanged: viewModel.setCardDetails,
                  onBankDetailsChanged: viewModel.setBankDetails,
                  onMobileProviderChanged: viewModel.setMobileProvider,
                  onCardTypeChanged: viewModel.setCardType,
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Delivery Section (Collapsible)
          Consumer<CheckoutViewModel>(
            builder: (context, viewModel, child) {
              return _buildCollapsibleSection(
                  title: loc.delivery,
                  icon: Icons.local_shipping,
                  isExpanded: _deliveryExpanded,
                  badge: DeliveryUIManager.getDeliveryTypeById(
                          viewModel.deliveryType, loc)!
                      .label,
                  onToggle: () =>
                      setState(() => _deliveryExpanded = !_deliveryExpanded),
                  child: DeliverySection(
                    selectedType: viewModel.deliveryType,
                    onChanged: viewModel.setDeliveryType,
                    onDeliveryDataChanged: viewModel.setDeliveryData,
                    customer: viewModel.selectedPerson,
                  ));
            },
          ),

          const SizedBox(height: 8),

          // Notes & Parameters (Collapsible)
          _buildCollapsibleSection(
            title: loc.notesParameters,
            icon: Icons.note_add,
            isExpanded: _notesExpanded,
            onToggle: () => setState(() => _notesExpanded = !_notesExpanded),
            badge: _viewModel.parameters.isNotEmpty
                ? _viewModel.parameters.length.toString()
                : null,
            child: Consumer<CheckoutViewModel>(
              builder: (context, viewModel, child) {
                return NotesParametersSection(
                  notes: viewModel.notes,
                  parameters: viewModel.parameters,
                  savedParameters: viewModel.savedParameters,
                  isLoadingParameters: viewModel.isLoadingParameters,
                  onNotesChanged: viewModel.setNotes,
                  onParametersChanged: viewModel.setParameters,
                  onSaveParameter: viewModel.saveParameter,
                  onUpdateParameter: viewModel.updateParameter,
                  onDeleteParameter: viewModel.deleteParameter,
                  onUseSavedParameter: viewModel.useSavedParameter,
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Checkout Footer
          Consumer<CheckoutViewModel>(
            builder: (context, viewModel, child) {
              return CheckoutFooter(
                onCheckoutPressed: () => _processCheckout(context),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    String? badge,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            // Header
            ListTile(
              leading: Icon(
                icon,
                color: isExpanded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isExpanded
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onTap: onToggle,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),

            // Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: child,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.checkoutHelp),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                icon: Icons.person,
                title: loc.customer,
                description: loc.customerHelpDescription,
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: Icons.shopping_cart,
                title: loc.itemsText,
                description: loc.itemsHelpDescription,
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: Icons.description,
                title: loc.documentType,
                description: loc.documentTypeHelpDescription,
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: Icons.payment,
                title: loc.paymentMethod,
                description: loc.paymentMethodHelpDescription,
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: Icons.local_shipping,
                title: loc.delivery,
                description: loc.deliveryHelpDescription,
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: Icons.note_add,
                title: loc.notesParameters,
                description: loc.notesParametersHelpDescription,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.gotIt),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
