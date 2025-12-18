import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _paymentMethod = 'cash';
  String _deliveryType = 'pickup';
  String _documentType = 'invoice_receipt';
  String _paymentType = 'payment';
  String? _cardNumber;
  String? _bankName;
  String? _mobileProvider;
  Person? _selectedCustomer;
  bool _isSearchingUsers = false;
  List<Person> _searchResults = [];

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults.clear();
        _isSearchingUsers = false;
      });
      return;
    }

    setState(() => _isSearchingUsers = true);

    try {
      // TODO: Implement actual user search from your service
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data - replace with actual API call
      final mockResults = [
        Person(
          id: 1,
          personDetailsId: 1,
          bloodTypeId: 1,
          details: PersonDetails(
            id: 1,
            firstName: 'John',
            lastName: 'Doe',
            birthDate: DateTime(1990, 5, 15),
            gender: 'Male',
            nationality: 'American',
            email: 'john@example.com',
            phone: '+1234567890',
            address: '123 Main St',
            city: 'New York',
            postalCode: '10001',
            country: 'USA',
          ),
        ),
        Person(
          id: 2,
          personDetailsId: 2,
          bloodTypeId: 2,
          details: PersonDetails(
            id: 2,
            firstName: 'Jane',
            lastName: 'Smith',
            birthDate: DateTime(1992, 8, 22),
            gender: 'Female',
            nationality: 'British',
            email: 'jane@example.com',
            phone: '+0987654321',
            address: '456 Oak Ave',
            city: 'London',
            postalCode: 'SW1A 1AA',
            country: 'UK',
          ),
        ),
        Person(
          id: 3,
          personDetailsId: 3,
          bloodTypeId: 3,
          details: PersonDetails(
            id: 3,
            firstName: 'Mohamed',
            lastName: 'Amir',
            birthDate: DateTime(1988, 3, 10),
            gender: 'Male',
            nationality: 'Algerian',
            email: 'mohamed.amir@example.com',
            phone: '+213555123456',
            address: '789 Algiers Street',
            city: 'Algiers',
            postalCode: '16000',
            country: 'Algeria',
          ),
        ),
        Person(
          id: 4,
          personDetailsId: 4,
          bloodTypeId: 1,
          details: PersonDetails(
            id: 4,
            firstName: 'Fatima',
            lastName: 'Zohra',
            birthDate: DateTime(1995, 11, 30),
            gender: 'Female',
            nationality: 'Algerian',
            email: 'fatima.zohra@example.com',
            phone: '+213555654321',
            address: '101 Oran Road',
            city: 'Oran',
            postalCode: '31000',
            country: 'Algeria',
          ),
        ),
        Person(
          id: 5,
          personDetailsId: 5,
          bloodTypeId: 2,
          details: PersonDetails(
            id: 5,
            firstName: 'Ahmed',
            lastName: 'Khan',
            birthDate: DateTime(1985, 7, 4),
            gender: 'Male',
            nationality: 'Pakistani',
            email: 'ahmed.khan@example.com',
            phone: '+923001234567',
            address: '222 Karachi Lane',
            city: 'Karachi',
            postalCode: '75500',
            country: 'Pakistan',
          ),
        ),
        Person(
          id: 6,
          personDetailsId: 6,
          bloodTypeId: 4,
          details: PersonDetails(
            id: 6,
            firstName: 'Sarah',
            lastName: 'Chen',
            birthDate: DateTime(1993, 2, 14),
            gender: 'Female',
            nationality: 'Chinese',
            email: 'sarah.chen@example.com',
            phone: '+8613812345678',
            address: '333 Beijing Avenue',
            city: 'Beijing',
            postalCode: '100000',
            country: 'China',
          ),
        ),
        Person(
          id: 7,
          personDetailsId: 7,
          bloodTypeId: 3,
          details: PersonDetails(
            id: 7,
            firstName: 'Pierre',
            lastName: 'Dubois',
            birthDate: DateTime(1978, 9, 18),
            gender: 'Male',
            nationality: 'French',
            email: 'pierre.dubois@example.com',
            phone: '+33123456789',
            address: '444 Rue de Paris',
            city: 'Paris',
            postalCode: '75001',
            country: 'France',
          ),
        ),
        Person(
          id: 8,
          personDetailsId: 8,
          bloodTypeId: 1,
          details: PersonDetails(
            id: 8,
            firstName: 'Maria',
            lastName: 'Garcia',
            birthDate: DateTime(1991, 12, 5),
            gender: 'Female',
            nationality: 'Spanish',
            email: 'maria.garcia@example.com',
            phone: '+34123456789',
            address: '555 Madrid Plaza',
            city: 'Madrid',
            postalCode: '28001',
            country: 'Spain',
          ),
        ),
        Person(
          id: 9,
          personDetailsId: 9,
          bloodTypeId: 2,
          details: PersonDetails(
            id: 9,
            firstName: 'Hassan',
            lastName: 'El-Masry',
            birthDate: DateTime(1982, 4, 25),
            gender: 'Male',
            nationality: 'Egyptian',
            email: 'hassan.elmasry@example.com',
            phone: '+201002345678',
            address: '666 Cairo Street',
            city: 'Cairo',
            postalCode: '11511',
            country: 'Egypt',
          ),
        ),
        Person(
          id: 10,
          personDetailsId: 10,
          bloodTypeId: 4,
          details: PersonDetails(
            id: 10,
            firstName: 'Aisha',
            lastName: 'Mohammed',
            birthDate: DateTime(1998, 6, 8),
            gender: 'Female',
            nationality: 'Nigerian',
            email: 'aisha.mohammed@example.com',
            phone: '+2348012345678',
            address: '777 Lagos Road',
            city: 'Lagos',
            postalCode: '100001',
            country: 'Nigeria',
          ),
        ),
        Person(
          id: 11,
          personDetailsId: 11,
          bloodTypeId: 1,
          details: PersonDetails(
            id: 11,
            firstName: 'Ravi',
            lastName: 'Kumar',
            birthDate: DateTime(1990, 10, 12),
            gender: 'Male',
            nationality: 'Indian',
            email: 'ravi.kumar@example.com',
            phone: '+911234567890',
            address: '888 Delhi Street',
            city: 'New Delhi',
            postalCode: '110001',
            country: 'India',
          ),
        ),
        Person(
          id: 12,
          personDetailsId: 12,
          bloodTypeId: 3,
          details: PersonDetails(
            id: 12,
            firstName: 'Sophia',
            lastName: 'Petrov',
            birthDate: DateTime(1987, 1, 20),
            gender: 'Female',
            nationality: 'Russian',
            email: 'sophia.petrov@example.com',
            phone: '+79161234567',
            address: '999 Moscow Avenue',
            city: 'Moscow',
            postalCode: '101000',
            country: 'Russia',
          ),
        ),
      ].where((person) {
        final query =
            "search query here"; // This would be the actual search query
        if (query.isEmpty) return true;

        final searchQuery = query.toLowerCase();
        final fullName = person.fullName.toLowerCase();

        return fullName.contains(searchQuery) ||
            person.details?.email?.toLowerCase().contains(searchQuery) ==
                true ||
            person.details?.phone?.contains(query) == true ||
            person.details?.city?.toLowerCase().contains(searchQuery) == true ||
            person.details?.country?.toLowerCase().contains(searchQuery) ==
                true;
      }).toList();

      setState(() => _searchResults = mockResults);
    } finally {
      setState(() => _isSearchingUsers = false);
    }
  }

  void _processCheckout(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate payment details based on method
    if (_paymentMethod == 'card' && (_cardNumber?.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter card details'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_paymentMethod == 'bank_transfer' && (_bankName?.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter bank details'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_paymentMethod == 'mobile_payment' &&
        (_mobileProvider?.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select mobile payment provider'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final cart = context.read<CartChangeNotifier>();
    final user = context.read<AppUserNotifier>().appUser;

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Simulate checkout process
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog(context, cart.cartSubtotal);

      // Clear cart after successful checkout
      cart.clearCart();
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        total: total,
        documentType: _documentType,
        onDone: () => Navigator.popUntil(context, (route) => route.isFirst),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.checkout),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // Customer search section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _CustomerSearchSection(
                    selectedCustomer: _selectedCustomer,
                    searchController: _searchController,
                    isSearching: _isSearchingUsers,
                    searchResults: _searchResults,
                    onSearchChanged: _searchUsers,
                    onCustomerSelected: (customer) {
                      setState(() => _selectedCustomer = customer);
                      _searchController.clear();
                      _searchResults.clear();
                    },
                    onClearCustomer: () {
                      setState(() => _selectedCustomer = null);
                    },
                  ),
                ),
              ),

              // Order items section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    loc.orderItems,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.symmetric(vertical: 4)),
              Consumer<CartChangeNotifier>(
                builder: (context, cart, child) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          index == cart.cartItems.length - 1 ? 16 : 4,
                        ),
                        child: _CheckoutItemCard(item: cart.cartItems[index]),
                      ),
                      childCount: cart.cartItems.length,
                    ),
                  );
                },
              ),

              // Document type section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    loc.documentType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.symmetric(vertical: 4)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DocumentTypeSelector(
                    selectedType: _documentType,
                    onChanged: (type) => setState(() => _documentType = type),
                  ),
                ),
              ),

              // Payment type section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    loc.paymentType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PaymentTypeSelector(
                    selectedType: _paymentType,
                    onChanged: (type) => setState(() => _paymentType = type),
                  ),
                ),
              ),

              // Payment method section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    loc.paymentMethod,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PaymentMethodSelector(
                    selectedMethod: _paymentMethod,
                    onChanged: (method) =>
                        setState(() => _paymentMethod = method),
                  ),
                ),
              ),

              // Payment details section
              SliverToBoxAdapter(
                child: _PaymentDetailsSection(
                  paymentMethod: _paymentMethod,
                  onCardDetailsChanged: (value) => _cardNumber = value,
                  onBankDetailsChanged: (value) => _bankName = value,
                  onMobileProviderChanged: (value) => _mobileProvider = value,
                ),
              ),

              // Delivery type section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    loc.deliveryType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DeliveryTypeSelector(
                    selectedType: _deliveryType,
                    onChanged: (type) => setState(() => _deliveryType = type),
                  ),
                ),
              ),

              // Order notes section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    loc.orderNotes,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: loc.notesHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              // Order summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<CartChangeNotifier>(
                    builder: (context, cart, child) => _OrderSummaryCard(
                      subtotal: cart.cartSubtotal,
                      tax: cart.cartSubtotal * 0.19,
                    ),
                  ),
                ),
              ),

              // Checkout button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: _CheckoutButton(
                    onPressed: () => _processCheckout(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerSearchSection extends StatefulWidget {
  final Person? selectedCustomer;
  final TextEditingController searchController;
  final bool isSearching;
  final List<Person> searchResults;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Person> onCustomerSelected;
  final VoidCallback onClearCustomer;

  const _CustomerSearchSection({
    required this.selectedCustomer,
    required this.searchController,
    required this.isSearching,
    required this.searchResults,
    required this.onSearchChanged,
    required this.onCustomerSelected,
    required this.onClearCustomer,
  });

  @override
  State<_CustomerSearchSection> createState() => _CustomerSearchSectionState();
}

class _CustomerSearchSectionState extends State<_CustomerSearchSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.customer,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Selected customer card
        if (widget.selectedCustomer != null)
          _SelectedCustomerCard(
            customer: widget.selectedCustomer!,
            onClear: widget.onClearCustomer,
          ),

        // Search bar
        if (widget.selectedCustomer == null)
          Column(
            children: [
              TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  hintText: loc.searchCustomers,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: widget.isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: widget.onSearchChanged,
              ),

              // Search results
              if (widget.searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.searchResults.length,
                    itemBuilder: (context, index) {
                      final customer = widget.searchResults[index];
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          '${customer.firstName} ${customer.lastName}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          customer.fullName ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onTap: () => widget.onCustomerSelected(customer),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _SelectedCustomerCard extends StatelessWidget {
  final Person customer;
  final VoidCallback onClear;

  const _SelectedCustomerCard({
    required this.customer,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${customer.firstName} ${customer.lastName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (customer.fullName != null)
                    Text(
                      customer.fullName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  // if (customer.phone != null)
                  //   Text(
                  //     customer.phone!,
                  //     style: theme.textTheme.bodySmall?.copyWith(
                  //       color: theme.colorScheme.onSurfaceVariant,
                  //     ),
                  //   ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.close,
                size: 20,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutItemCard extends StatelessWidget {
  final CartItem item;

  const _CheckoutItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.isService
                    ? theme.colorScheme.secondary.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.isService ? Icons.construction : Icons.inventory_2,
                color: item.isService
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity} × ${loc.price(item.unitPrice?.toStringAsFixed(2) ?? '0.00')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (item.isService && item.scheduledDate != null)
                    Text(
                      'Scheduled: ${item.scheduledDate}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            // Item total
            Text(
              loc.price(item.totalPrice.toStringAsFixed(2)),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _DocumentTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final types = [
      ('invoice', Icons.receipt_long, loc.invoice),
      ('invoice_receipt', Icons.receipt, loc.invoiceReceipt),
      ('receipt', Icons.description, loc.receiptOnly),
      ('none', Icons.block, loc.none),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final (id, icon, label) = type;
        final isSelected = selectedType == id;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(id),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _PaymentTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final types = [
      ('payment', Icons.payment, loc.fullPayment),
      ('deposit', Icons.account_balance_wallet, loc.depositOnly),
    ];

    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final (id, icon, label) = type;
        final isSelected = selectedType == id;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(id),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final methods = [
      ('cash', Icons.money, loc.cash),
      ('card', Icons.credit_card, loc.card),
      ('bank_transfer', Icons.account_balance, loc.bankTransfer),
      ('mobile_payment', Icons.phone_android, loc.mobilePayment),
      ('check', Icons.description, loc.check),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((method) {
        final (id, icon, label) = method;
        final isSelected = selectedMethod == id;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(id),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentDetailsSection extends StatelessWidget {
  final String paymentMethod;
  final ValueChanged<String> onCardDetailsChanged;
  final ValueChanged<String> onBankDetailsChanged;
  final ValueChanged<String> onMobileProviderChanged;

  const _PaymentDetailsSection({
    required this.paymentMethod,
    required this.onCardDetailsChanged,
    required this.onBankDetailsChanged,
    required this.onMobileProviderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildDetailsContent(context, loc),
    );
  }

  Widget _buildDetailsContent(BuildContext context, AppLocalizations loc) {
    switch (paymentMethod) {
      case 'card':
        return _CardDetails(
          onChanged: onCardDetailsChanged,
        );
      case 'bank_transfer':
        return _BankTransferDetails(
          onChanged: onBankDetailsChanged,
        );
      case 'mobile_payment':
        return _MobilePaymentDetails(
          onChanged: onMobileProviderChanged,
        );
      case 'check':
        return _CheckDetails();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CardDetails extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _CardDetails({required this.onChanged});

  @override
  State<_CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<_CardDetails> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String _cardType = 'visa';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.cardDetails,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _cardType,
                decoration: InputDecoration(
                  labelText: loc.cardType,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['visa', 'mastercard', 'amex'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _cardType = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: loc.cardNumber,
                  hintText: '**** **** **** ****',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: loc.expiryDate,
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '***',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankTransferDetails extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _BankTransferDetails({required this.onChanged});

  @override
  State<_BankTransferDetails> createState() => _BankTransferDetailsState();
}

class _BankTransferDetailsState extends State<_BankTransferDetails> {
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _bankController.dispose();
    _accountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.bankTransferDetails,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankController,
                decoration: InputDecoration(
                  labelText: loc.bankName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountController,
                decoration: InputDecoration(
                  labelText: loc.accountNumber,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: loc.reference,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobilePaymentDetails extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _MobilePaymentDetails({required this.onChanged});

  @override
  State<_MobilePaymentDetails> createState() => _MobilePaymentDetailsState();
}

class _MobilePaymentDetailsState extends State<_MobilePaymentDetails> {
  String _provider = 'orange_money';
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.mobilePaymentDetails,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _provider,
                decoration: InputDecoration(
                  labelText: loc.serviceProvider,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  'orange_money',
                  'ooredoo_money',
                  'nedjma_pay',
                  'paypal',
                  'stc_pay',
                ].map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Text(provider.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _provider = value!);
                  widget.onChanged(value!);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: loc.phoneNumber,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.checkDetails,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                loc.checkPaymentNote,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _DeliveryTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final types = [
      ('pickup', Icons.store, loc.pickup, loc.pickupDesc),
      ('delivery', Icons.delivery_dining, loc.delivery, loc.deliveryDesc),
      ('shipping', Icons.local_shipping, loc.shipping, loc.shippingDesc),
    ];

    return Column(
      children: types.map((type) {
        final (id, icon, title, description) = type;
        final isSelected = selectedType == id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 1 : 0,
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Icon(icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface),
            title: Text(title),
            subtitle: Text(description),
            trailing: isSelected
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () => onChanged(id),
          ),
        );
      }).toList(),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double tax;

  const _OrderSummaryCard({
    required this.subtotal,
    required this.tax,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final total = subtotal + tax;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.orderSummary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: loc.subtotal,
              value: loc.price(subtotal.toStringAsFixed(2)),
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: loc.tax,
              value: loc.price(tax.toStringAsFixed(2)),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: loc.total,
              value: loc.price(total.toStringAsFixed(2)),
              valueStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: valueStyle ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CheckoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          loc.placeOrder.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final double total;
  final String documentType;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.total,
    required this.documentType,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.orderConfirmed,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.orderPlacedSuccessfully,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.total,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        loc.price(total.toStringAsFixed(2)),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.documentType,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _getDocumentTypeText(loc, documentType),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Print document
                      Navigator.pop(context);
                    },
                    child: Text(loc.printDocument),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDone,
                    child: Text(loc.done),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDocumentTypeText(AppLocalizations loc, String type) {
    switch (type) {
      case 'invoice':
        return loc.invoice;
      case 'invoice_receipt':
        return loc.invoiceReceipt;
      case 'receipt':
        return loc.receiptOnly;
      default:
        return loc.none;
    }
  }
}
