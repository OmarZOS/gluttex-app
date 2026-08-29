import 'package:flutter/material.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:provider/provider.dart';

class NewDeliverySheet extends StatefulWidget {
  final DeliveryChangeNotifier? notifier;

  const NewDeliverySheet({
    super.key,
    this.notifier,
  });

  @override
  State<NewDeliverySheet> createState() => _NewDeliverySheetState();
}

class _NewDeliverySheetState extends State<NewDeliverySheet> {
  late DeliveryChangeNotifier _notifier;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _packageCountController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _goodsDescriptionController = TextEditingController();
  final _merchantNameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _hsCodeController = TextEditingController();

  // Form State
  String _selectedShippingMethod = 'standard';
  String? _selectedRecipientType;
  int? _recipientId;
  int? _providerId;
  bool _isLoading = false;

  final List<String> _shippingMethods = [
    'standard',
    'express',
    'overnight',
    'pickup',
    'courier',
    'same_day',
    'international',
  ];

  final List<String> _recipientTypes = [
    'Person',
    'Provider',
  ];

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? context.read<DeliveryChangeNotifier>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.notifier == null) {
      _notifier = context.read<DeliveryChangeNotifier>();
    }
  }

  @override
  void dispose() {
    _packageCountController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _goodsDescriptionController.dispose();
    _merchantNameController.dispose();
    _instructionsController.dispose();
    _hsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(theme, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipient Section
                    _buildSectionHeader(
                        'Recipient Information', Icons.person_outlined),
                    const SizedBox(height: 12),
                    _buildRecipientSection(theme, colorScheme),
                    const SizedBox(height: 20),

                    // Package Details
                    _buildSectionHeader(
                        'Package Details', Icons.inventory_2_outlined),
                    const SizedBox(height: 12),
                    _buildPackageSection(theme, colorScheme),
                    const SizedBox(height: 20),

                    // Shipping Information
                    _buildSectionHeader(
                        'Shipping Information', Icons.local_shipping_outlined),
                    const SizedBox(height: 12),
                    _buildShippingSection(theme, colorScheme),
                    const SizedBox(height: 20),

                    // Merchant Information
                    _buildSectionHeader(
                        'Merchant Information', Icons.store_outlined),
                    const SizedBox(height: 12),
                    _buildMerchantSection(theme, colorScheme),
                    const SizedBox(height: 20),

                    // Additional Information
                    _buildSectionHeader(
                        'Additional Information', Icons.note_outlined),
                    const SizedBox(height: 12),
                    _buildAdditionalSection(theme, colorScheme),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(theme, colorScheme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Create New Delivery',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Recipient Type Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Recipient Type',
            border: OutlineInputBorder(),
          ),
          value: _selectedRecipientType,
          items: _recipientTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRecipientType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select recipient type';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Recipient ID
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _selectedRecipientType == 'Person'
                ? 'Person ID'
                : 'Provider ID',
            hintText:
                'Enter ${_selectedRecipientType?.toLowerCase() ?? 'recipient'} ID',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            _recipientId = int.tryParse(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recipient ID';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPackageSection(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _packageCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Package Count',
              border: OutlineInputBorder(),
              helperText: 'Number of packages',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter package count';
              }
              if (int.tryParse(value) == null || int.parse(value) < 1) {
                return 'Must be at least 1';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
              helperText: 'Total weight in kg',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter weight';
              }
              if (double.tryParse(value) == null || double.parse(value) < 0) {
                return 'Enter valid weight';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShippingSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Shipping Method',
            border: OutlineInputBorder(),
          ),
          value: _selectedShippingMethod,
          items: _shippingMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedShippingMethod = value ?? 'standard';
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dimensionsController,
          decoration: const InputDecoration(
            labelText: 'Dimensions (LxWxH)',
            border: OutlineInputBorder(),
            hintText: 'e.g., 30x20x15 cm',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _hsCodeController,
          decoration: const InputDecoration(
            labelText: 'HS Code',
            border: OutlineInputBorder(),
            hintText: 'Harmonized System Code',
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantSection(ThemeData theme, ColorScheme colorScheme) {
    return TextFormField(
      controller: _merchantNameController,
      decoration: const InputDecoration(
        labelText: 'Merchant Name',
        border: OutlineInputBorder(),
        hintText: 'Name of the merchant/sender',
      ),
    );
  }

  Widget _buildAdditionalSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        TextFormField(
          controller: _goodsDescriptionController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Goods Description',
            border: OutlineInputBorder(),
            hintText: 'Describe the items being delivered',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _instructionsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Special Instructions',
            border: OutlineInputBorder(),
            hintText: 'Any special delivery instructions',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Create Delivery',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Build delivery data
      final deliveryData = {
        'recipient_person':
            _selectedRecipientType == 'Person' ? _recipientId : null,
        'recipient_provider':
            _selectedRecipientType == 'Provider' ? _recipientId : null,
        'delivery_package_count': int.parse(_packageCountController.text),
        'delivery_total_weight': double.parse(_weightController.text),
        'delivery_cargo_dimensions': _dimensionsController.text,
        'delivery_goods_description': _goodsDescriptionController.text,
        'delivery_merchant_name': _merchantNameController.text,
        'delivery_special_instructions': _instructionsController.text,
        'hs_code': _hsCodeController.text,
        'delivery_shipping_method': _selectedShippingMethod,
        'delivery_status': 'PENDING',
        'delivery_fee': 0.0,
        'delivery_address_id': 0,
        'delivery_provider_id': 0,
        'delivery_broker_id': 0,
      };

      // // Create delivery using the notifier
      // final success = await _notifier.createDelivery(deliveryData);

      // if (success && mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Delivery created successfully!'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      //   Navigator.pop(context);
      // } else if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Failed to create delivery'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
