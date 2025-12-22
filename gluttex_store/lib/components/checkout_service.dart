import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/services/CartService.dart';
import 'package:gluttex_core/business/services/OrderService.dart';
import 'package:gluttex_event/views/checkout_view_model.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_event/user_change_notifier.dart';

class CheckoutService {
  final CartService _cartService = GluttexLocator.get<CartService>();

  Future<CheckoutResult> processCheckout({
    required Cart cart,
    required CheckoutViewModel viewModel,
    required int sellingUserId,
    required int providerId,
  }) async {
    try {
      // Validate inputs
      if (cart.isEmpty) {
        return CheckoutResult.failure('Cart is empty');
      }
      // Determine customer reference
      int? customerRef;
      int? clientUserId;
      if (viewModel.selectedCustomer != null) {
        // AppUser customer
        customerRef = viewModel.selectedCustomer!.idPerson;
        clientUserId = viewModel.selectedCustomer!.id_app_user;
      } else if (viewModel.selectedPerson != null) {
        // Person customer
        customerRef = viewModel.selectedPerson!.id_person;
      }

      // Prepare checkout data
      final checkoutData = await _prepareCheckoutData(
        cart: cart,
        viewModel: viewModel,
        sellingUserId: sellingUserId,
        providerId: providerId,
        customerRef: customerRef,
        clientUserId: clientUserId,
      );

      // debugPrint(checkoutData.toString());

      // Submit the order
      final result = await _submitOrder(checkoutData);

      if (result.isSuccess) {
        // Clear the cart after successful checkout
        // cart.clear();
        return CheckoutResult.success(
          result.message,
          orderId: result.orderId,
        );
      }

      return CheckoutResult.failure(result.message);
    } catch (e) {
      return CheckoutResult.failure('Checkout failed: $e');
    }
  }

  Future<CheckoutData> _prepareCheckoutData({
    required Cart cart,
    required CheckoutViewModel viewModel,
    required int sellingUserId,
    required int providerId,
    int? customerRef,
    int? clientUserId,
  }) async {
    // Calculate totals
    final totalAmount = cart.totalAmount;
    double paidMoney = 0.0;

    // Determine paid amount based on payment type
    if (viewModel.paymentType == 'payment') {
      if (viewModel.paymentMethod == 'cash') {
        paidMoney = totalAmount;
      } else if (viewModel.paymentMethod == 'card') {
        paidMoney = totalAmount; // Full payment for card
      } else if (viewModel.paymentMethod == 'bank') {
        paidMoney = totalAmount; // Full payment for bank transfer
      } else if (viewModel.paymentMethod == 'mobile') {
        paidMoney = totalAmount; // Full payment for mobile money
      }
    } else if (viewModel.paymentType == 'deposit') {
      // For deposit, you might want to handle partial payments
      // This would need to be configured in your UI
      paidMoney = totalAmount * 0.5; // Example: 50% deposit
    }

    // Build ordered items from cart (products)
    final List<Map<String, dynamic>> orderedItems = [];

    for (final cartItem in cart.items.where((item) => item.isProduct)) {
      orderedItems.add({
        "id_ordered_item": 0,
        "ordered_product_id": cartItem.product?.id_product ?? 0,
        "order_ref": 0,
        "product_discount": 0.0,
        "ordered_quantity": cartItem.quantity,
        "unit_price": cartItem.unitPrice ?? 0.0,
        "applied_vat": 0.0,
      });
    }
    // debugPrint(orderedItems.length.toString());
    // Build provided services from cart (services)
    final List<Map<String, dynamic>> providedServices = [];

    for (final cartItem in cart.items.where((item) => item.isService)) {
      debugPrint(cartItem.service?.id.toString());
      debugPrint(cartItem.quantity.toString());
      debugPrint(cartItem.unitPrice.toString());
      debugPrint(cartItem.totalPrice.toString());
      debugPrint(cartItem.scheduledDate.toString());
      debugPrint(cartItem.scheduledTime.toString());

      providedServices.add({
        "ordered_service_service_id": cartItem.service?.id ?? 0,
        "ordered_service_quantity": cartItem.quantity,
        "ordered_service_unit_price": cartItem.unitPrice ?? 0.0,
        "ordered_service_total_price": cartItem.totalPrice,
        // "ordered_service_scheduled_at": cartItem.scheduledDate ?? "",
        // "ordered_service_notes": cartItem.scheduledTime ?? "",
        // "resource_requirement_id":
        //     cartItem.service?.resourceRequirements.first.id ?? 0,
      });
      // debugPrint("Ref: " + cartItem.service.toString());
    }

    // Build cart data
    final Map<String, dynamic> apiCart = {
      "cart_id": 0, // 0 for new cart
      "cart_product_provider_id": providerId,
      "cart_selling_user": sellingUserId,
      "cart_person_ref": customerRef,
      "cart_client_user": clientUserId,
      "cart_status": "PENDING",
      "cart_total_amount": totalAmount,
      "cart_notes": viewModel.notes,
      "cart_invoice": viewModel.documentType.contains('invoice'),
      "cart_receipt": viewModel.documentType.contains('receipt'),
      "cart_deposit": viewModel.paymentType == 'deposit',
      "cart_payment": viewModel.paymentType == 'payment',
      "cart_paid_money": paidMoney,
      "cart_payment_method": viewModel.paymentMethod,
      "cart_card_type": viewModel.cardType,
      "cart_card_details": viewModel.cardDetails,
      "cart_bank_details": viewModel.bankDetails,
      "cart_mobile_provider": viewModel.mobileProvider,
      "cart_delivery_type": viewModel.deliveryType,
    };

    // Add checkout parameters
    final Map<String, dynamic> parameters = {};
    for (final param in viewModel.parameters) {
      parameters[param.key] = param.value;
    }
    apiCart["cart_parameters"] = parameters;

    // Build client data from selected customer
    final Map<String, dynamic> client = {};
    debugPrint("Start................");

    if (viewModel.selectedCustomer != null) {
      final customer = viewModel.selectedCustomer!;
      client.addAll({
        "id_person": customer.idPerson,
        "person_details_id": customer.personDetailsId,
        "id_person_details": customer.personDetailsId,
        "person_first_name": customer.personFirstName ?? "",
        "person_last_name": customer.personLastName ?? "",
        "person_birth_date": customer.personBirthDate ?? "",
        "person_gender": customer.personGender ?? "",
        "person_nationality": customer.personNationality ?? "",
        // "person_email": customer.personEmail ?? "",
        // "person_phone": customer.personPhone ?? "",
        "id_blood_type": 0,
      });
    } else if (viewModel.selectedPerson != null) {
      final person = viewModel.selectedPerson!;
      final details = person.person_details;
      client.addAll({
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
    return CheckoutData(
      orderedItems: orderedItems,
      providedServices: providedServices,
      cart: apiCart,
      client: client,
      paymentMethod: viewModel.paymentMethod,
    );
  }

  Future<OrderSubmissionResult> _submitOrder(CheckoutData checkoutData) async {
    try {
      // Prepare the complete order data
      final orderData = {
        "api_ordered_items": checkoutData.orderedItems,
        "api_provided_services": checkoutData.providedServices,
        "api_cart": checkoutData.cart,
        "client": checkoutData.client,

        // "payment_method": checkoutData.paymentMethod,
      };

      final data = jsonEncode(orderData);
      debugPrint(data.toString());
      // Call the order service
      final result = await _cartService.addCart(orderData, params: {
        "provider_id": checkoutData.cart["cart_product_provider_id"],
        "seller_user_id": checkoutData.cart["cart_selling_user"],
        "buyer_user_id": checkoutData.cart["cart_client_user"] ?? 0,
      });

      if (result != null && result.cartId != null) {
        return OrderSubmissionResult.success(
          'Order placed successfully. Order ID: ${result.cartId}',
          orderId: result.cartId!,
        );
      }

      return OrderSubmissionResult.failure('Failed to place order');
    } catch (e) {
      return OrderSubmissionResult.failure('Order submission error: $e');
    }
  }
}

// Supporting classes
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

class OrderSubmissionResult {
  final bool isSuccess;
  final String message;
  final int? orderId;

  const OrderSubmissionResult._({
    required this.isSuccess,
    required this.message,
    this.orderId,
  });

  factory OrderSubmissionResult.success(String message, {int? orderId}) {
    return OrderSubmissionResult._(
      isSuccess: true,
      message: message,
      orderId: orderId,
    );
  }

  factory OrderSubmissionResult.failure(String message) {
    return OrderSubmissionResult._(
      isSuccess: false,
      message: message,
    );
  }
}

class CheckoutData {
  final List<Map<String, dynamic>> orderedItems;
  final List<Map<String, dynamic>> providedServices;
  final Map<String, dynamic> cart;
  final Map<String, dynamic> client;
  final String paymentMethod;

  const CheckoutData({
    required this.orderedItems,
    required this.providedServices,
    required this.cart,
    required this.client,
    required this.paymentMethod,
  });
}

String _getCustomerName(CheckoutViewModel viewModel) {
  if (viewModel.selectedCustomer != null) {
    final customer = viewModel.selectedCustomer!;
    return '${customer.personFirstName} ${customer.personLastName}'.trim();
  } else if (viewModel.selectedPerson != null) {
    return viewModel.selectedPerson!.fullName;
  }
  return 'Guest';
}

// Processing Dialog Widget
class ProcessingDialog extends StatelessWidget {
  const ProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing your order...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Checkout Success Screen
class CheckoutSuccessScreen extends StatelessWidget {
  final int? orderId;
  final double totalAmount;
  final String customerName;

  const CheckoutSuccessScreen({
    super.key,
    this.orderId,
    required this.totalAmount,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Successful'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed Successfully!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (orderId != null)
                Text(
                  'Order ID: #$orderId',
                  style: theme.textTheme.bodyLarge,
                ),
              const SizedBox(height: 8),
              Text(
                'Customer: $customerName',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to orders screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/orders',
                        (route) => false,
                      );
                    },
                    icon: Icon(Icons.list_alt),
                    label: Text('View Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Go back to shopping
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Continue Shopping'),
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
