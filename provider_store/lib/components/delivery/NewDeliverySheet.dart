import 'package:event/delivery_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';

class NewDeliverySheet extends StatefulWidget {
  final DeliveryChangeNotifier notifier;
  final int providerId;
  final Delivery? delivery;

  const NewDeliverySheet({
    super.key,
    required this.notifier,
    this.providerId = 0,
    this.delivery,
  });

  @override
  State<NewDeliverySheet> createState() => _NewDeliverySheetState();
}

class _NewDeliverySheetState extends State<NewDeliverySheet> {
  final _formKey = GlobalKey<FormState>();
  final _packages = <_PackageInput>[];
  final _goodsController = TextEditingController();
  final _merchantController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _hsCodeController = TextEditingController();
  late DeliveryChangeNotifier _notifier;

  String _shippingMethod = 'standard';
  String? _recipientType;
  int? _recipientId;
  bool _isLoading = false;

  bool get _isEditing => widget.delivery != null;
  double get _totalWeight => _packages.fold(
        0,
        (total, package) => total + (double.tryParse(package.weight.text) ?? 0),
      );

  static const _shippingMethods = [
    'standard',
    'express',
    'overnight',
    'pickup',
    'courier',
    'same_day',
    'international',
  ];

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier;
    final delivery = widget.delivery;
    if (delivery == null) {
      _packages.add(_PackageInput());
      return;
    }

    final count = delivery.delivery_package_count ?? 1;
    final weight = (delivery.delivery_total_weight ?? 0) / count;
    final dimensions = (delivery.delivery_cargo_dimensions ?? '')
        .split(RegExp(r'\s*,\s*|\s*\|\s*|\s*;\s*'));
    for (var index = 0; index < count; index++) {
      final parts = index < dimensions.length
          ? dimensions[index].split(RegExp(r'\s*[xX]\s*'))
          : <String>[];
      _packages.add(_PackageInput(
        length: parts.isNotEmpty ? parts[0] : '',
        width: parts.length > 1 ? parts[1] : '',
        height: parts.length > 2 ? parts[2] : '',
        weight: weight,
      ));
    }

    _goodsController.text = delivery.delivery_goods_description ?? '';
    _merchantController.text = delivery.delivery_merchant_name ?? '';
    _instructionsController.text = delivery.delivery_special_instructions ?? '';
    _hsCodeController.text = delivery.hs_code ?? '';
    _shippingMethod = delivery.delivery_shipping_method;
    if (delivery.recipient_person > 0) {
      _recipientType = 'Person';
      _recipientId = delivery.recipient_person;
    } else if (delivery.recipient_provider > 0) {
      _recipientType = 'Provider';
      _recipientId = delivery.recipient_provider;
    }
  }

  @override
  void dispose() {
    for (final package in _packages) {
      package.dispose();
    }
    _goodsController.dispose();
    _merchantController.dispose();
    _instructionsController.dispose();
    _hsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.of(context).size.height * .85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('Recipient Information', Icons.person_outline),
                    _recipientFields(),
                    _section('Package Details', Icons.inventory_2_outlined),
                    _packageFields(),
                    _section('Shipping Information', Icons.local_shipping),
                    _shippingFields(),
                    _section('Additional Information', Icons.note_outlined),
                    _additionalFields(),
                    const SizedBox(height: 24),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        Expanded(
          child: Text(
            _isEditing ? 'Edit Delivery' : 'Create New Delivery',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _recipientFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _recipientType,
          decoration: const InputDecoration(
              labelText: 'Recipient Type', border: OutlineInputBorder()),
          items: const ['Person', 'Provider']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _recipientType = value),
          validator: (value) => value == null ? 'Select recipient type' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: ValueKey(_recipientId),
          initialValue: _recipientId?.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Recipient ID', border: OutlineInputBorder()),
          onChanged: (value) => _recipientId = int.tryParse(value),
          validator: (value) => int.tryParse(value ?? '') == null
              ? 'Enter a valid recipient ID'
              : null,
        ),
      ],
    );
  }

  Widget _packageFields() {
    return Column(
      children: [
        ..._packages.asMap().entries.map((entry) {
          final index = entry.key;
          final package = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _dimension(package.length, 'Length')),
                    const SizedBox(width: 8),
                    Expanded(child: _dimension(package.width, 'Width')),
                    const SizedBox(width: 8),
                    Expanded(child: _dimension(package.height, 'Height')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: package.weight,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText: 'Package ${index + 1} weight (kg)',
                            border: const OutlineInputBorder()),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final weight = double.tryParse(value ?? '');
                          return weight == null || weight <= 0
                              ? 'Enter weight'
                              : null;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _packages.length == 1
                          ? null
                          : () => setState(() {
                                _packages.removeAt(index).dispose();
                              }),
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Remove package',
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _packages.add(_PackageInput())),
            icon: const Icon(Icons.add),
            label: const Text('Add package'),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
              'Package count: ${_packages.length}   Total weight: ${_totalWeight.toStringAsFixed(2)} kg'),
        ),
      ],
    );
  }

  Widget _dimension(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) {
        final dimension = double.tryParse(value ?? '');
        return dimension == null || dimension <= 0 ? 'Required' : null;
      },
    );
  }

  Widget _shippingFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _shippingMethod,
          decoration: const InputDecoration(
              labelText: 'Shipping Method', border: OutlineInputBorder()),
          items: _shippingMethods
              .map((method) => DropdownMenuItem(
                  value: method, child: Text(method.toUpperCase())))
              .toList(),
          onChanged: (value) => setState(() => _shippingMethod = value!),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _hsCodeController,
          decoration: const InputDecoration(
              labelText: 'HS Code', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _additionalFields() {
    return Column(
      children: [
        TextFormField(
          controller: _merchantController,
          decoration: const InputDecoration(
              labelText: 'Merchant Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _goodsController,
          maxLines: 2,
          decoration: const InputDecoration(
              labelText: 'Goods Description', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _instructionsController,
          maxLines: 2,
          decoration: const InputDecoration(
              labelText: 'Special Instructions', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _submitButton() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submit,
        child: Text(_isEditing ? 'Save Changes' : 'Create Delivery'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final dimensions = _packages
          .map((package) => [
                package.length.text.trim(),
                package.width.text.trim(),
                package.height.text.trim(),
              ].join('x'))
          .join(', ');
      final delivery = widget.delivery;
      final success = delivery == null
          ? await _notifier.createDelivery({
              if (_recipientType == 'Person') 'recipient_person': _recipientId,
              if (_recipientType == 'Provider')
                'recipient_provider': _recipientId,
              'delivery_package_count': _packages.length,
              'delivery_total_weight': _totalWeight,
              'delivery_cargo_dimensions': dimensions,
              'delivery_shipping_method': _shippingMethod,
              'delivery_status': 'PENDING',
              if (_goodsController.text.trim().isNotEmpty)
                'delivery_goods_description': _goodsController.text.trim(),
              if (_merchantController.text.trim().isNotEmpty)
                'delivery_merchant_name': _merchantController.text.trim(),
              if (_instructionsController.text.trim().isNotEmpty)
                'delivery_special_instructions':
                    _instructionsController.text.trim(),
              if (_hsCodeController.text.trim().isNotEmpty)
                'hs_code': _hsCodeController.text.trim(),
              if (widget.providerId > 0)
                'delivery_provider_id': widget.providerId,
            })
          : await _notifier.updateDelivery(delivery.copyWith(
              recipient_person: _recipientType == 'Person' ? _recipientId : 0,
              recipient_provider:
                  _recipientType == 'Provider' ? _recipientId : 0,
              delivery_package_count: _packages.length,
              delivery_total_weight: _totalWeight,
              delivery_cargo_dimensions: dimensions,
              delivery_shipping_method: _shippingMethod,
              delivery_goods_description: _goodsController.text.trim(),
              delivery_merchant_name: _merchantController.text.trim(),
              delivery_special_instructions:
                  _instructionsController.text.trim(),
              hs_code: _hsCodeController.text.trim(),
            ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? (_isEditing ? 'Delivery updated' : 'Delivery created')
            : (_isEditing
                ? 'Failed to update delivery'
                : 'Failed to create delivery')),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _PackageInput {
  final length = TextEditingController();
  final width = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();

  _PackageInput({
    String length = '',
    String width = '',
    String height = '',
    double? weight,
  }) {
    this.length.text = length;
    this.width.text = width;
    this.height.text = height;
    if (weight != null) this.weight.text = weight.toString();
  }

  void dispose() {
    length.dispose();
    width.dispose();
    height.dispose();
    weight.dispose();
  }
}
