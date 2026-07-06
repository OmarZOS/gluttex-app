import 'dart:convert';
// import 'dart:deve' as developer;
import 'dart:developer' as developer;
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/services/CartService.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:locator/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutParameter {
  final String key;
  final String value;

  CheckoutParameter({required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  factory CheckoutParameter.fromMap(Map<String, dynamic> map) {
    return CheckoutParameter(
      key: map['key'] ?? '',
      value: map['value'] ?? '',
    );
  }
}

class CheckoutViewModel extends ChangeNotifier {
  // Services
  final CartService _cartService = AppLocator.get<CartService>();

  // State
  AppUser? _selectedCustomer;
  Person? _selectedPerson;
  String _documentType = 'receipt';
  String _paymentType = 'payment'; // 'payment' or 'deposit'
  String _paymentMethod = 'cash';
  String _deliveryType = 'pickup';
  String _notes = '';
  List<CheckoutParameter> _parameters = [];
  bool _isProcessing = false;
  String? _cardDetails;
  String? _bankDetails;
  String? _mobileProvider;
  String _cardType = 'visa';
  final List<CheckoutParameter> _savedParameters = [];
  bool _isLoadingParameters = false;
  CheckoutResult? _lastCheckoutResult;
  double _depositAmount = 0.0; // User-specified deposit amount
  bool _applyVAT = false; // Whether to apply VAT (for invoices)
  DeliveryData? _deliveryData;

  String? _dueDate;

  static const String _prefsKey = 'checkout_parameters';
  static const double vatRate = 0.19; // 19% VAT

  // Getters
  AppUser? get selectedCustomer => _selectedCustomer;
  Person? get selectedPerson => _selectedPerson;
  String get documentType => _documentType;
  String get paymentType => _paymentType;
  String get paymentMethod => _paymentMethod;
  String get deliveryType => _deliveryType;
  String get notes => _notes;
  List<CheckoutParameter> get parameters => _parameters;
  List<CheckoutParameter> get savedParameters => _savedParameters;
  bool get isProcessing => _isProcessing;
  String? get cardDetails => _cardDetails;
  String? get bankDetails => _bankDetails;
  String? get mobileProvider => _mobileProvider;
  String get cardType => _cardType;
  bool get isLoadingParameters => _isLoadingParameters;
  CheckoutResult? get lastCheckoutResult => _lastCheckoutResult;
  double get depositAmount => _depositAmount;
  bool get applyVAT => _applyVAT;
  DeliveryData? get deliveryData => _deliveryData;

  CheckoutViewModel() {
    _loadSavedParameters();
    // Apply VAT by default if creating an invoice
    _updateVATSetting();
  }

  // ===================== CHECKOUT CORE FUNCTIONALITY =====================

  /// Process checkout using the local cart from CartChangeNotifier
  Future<CheckoutResult> processCheckout({
    required CartChangeNotifier cartNotifier,
    required int sellingUserId,
    required int providerId,
  }) async {
    try {
      _isProcessing = true;
      _lastCheckoutResult = null;
      notifyListeners();

      // Validate cart has items
      if (cartNotifier.cart.isEmpty) {
        return _setCheckoutResult(CheckoutResult.failure('Cart is empty'));
      }

      // Prepare and submit checkout data
      final checkoutData = await _prepareCheckoutData(
        cart: cartNotifier.cart,
        sellingUserId: sellingUserId,
        providerId: providerId,
      );

      final result = await _submitOrder(checkoutData);

      if (result.isSuccess) {
        // Clear the local cart on success
        cartNotifier.clearCart();
        // Reset checkout state
        resetAfterCheckout();
      }

      return _setCheckoutResult(result);
    } catch (e) {
      developer.log('Checkout failed: $e', name: 'CheckoutViewModel');
      return _setCheckoutResult(CheckoutResult.failure('Checkout failed: $e'));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Process checkout with a specific cart (for API carts)
  Future<CheckoutResult> processCartCheckout({
    required Cart cart,
    required int sellingUserId,
    required int providerId,
  }) async {
    try {
      _isProcessing = true;
      _lastCheckoutResult = null;
      notifyListeners();

      // Validate cart has items
      if (cart.isEmpty) {
        return _setCheckoutResult(CheckoutResult.failure('Cart is empty'));
      }

      // Prepare and submit checkout data
      final checkoutData = await _prepareCheckoutData(
        cart: cart,
        sellingUserId: sellingUserId,
        providerId: providerId,
      );

      final result = await _submitOrder(checkoutData);

      return _setCheckoutResult(result);
    } catch (e) {
      developer.log('Cart checkout failed: $e', name: 'CheckoutViewModel');
      return _setCheckoutResult(CheckoutResult.failure('Checkout failed: $e'));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  CheckoutResult _setCheckoutResult(CheckoutResult result) {
    _lastCheckoutResult = result;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> _prepareCheckoutData({
    required Cart cart,
    required int sellingUserId,
    required int providerId,
  }) async {
    // Determine customer reference
    int? customerRef;
    int? clientUserId;

    // IMPORTANT: Only set customerRef if we have a valid user (id != 0)
    if (_selectedCustomer != null) {
      // Check if this is a real user (id != 0) or guest (id == 0)
      if (_selectedCustomer!.idAppUser != 0) {
        // Real user - include their data
        customerRef = _selectedCustomer!.idPerson;
        clientUserId = _selectedCustomer!.idAppUser;
      } else {
        // Guest user (id == 0) - don't send customer reference
        // Still send clientUserId as 0 to indicate guest
        clientUserId = 0;
      }
    } else if (_selectedPerson != null) {
      // Person is always a real record (not a guest)
      customerRef = _selectedPerson!.id_person;
    }

    // Calculate totals with VAT if applicable
    final subtotal =
        _applyVAT ? cart.totalAmount * (1 - vatRate) : cart.totalAmount;
    final vatAmount = _applyVAT ? subtotal * vatRate : 0.0;
    final totalAmount = subtotal + vatAmount;

    double paidMoney = 0.0;

    // Determine paid amount based on payment type
    if (_paymentType == 'payment') {
      paidMoney = totalAmount; // Full payment
    } else if (_paymentType == 'deposit') {
      // Use user-specified deposit amount, but ensure it doesn't exceed total
      paidMoney = _depositAmount.clamp(0.0, totalAmount);
    }

    // Build ordered items from cart (products) - using correct key name "ordered_items"
    final List<Map<String, dynamic>> orderedItems = [];

    for (final cartItem in cart.items.where((item) => item.isProduct)) {
      orderedItems.add({
        "id_ordered_item": 0,
        "ordered_product_id": cartItem.product?.id_product ?? 0,
        "order_ref": 0,
        "product_discount": 0.0,
        "ordered_quantity": cartItem.quantity,
        "unit_price": _applyVAT
            ? ((cartItem.unitPrice ?? 0) * (1 - vatRate))
            : (cartItem.unitPrice ?? 0.0),
        "applied_vat": _applyVAT ? vatRate * 100 : 0.0, // Convert to percentage
      });
    }

    // Build ordered services from cart - using correct key name "ordered_services"
    final List<Map<String, dynamic>> orderedServices = [];

    for (final cartItem in cart.items.where((item) => item.isService)) {
      orderedServices.add({
        "ordered_service_service_id": cartItem.service?.id ?? 0,
        "ordered_service_quantity": cartItem.quantity,
        "ordered_service_unit_price": _applyVAT
            ? ((cartItem.unitPrice ?? 0) * (1 - vatRate))
            : cartItem.unitPrice ?? 0.0,
        "ordered_service_total_price": _applyVAT
            ? (cartItem.totalPrice * (1 - vatRate))
            : cartItem.totalPrice,
        "ordered_service_scheduled_at":
            cartItem.scheduledDate ?? DateTime.now().toIso8601String(),
        "ordered_service_notes": cartItem.scheduledTime ?? "",
        "resource_requirement_id": 0,
      });
    }

    // Build cart data - using correct key name "cart" (not "api_cart")
    final Map<String, dynamic> cartData = {
      "cart_id": 0,
      "cart_product_provider_id": providerId,
      "cart_selling_user": sellingUserId,
      "cart_person_ref": customerRef,
      "cart_client_user": clientUserId ?? 0,
      "cart_due_date": _dueDate ?? DateTime.now().toIso8601String(),
      "cart_status": "PENDING",
      "cart_total_amount": totalAmount,
      "cart_notes": _notes,
      "cart_invoice": _documentType.contains('invoice'),
      "cart_receipt": _documentType.contains('receipt'),
      "cart_deposit": _paymentType == 'deposit',
      "cart_payment": _paymentType == 'payment',
      "cart_paid_money": paidMoney,
    };

    // Add additional cart fields if needed
    if (_applyVAT) {
      cartData["cart_vat_amount"] = vatAmount;
      cartData["cart_subtotal"] = subtotal;
      cartData["cart_vat_rate"] = vatRate;
    }

    if (_paymentMethod.isNotEmpty) {
      cartData["cart_payment_method"] = _paymentMethod;
    }

    if (_cardType.isNotEmpty) {
      cartData["cart_card_type"] = _cardType;
    }

    if (_cardDetails != null && _cardDetails!.isNotEmpty) {
      cartData["cart_card_details"] = _cardDetails;
    }

    if (_bankDetails != null && _bankDetails!.isNotEmpty) {
      cartData["cart_bank_details"] = _bankDetails;
    }

    if (_mobileProvider != null && _mobileProvider!.isNotEmpty) {
      cartData["cart_mobile_provider"] = _mobileProvider;
    }

    if (_deliveryType.isNotEmpty) {
      cartData["cart_delivery_type"] = _deliveryType;
    }

    if (_depositAmount > 0) {
      cartData["cart_deposit_amount"] = _depositAmount;
    }

    // Add checkout parameters
    if (_parameters.isNotEmpty) {
      final Map<String, dynamic> parameters = {};
      for (final param in _parameters) {
        parameters[param.key] = param.value;
      }
      cartData["cart_parameters"] = parameters;
    }

    // Build client data - ONLY for real users (id != 0)
    final Map<String, dynamic> clientData = {};

    if (_selectedCustomer != null && _selectedCustomer!.idAppUser != 0) {
      // Only send client data for real users, not guests
      final customer = _selectedCustomer!;
      clientData.addAll({
        "id_person": customer.idPerson,
        "person_details_id": customer.personDetailsId,
        "id_person_details": customer.personDetailsId,
        "person_first_name": customer.personFirstName ?? "",
        "person_last_name": customer.personLastName ?? "",
        "person_birth_date": customer.personBirthDate ?? "",
        "person_gender": customer.personGender ?? "",
        "person_nationality": customer.personCountryCode ?? "",
        "id_blood_type": 0,
      });
    } else if (_selectedPerson != null) {
      // Person is always a real record
      final person = _selectedPerson!;
      final details = person.person_details;
      clientData.addAll({
        "id_person": person.id_person,
        "person_details_id": person.person_details_id,
        "id_person_details": details.id_person_details,
        "person_first_name": details.person_first_name,
        "person_last_name": details.person_last_name,
        "person_birth_date": details.person_birth_date?.toIso8601String() ?? "",
        "person_gender": details.person_gender,
        "person_nationality": details.person_nationality,
        "person_email": details.person_email ?? "",
        "person_phone": details.person_phone ?? "",
        "id_blood_type": person.person_blood_type_id,
      });
    }

    // Build the final payload with CORRECT keys
    final Map<String, dynamic> payload = {
      "ordered_items": orderedItems,
      "ordered_services": orderedServices,
      "cart": cartData,
    };

    // Only add client data if we have a real customer
    if (clientData.isNotEmpty) {
      payload["client"] = clientData;
    }

    // Add delivery data if needed
    if (_deliveryType != "pickup" && _deliveryData != null) {
      payload["delivery"] = _deliveryData!.toJson();
    }

    developer.log('Prepared checkout payload keys: ${payload.keys}',
        name: 'CheckoutViewModel');
    developer.log('Ordered items count: ${orderedItems.length}',
        name: 'CheckoutViewModel');
    developer.log('Ordered services count: ${orderedServices.length}',
        name: 'CheckoutViewModel');
    developer.log('Has client: ${clientData.isNotEmpty}',
        name: 'CheckoutViewModel');
    developer.log('Has delivery: ${payload.containsKey("delivery")}',
        name: 'CheckoutViewModel');

    return payload;
  }

  Future<CheckoutResult> _submitOrder(Map<String, dynamic> checkoutData) async {
    try {
      developer.log('Submitting order data...', name: 'CheckoutViewModel');

      // Get parameters from checkout data - using correct key "cart"
      final apiCart = checkoutData["cart"] as Map<String, dynamic>;

      final result = await _cartService.addCart(checkoutData, params: {
        "provider_id": apiCart["cart_product_provider_id"],
        "seller_user_id": apiCart["cart_selling_user"],
        "buyer_user_id": apiCart["cart_client_user"] ?? 0,
      });

      if (result != null && result.cartId != null) {
        developer.log('Order submitted successfully! Cart ID: ${result.cartId}',
            name: 'CheckoutViewModel');
        return CheckoutResult.success(
          'Order placed successfully. Order ID: ${result.cartId}',
          orderId: result.cartId!,
        );
      }

      developer.log('Order submission returned null result',
          name: 'CheckoutViewModel');
      return CheckoutResult.failure('Failed to place order');
    } catch (e) {
      developer.log('Error in order submission: $e', name: 'CheckoutViewModel');
      return CheckoutResult.failure('Order submission error: $e');
    }
  }

  // ===================== CUSTOMER MANAGEMENT =====================

  Future<Person?> createNewCustomer(Person person) async {
    try {
      _isProcessing = true;
      notifyListeners();

      developer.log('Creating new customer: ${person.fullName}',
          name: 'CheckoutViewModel');

      // Here you would call your API to save the person to the database
      // For now, we just set it as selected
      _selectedPerson = person;

      notifyListeners();
      return person;
    } catch (e) {
      developer.log('Error creating customer: $e', name: 'CheckoutViewModel');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ===================== PARAMETERS MANAGEMENT =====================

  Future<void> _loadSavedParameters() async {
    _isLoadingParameters = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final parametersJson = prefs.getStringList(_prefsKey) ?? [];

      _savedParameters.clear();
      for (final jsonString in parametersJson) {
        try {
          final map = json.decode(jsonString) as Map<String, dynamic>;
          _savedParameters.add(CheckoutParameter.fromMap(map));
        } catch (e) {
          developer.log('Error parsing parameter: $e',
              name: 'CheckoutViewModel');
        }
      }
    } catch (e) {
      developer.log('Error loading parameters: $e', name: 'CheckoutViewModel');
    } finally {
      _isLoadingParameters = false;
      notifyListeners();
    }
  }

  Future<void> saveParameter(CheckoutParameter parameter) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!_savedParameters.any((p) => p.key == parameter.key)) {
        _savedParameters.add(parameter);

        final parametersJson =
            _savedParameters.map((p) => json.encode(p.toMap())).toList();

        await prefs.setStringList(_prefsKey, parametersJson);

        notifyListeners();
      }
    } catch (e) {
      developer.log('Error saving parameter: $e', name: 'CheckoutViewModel');
      rethrow;
    }
  }

  Future<void> updateParameter(int index, CheckoutParameter parameter) async {
    try {
      if (index >= 0 && index < _savedParameters.length) {
        _savedParameters[index] = parameter;

        final prefs = await SharedPreferences.getInstance();
        final parametersJson =
            _savedParameters.map((p) => json.encode(p.toMap())).toList();

        await prefs.setStringList(_prefsKey, parametersJson);

        notifyListeners();
      }
    } catch (e) {
      developer.log('Error updating parameter: $e', name: 'CheckoutViewModel');
      rethrow;
    }
  }

  Future<void> deleteParameter(int index) async {
    try {
      if (index >= 0 && index < _savedParameters.length) {
        _savedParameters.removeAt(index);

        final prefs = await SharedPreferences.getInstance();
        final parametersJson =
            _savedParameters.map((p) => json.encode(p.toMap())).toList();

        await prefs.setStringList(_prefsKey, parametersJson);

        notifyListeners();
      }
    } catch (e) {
      developer.log('Error deleting parameter: $e', name: 'CheckoutViewModel');
      rethrow;
    }
  }

  void useSavedParameter(CheckoutParameter parameter) {
    if (!_parameters.any((p) => p.key == parameter.key)) {
      _parameters
          .add(CheckoutParameter(key: parameter.key, value: parameter.value));
      notifyListeners();
    }
  }

  // ===================== STATE SETTERS =====================

  void setSelectedCustomer(AppUser? customer, Person? person) {
    _selectedCustomer = customer;
    _selectedPerson = person;
    notifyListeners();
  }

  void setDocumentType(String type) {
    _documentType = type;
    _updateVATSetting();
    notifyListeners();
  }

  void _updateVATSetting() {
    // Apply VAT only for invoices
    _applyVAT = _documentType.contains('invoice');
  }

  void setPaymentType(String type) {
    _paymentType = type;
    // Reset deposit amount when switching from deposit to payment
    if (type != 'deposit') {
      _depositAmount = 0.0;
    } else if (type != 'installment') {
      _dueDate = "";
    }
    notifyListeners();
  }

  void setPaymentAmount(double amount) {
    if (_paymentType == 'deposit') {
      _depositAmount = amount;
    }
    notifyListeners();
  }

  void setInstallmentDate(DateTime dueDate) {
    _dueDate = dueDate.toIso8601String();
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setDeliveryType(String type) {
    _deliveryType = type;
    notifyListeners();
  }

  void setDeliveryData(DeliveryData data) {
    _deliveryData = data;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void setParameters(List<CheckoutParameter> parameters) {
    _parameters = parameters;
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void setCardDetails(String? details) {
    _cardDetails = details;
    notifyListeners();
  }

  void setBankDetails(String? details) {
    _bankDetails = details;
    notifyListeners();
  }

  void setMobileProvider(String? provider) {
    _mobileProvider = provider;
    notifyListeners();
  }

  void setCardType(String type) {
    _cardType = type;
    notifyListeners();
  }

  void setDepositAmount(double amount) {
    _depositAmount = amount;
    notifyListeners();
  }

  void setApplyVAT(bool apply) {
    _applyVAT = apply;
    notifyListeners();
  }

  void addParameter(String key, String value) {
    _parameters.add(CheckoutParameter(key: key, value: value));
    notifyListeners();
  }

  void removeParameter(int index) {
    if (index >= 0 && index < _parameters.length) {
      _parameters.removeAt(index);
      notifyListeners();
    }
  }

  void clearAll() {
    _selectedCustomer = null;
    _selectedPerson = null;
    _documentType = 'receipt';
    _paymentType = 'payment';
    _paymentMethod = 'cash';
    _deliveryType = 'pickup';
    _notes = '';
    _dueDate = null;
    _parameters.clear();
    _cardDetails = null;
    _bankDetails = null;
    _mobileProvider = null;
    _cardType = 'visa';
    _depositAmount = 0.0;
    _applyVAT = false;
    _lastCheckoutResult = null;
    _updateVATSetting();
    notifyListeners();
  }

  void clearCurrentParameters() {
    _parameters.clear();
    notifyListeners();
  }

  void resetAfterCheckout() {
    _selectedCustomer = null;
    _selectedPerson = null;
    _notes = '';
    _parameters.clear();
    _cardDetails = null;
    _bankDetails = null;
    _mobileProvider = null;
    _depositAmount = 0.0;
    _lastCheckoutResult = null;
    _updateVATSetting();
    notifyListeners();
  }

  // Helper method to get customer name for display
  // Helper method to get customer name for display
  String getCustomerName() {
    if (_selectedCustomer != null) {
      final customer = _selectedCustomer!;
      if (customer.idAppUser == 0) {
        // Guest user
        return 'Guest';
      }
      return '${customer.personFirstName} ${customer.personLastName}'.trim();
    } else if (_selectedPerson != null) {
      return _selectedPerson!.fullName;
    }
    return 'No customer selected';
  }

// Helper method to check if current customer is a guest
  bool get isGuestCustomer {
    if (_selectedCustomer != null) {
      return _selectedCustomer!.idAppUser == 0;
    }
    return false; // Person is never a guest
  }

// Helper method to check if we have a real customer
  bool get hasRealCustomer {
    if (_selectedCustomer != null) {
      return _selectedCustomer!.idAppUser != 0;
    }
    return _selectedPerson != null; // Person is always real
  }

  // Helper method to calculate totals
  Map<String, double> calculateTotals(CartChangeNotifier cartNotifier) {
    final subtotal = cartNotifier.cart.totalAmount;
    final vatAmount = _applyVAT ? subtotal * vatRate : 0.0;
    final total = subtotal + vatAmount;
    final paidMoney =
        _paymentType == 'deposit' ? _depositAmount.clamp(0.0, total) : total;
    final balanceDue = total - paidMoney;

    return {
      'subtotal': subtotal,
      'vatAmount': vatAmount,
      'total': total,
      'paidMoney': paidMoney,
      'balanceDue': balanceDue,
      'vatRate': _applyVAT ? vatRate : 0.0,
    };
  }

  // Helper method to check if checkout can proceed
  // Helper method to check if checkout can proceed
  bool canCheckout(CartChangeNotifier cartNotifier) {
    // For deposit, ensure deposit amount is valid
    if (_paymentType == 'deposit') {
      final totals = calculateTotals(cartNotifier);
      if (_depositAmount <= 0 || _depositAmount > totals['total']!) {
        return false;
      }
    }

    // Allow checkout even with guest users (id == 0)
    // The cart must have items
    return cartNotifier.cart.isNotEmpty;

    // If you want to require SOME customer (even guest), use:
    // return cartNotifier.cart.isNotEmpty &&
    //        (_selectedCustomer != null || _selectedPerson != null);

    // If you want to require REAL customer (not guest), use:
    // return cartNotifier.cart.isNotEmpty &&
    //        ((_selectedCustomer != null && _selectedCustomer!.idAppUser != 0) ||
    //         _selectedPerson != null);
  } // Helper to get checkout summary

  Map<String, dynamic> getCheckoutSummary(CartChangeNotifier cartNotifier) {
    final totals = calculateTotals(cartNotifier);

    return {
      'customer': getCustomerName(),
      'subtotal': totals['subtotal'],
      'vatAmount': totals['vatAmount'],
      'vatRate': totals['vatRate'],
      'total': totals['total'],
      'paidMoney': totals['paidMoney'],
      'balanceDue': totals['balanceDue'],
      'itemCount': cartNotifier.cart.itemCount,
      'productCount': cartNotifier.productItemCount,
      'serviceCount': cartNotifier.serviceItemCount,
      'documentType': _documentType,
      'paymentType': _paymentType,
      'paymentMethod': _paymentMethod,
      'depositAmount': _depositAmount,
      'applyVAT': _applyVAT,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ===================== SUPPORTING CLASSES =====================

class CheckoutResult {
  final bool isSuccess;
  final String message;
  final int? orderId;

  const CheckoutResult._({
    required this.isSuccess,
    required this.message,
    this.orderId,
  });

  factory CheckoutResult.success(String message, {int? orderId}) {
    return CheckoutResult._(
      isSuccess: true,
      message: message,
      orderId: orderId,
    );
  }

  factory CheckoutResult.failure(String message) {
    return CheckoutResult._(
      isSuccess: false,
      message: message,
    );
  }
}
