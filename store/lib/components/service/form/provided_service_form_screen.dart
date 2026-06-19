import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:store/components/service/form/ProductSelectorDialog.dart';
import 'package:ui/Services/ResponseHandler.dart';
import 'package:provider/provider.dart';

// ====================== DESIGN SYSTEM CONSTANTS ======================
class AppDesignSystem {
  static const double cardBorderRadius = 16.0;
  static const double inputBorderRadius = 12.0;
  static const double chipBorderRadius = 20.0;
  static const double sectionSpacing = 24.0;
  static const double elementSpacing = 12.0;
  static const double smallSpacing = 8.0;

  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );
  static const EdgeInsets sectionPadding = EdgeInsets.all(16.0);

  static const Duration expandDuration = Duration(milliseconds: 300);
  static const Curve expandCurve = Curves.easeInOut;
}

// ====================== REUSABLE COMPONENTS ======================
class FormSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final bool isCompleted;
  final bool isOptional;
  final VoidCallback onTap;
  final ColorScheme colors;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.isCompleted,
    required this.isOptional,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color iconColor;
    Color textColor;
    IconData headerIcon;

    if (isCompleted) {
      backgroundColor = colors.primaryContainer.withOpacity(0.15);
      iconColor = colors.primary;
      textColor = colors.primary;
      headerIcon = Icons.check_circle;
    } else if (isExpanded) {
      backgroundColor = colors.surfaceVariant;
      iconColor = colors.secondary;
      textColor = colors.onSurface;
      headerIcon = icon;
    } else {
      backgroundColor = colors.surfaceVariant.withOpacity(0.5);
      iconColor = colors.onSurfaceVariant;
      textColor = colors.onSurfaceVariant;
      headerIcon = icon;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDesignSystem.smallSpacing),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDesignSystem.cardBorderRadius),
        border: Border.all(
          color: isCompleted
              ? colors.primary.withOpacity(0.2)
              : colors.outline.withOpacity(0.1),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignSystem.cardBorderRadius),
          child: Padding(
            padding: AppDesignSystem.sectionPadding,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.primary.withOpacity(0.1)
                        : colors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    headerIcon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isOptional)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Optional',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Completed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.primary.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isExpanded ? 0 : -0.25,
                  duration: AppDesignSystem.expandDuration,
                  curve: AppDesignSystem.expandCurve,
                  child: Icon(
                    Icons.arrow_right,
                    size: 24,
                    color:
                        isCompleted ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormInputField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final int? maxLines;
  final bool isRequired;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;

  const FormInputField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
    this.maxLines = 1,
    this.isRequired = false,
    this.validator,
    this.onSaved,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
              if (isRequired)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius:
                BorderRadius.circular(AppDesignSystem.inputBorderRadius),
            border: Border.all(
              color: colors.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: AppDesignSystem.inputPadding,
              suffixText: suffixText,
              suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            validator: validator,
            onSaved: onSaved,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class FormPriceField extends StatelessWidget {
  final String label;
  final double? value;
  final bool isRequired;
  final Function(double) onSaved;

  const FormPriceField({
    super.key,
    required this.label,
    required this.value,
    required this.isRequired,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return FormInputField(
      label: label,
      initialValue:
          value != null && value! > 0 ? value!.toStringAsFixed(2) : '',
      hintText: '0.00',
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      isRequired: isRequired,
      suffixText: 'DZD',
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) {
          return 'This field is required';
        }
        if (val != null && val.isNotEmpty) {
          final parsed = double.tryParse(val);
          if (parsed == null || parsed < 0) {
            return 'Please enter a valid price';
          }
        }
        return null;
      },
      onSaved: (val) => onSaved(double.tryParse(val ?? '') ?? 0.0),
    );
  }
}

class FormCheckboxOption extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const FormCheckboxOption({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDesignSystem.inputBorderRadius),
        border: Border.all(
          color: value
              ? colors.primary.withOpacity(0.3)
              : colors.outline.withOpacity(0.2),
          width: value ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: value ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        activeColor: colors.primary,
        checkColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppDesignSystem.inputBorderRadius),
        ),
      ),
    );
  }
}

class FormChipInput extends StatefulWidget {
  final String label;
  final List<String> items;
  final Function(String) onAdd;
  final Function(int) onRemove;

  const FormChipInput({
    super.key,
    required this.label,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<FormChipInput> createState() => _FormChipInputState();
}

class _FormChipInputState extends State<FormChipInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.inputBorderRadius),
                  border: Border.all(
                    color: colors.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type and press enter...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onAdd(value.trim());
                      _controller.clear();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.inputBorderRadius),
              ),
              child: IconButton(
                onPressed: () {
                  final value = _controller.text.trim();
                  if (value.isNotEmpty) {
                    widget.onAdd(value);
                    _controller.clear();
                  }
                },
                icon: Icon(Icons.add, color: colors.onPrimary),
                splashRadius: 20,
              ),
            ),
          ],
        ),
        if (widget.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.chipBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => widget.onRemove(index),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: colors.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class RequirementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RequirementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDesignSystem.smallSpacing),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDesignSystem.inputBorderRadius),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, size: 20, color: colors.primary),
                splashRadius: 20,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, size: 20, color: colors.error),
                splashRadius: 20,
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDesignSystem.inputBorderRadius),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: AppDesignSystem.cardPadding,
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDesignSystem.cardBorderRadius),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: colors.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ====================== MAIN FORM SCREEN ======================
class ProvidedServiceFormScreen extends StatefulWidget {
  const ProvidedServiceFormScreen({super.key});

  @override
  State<ProvidedServiceFormScreen> createState() =>
      _ProvidedServiceFormScreenState();
}

class _ProvidedServiceFormScreenState extends State<ProvidedServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form data
  String _serviceName = '';
  String _serviceDescription = '';
  int _categoryId = 0;
  int _providerId = 0;
  double _basePrice = 0.0;
  double _finalPrice = 0.0;
  int _actualDuration = 0;

  final List<ServiceResourceRequirement> _resourceRequirements = [];
  final List<ServiceStaffRequirement> _staffRequirements = [];

  String _recommendedAge = '';
  String _recommendedFrequency = '';
  String _ageGroup = '';
  String _sampleType = '';
  bool _specialistConsultation = false;
  bool _governmentFunded = false;
  bool _consultationIncluded = false;
  bool _digitalImaging = false;
  List<String> _materialOptions = [];
  List<String> _includes = [];

  // State
  bool _updatePage = false;
  int _id = 0;
  bool _isActive = true;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool _initialized = false;

  // Section states
  bool _basicInfoExpanded = true;
  bool _pricingExpanded = true;
  bool _pricingConfigExpanded = false;
  bool _resourcesExpanded = false;
  bool _staffExpanded = false;
  bool _costSummaryExpanded = false;

  // Completion states
  bool _basicInfoCompleted = false;
  bool _pricingCompleted = false;
  bool _pricingConfigCompleted = false;
  bool _resourcesCompleted = false;
  bool _staffCompleted = false;
  bool _costSummaryCompleted = false;

  // Submission state
  bool _isSubmitting = false;
  String? _currentOperationKey;

  @override
  void initState() {
    super.initState();
    _log('Form initialized');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeForm();
      _initialized = true;
    }
  }

  void _initializeForm() {
    try {
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments;
      ProvidedService? service;

      if (args is Map<String, dynamic>) {
        service = args["service"] as ProvidedService?;
      }
      if (service != null) {
        _updatePage = true;
        _id = service.id;
        _serviceName = service.name;
        _serviceDescription = service.description;
        _categoryId = service.categoryId;
        _providerId = service.productProviderId;
        _basePrice = service.basePrice;
        _finalPrice = service.finalPrice;
        _actualDuration = service.actualDuration;
        _isActive = service.isActive;
        _createdAt = service.createdAt;
        _updatedAt = service.updatedAt;

        final config = service.pricingConfig;
        _recommendedAge = config.recommendedAge ?? '';
        _recommendedFrequency = config.recommendedFrequency ?? '';
        _ageGroup = config.ageGroup ?? '';
        _sampleType = config.sampleType ?? '';
        _specialistConsultation = config.specialistConsultation ?? false;
        _governmentFunded = config.governmentFunded ?? false;
        _consultationIncluded = config.consultationIncluded ?? false;
        _digitalImaging = config.digitalImaging ?? false;
        _materialOptions = config.materialOptions ?? [];
        _includes = config.includes ?? [];

        _resourceRequirements.addAll(service.resourceRequirements);
        _staffRequirements.addAll(service.staffRequirements);
      } else {
        _providerId = 0;
      }

      _updateCompletionStates();
      _log('Form data loaded successfully');
    } catch (e, stackTrace) {
      _logError('Error loading form data', e, stackTrace);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _log(String message) {
    developer.log('ProvidedServiceForm: $message', name: 'ProvidedServiceForm');
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    developer.log('ERROR: $message - $error',
        name: 'ProvidedServiceForm', error: error, stackTrace: stackTrace);
  }

  // Completion checking
  void _updateCompletionStates() {
    setState(() {
      _basicInfoCompleted = _serviceName.isNotEmpty &&
          _categoryId > 0 &&
          _providerId > 0 &&
          _actualDuration > 0;

      _pricingCompleted = _basePrice > 0 && _finalPrice > 0;

      _pricingConfigCompleted = _ageGroup.isNotEmpty ||
          _sampleType.isNotEmpty ||
          _specialistConsultation ||
          _governmentFunded ||
          _consultationIncluded ||
          _digitalImaging ||
          _materialOptions.isNotEmpty ||
          _includes.isNotEmpty;

      _resourcesCompleted = _resourceRequirements.isNotEmpty;
      _staffCompleted = _staffRequirements.isNotEmpty;
      _costSummaryCompleted = _finalPrice > 0 && _totalCost > 0;
    });
  }

  // Calculations
  double get _totalResourceCost {
    return _resourceRequirements.fold(
      0.0,
      (total, req) => total + (req.costPerUnit * req.quantity),
    );
  }

  double get _totalStaffCost {
    return _staffRequirements.fold(
      0.0,
      (total, req) =>
          total +
          (req.hourlyRate *
              req.allocatedHours *
              ((req.minCount + req.maxCount) / 2)),
    );
  }

  double get _totalCost => _totalResourceCost + _totalStaffCost;

  double get _profitMargin {
    if (_finalPrice <= 0) return 0;
    return ((_finalPrice - _totalCost) / _finalPrice * 100)
        .clamp(-100.0, 100.0);
  }

  double get _discountPercentage {
    if (_basePrice == 0) return 0;
    return ((_basePrice - _finalPrice) / _basePrice * 100);
  }

  // Form submission with ResponseHandler
  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isSubmitting = true);

      // Generate unique key for this operation
      _currentOperationKey = _updatePage
          ? 'update_service_${DateTime.now().millisecondsSinceEpoch}'
          : 'create_service_${DateTime.now().millisecondsSinceEpoch}';

      final pricingConfig = ProvidedServicePricingConfig(
        recommendedAge: _recommendedAge.isNotEmpty ? _recommendedAge : null,
        recommendedFrequency:
            _recommendedFrequency.isNotEmpty ? _recommendedFrequency : null,
        ageGroup: _ageGroup.isNotEmpty ? _ageGroup : null,
        sampleType: _sampleType.isNotEmpty ? _sampleType : null,
        specialistConsultation: _specialistConsultation,
        governmentFunded: _governmentFunded,
        consultationIncluded: _consultationIncluded,
        digitalImaging: _digitalImaging,
        materialOptions: _materialOptions.isNotEmpty ? _materialOptions : null,
        includes: _includes.isNotEmpty ? _includes : null,
      );

      final service = ProvidedService(
        id: _id,
        name: _serviceName,
        description: _serviceDescription,
        categoryId: _categoryId,
        productProviderId: _providerId,
        basePrice: _basePrice,
        finalPrice: _finalPrice,
        actualDuration: _actualDuration,
        pricingConfig: pricingConfig,
        isActive: _isActive,
        createdAt: _createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
        resourceRequirements: List.from(_resourceRequirements),
        staffRequirements: List.from(_staffRequirements),
      );

      try {
        final serviceNotifier =
            Provider.of<ServiceNotifier>(context, listen: false);

        bool success = false;

        if (_updatePage) {
          // Update existing service
          final updated = await serviceNotifier.updateService(
            service,
            callerKey: _currentOperationKey,
          );
          success = updated != null;
        } else {
          // Create new service
          final created = await serviceNotifier.addService(
            service,
            callerKey: _currentOperationKey,
          );
          success = created != null;
        }

        if (!mounted) return;

        if (success) {
          // Get the response from the notifier
          final response = serviceNotifier.getResponse(_currentOperationKey!);

          // Show success message using ResponseHandler
          ResponseHandler.handleResponse(
            context: context,
            statusCode: response?.statusCode ?? 200,
            responseCode: response?.responseCode ?? 'SUCCESS',
            finalMessage: _updatePage
                ? AppLocalizations.of(context)!.updateSuccess
                : AppLocalizations.of(context)!.putSuccess,
          );

          // Navigate back after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else {
          // Get the error response from the notifier
          final response = serviceNotifier.getResponse(_currentOperationKey!);

          ResponseHandler.handleResponse(
            context: context,
            statusCode: response?.statusCode ?? 500,
            responseCode: response?.responseCode ?? 'FAILED',
            finalMessage:
                response?.message ?? AppLocalizations.of(context)!.putFailure,
          );
        }
      } on GluttexException catch (e) {
        if (mounted) {
          ResponseHandler.handleResponse(
            context: context,
            statusCode: e.statusCode ?? 300,
            responseCode: e.message,
            finalMessage: e.message,
          );
        }
      } catch (e) {
        if (mounted) {
          ResponseHandler.handleResponse(
            context: context,
            statusCode: 500,
            responseCode: 'ERROR',
            finalMessage: 'Error: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void _setSubmitting(bool submitting) {
    if (mounted) {
      setState(() {
        _isSubmitting = submitting;
      });
    }
  }

  Widget _buildProgressSection() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final totalSections = 6;
    final completedSections = [
      _basicInfoCompleted,
      _pricingCompleted,
      _pricingConfigCompleted,
      _resourcesCompleted,
      _staffCompleted,
      _costSummaryCompleted,
    ].where((completed) => completed).length;
    final progress = completedSections / totalSections;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: ${(progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completedSections/$totalSections',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? colors.primary : colors.secondary,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: progress == 1.0
                    ? colors.primary
                    : colors.primary.withOpacity(0.7),
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.inputBorderRadius),
                ),
                elevation: 0,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          progress == 1.0 ? Icons.check_circle : Icons.save,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _updatePage ? 'Update Service' : 'Create Service',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: AppDesignSystem.cardPadding,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDesignSystem.cardBorderRadius),
      ),
      child: Column(
        children: [
          _buildCostRow(
            label: 'Resource Cost',
            value: _totalResourceCost,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppDesignSystem.smallSpacing),
          _buildCostRow(
            label: 'Staff Cost',
            value: _totalStaffCost,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppDesignSystem.smallSpacing),
          Divider(color: colors.outline.withOpacity(0.3)),
          const SizedBox(height: AppDesignSystem.smallSpacing),
          _buildCostRow(
            label: 'Total Cost',
            value: _totalCost,
            color: colors.onSurface,
            isBold: true,
          ),
          if (_finalPrice > 0) ...[
            const SizedBox(height: 16),
            _buildCostRow(
              label: 'Final Price',
              value: _finalPrice,
              color: colors.primary,
              isBold: true,
            ),
            const SizedBox(height: AppDesignSystem.smallSpacing),
            Container(
              padding: AppDesignSystem.cardPadding,
              decoration: BoxDecoration(
                color: _profitMargin >= 20
                    ? colors.primaryContainer.withOpacity(0.2)
                    : _profitMargin >= 10
                        ? colors.secondaryContainer.withOpacity(0.2)
                        : colors.errorContainer.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.inputBorderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profit Margin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${_profitMargin.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _profitMargin >= 20
                          ? colors.primary
                          : _profitMargin >= 10
                              ? colors.secondary
                              : colors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostRow({
    required String label,
    required double value,
    required Color color,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
        Text(
          'DZD ${value.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _updatePage ? 'Edit Service' : 'Create Service',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Basic Information
                    FormSectionHeader(
                      title: 'Basic Information',
                      icon: Icons.info_outline,
                      isExpanded: _basicInfoExpanded,
                      isCompleted: _basicInfoCompleted,
                      isOptional: false,
                      onTap: () => setState(
                        () => _basicInfoExpanded = !_basicInfoExpanded,
                      ),
                      colors: colors,
                    ),
                    if (_basicInfoExpanded) ...[
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      FormInputField(
                        label: 'Service Name',
                        initialValue: _serviceName,
                        hintText: 'Enter service name',
                        isRequired: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Service name is required';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _serviceName = val ?? '';
                          _updateCompletionStates();
                        },
                        onChanged: (_) => _updateCompletionStates(),
                      ),
                      const SizedBox(height: AppDesignSystem.smallSpacing),
                      FormInputField(
                        label: 'Description',
                        initialValue: _serviceDescription,
                        hintText: 'Enter description',
                        maxLines: 3,
                        onSaved: (val) {
                          _serviceDescription = val ?? '';
                          _updateCompletionStates();
                        },
                      ),
                      const SizedBox(height: AppDesignSystem.smallSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: FormInputField(
                              label: 'Category ID',
                              initialValue:
                                  _categoryId > 0 ? _categoryId.toString() : '',
                              hintText: 'Enter category ID',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSaved: (val) {
                                _categoryId = int.tryParse(val ?? '') ?? 0;
                                _updateCompletionStates();
                              },
                              onChanged: (_) => _updateCompletionStates(),
                            ),
                          ),
                          const SizedBox(width: AppDesignSystem.smallSpacing),
                          Expanded(
                            child: FormInputField(
                              label: 'Provider ID',
                              initialValue:
                                  _providerId > 0 ? _providerId.toString() : '',
                              hintText: 'Enter provider ID',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSaved: (val) {
                                _providerId = int.tryParse(val ?? '') ?? 0;
                                _updateCompletionStates();
                              },
                              onChanged: (_) => _updateCompletionStates(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignSystem.smallSpacing),
                      FormInputField(
                        label: 'Duration (minutes)',
                        initialValue: _actualDuration > 0
                            ? _actualDuration.toString()
                            : '',
                        hintText: 'Enter duration',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        suffixText: 'min',
                        onSaved: (val) {
                          _actualDuration = int.tryParse(val ?? '') ?? 0;
                          _updateCompletionStates();
                        },
                        onChanged: (_) => _updateCompletionStates(),
                      ),
                      const SizedBox(height: AppDesignSystem.sectionSpacing),
                    ],

                    // Pricing
                    FormSectionHeader(
                      title: 'Pricing',
                      icon: Icons.attach_money,
                      isExpanded: _pricingExpanded,
                      isCompleted: _pricingCompleted,
                      isOptional: false,
                      onTap: () => setState(
                        () => _pricingExpanded = !_pricingExpanded,
                      ),
                      colors: colors,
                    ),
                    if (_pricingExpanded) ...[
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      FormPriceField(
                        label: 'Base Price',
                        value: _basePrice,
                        isRequired: true,
                        onSaved: (val) {
                          _basePrice = val;
                          _updateCompletionStates();
                        },
                      ),
                      const SizedBox(height: AppDesignSystem.smallSpacing),
                      FormPriceField(
                        label: 'Final Price',
                        value: _finalPrice,
                        isRequired: true,
                        onSaved: (val) {
                          _finalPrice = val;
                          _updateCompletionStates();
                        },
                      ),
                      if (_basePrice > 0 && _finalPrice > 0) ...[
                        const SizedBox(height: AppDesignSystem.smallSpacing),
                        Container(
                          padding: AppDesignSystem.cardPadding,
                          decoration: BoxDecoration(
                            color: _discountPercentage > 0
                                ? colors.primaryContainer.withOpacity(0.15)
                                : colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                                AppDesignSystem.inputBorderRadius),
                            border: Border.all(
                              color: _discountPercentage > 0
                                  ? colors.primary.withOpacity(0.2)
                                  : colors.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _discountPercentage > 0
                                    ? Icons.discount
                                    : Icons.price_check,
                                color: _discountPercentage > 0
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _discountPercentage > 0
                                      ? '${_discountPercentage.toStringAsFixed(1)}% discount applied'
                                      : 'No discount',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _discountPercentage > 0
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDesignSystem.sectionSpacing),
                    ],

                    // Pricing Configuration
                    FormSectionHeader(
                      title: 'Pricing Configuration',
                      icon: Icons.settings,
                      isExpanded: _pricingConfigExpanded,
                      isCompleted: _pricingConfigCompleted,
                      isOptional: true,
                      onTap: () => setState(
                        () => _pricingConfigExpanded = !_pricingConfigExpanded,
                      ),
                      colors: colors,
                    ),
                    if (_pricingConfigExpanded) ...[
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: FormInputField(
                              label: 'Age Group',
                              initialValue: _ageGroup,
                              hintText: 'Enter age group',
                              onSaved: (val) {
                                _ageGroup = val ?? '';
                                _updateCompletionStates();
                              },
                            ),
                          ),
                          const SizedBox(width: AppDesignSystem.smallSpacing),
                          Expanded(
                            child: FormInputField(
                              label: 'Sample Type',
                              initialValue: _sampleType,
                              hintText: 'Enter sample type',
                              onSaved: (val) {
                                _sampleType = val ?? '';
                                _updateCompletionStates();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      Column(
                        children: [
                          FormCheckboxOption(
                            label: 'Specialist Consultation',
                            value: _specialistConsultation,
                            onChanged: (val) {
                              setState(
                                  () => _specialistConsultation = val ?? false);
                              _updateCompletionStates();
                            },
                          ),
                          const SizedBox(height: AppDesignSystem.smallSpacing),
                          FormCheckboxOption(
                            label: 'Government Funded',
                            value: _governmentFunded,
                            onChanged: (val) {
                              setState(() => _governmentFunded = val ?? false);
                              _updateCompletionStates();
                            },
                          ),
                          const SizedBox(height: AppDesignSystem.smallSpacing),
                          FormCheckboxOption(
                            label: 'Consultation Included',
                            value: _consultationIncluded,
                            onChanged: (val) {
                              setState(
                                  () => _consultationIncluded = val ?? false);
                              _updateCompletionStates();
                            },
                          ),
                          const SizedBox(height: AppDesignSystem.smallSpacing),
                          FormCheckboxOption(
                            label: 'Digital Imaging',
                            value: _digitalImaging,
                            onChanged: (val) {
                              setState(() => _digitalImaging = val ?? false);
                              _updateCompletionStates();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      FormChipInput(
                        label: 'Material Options',
                        items: _materialOptions,
                        onAdd: (material) {
                          if (!_materialOptions.contains(material)) {
                            setState(() => _materialOptions.add(material));
                            _updateCompletionStates();
                          }
                        },
                        onRemove: (index) {
                          setState(() => _materialOptions.removeAt(index));
                          _updateCompletionStates();
                        },
                      ),
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      FormChipInput(
                        label: 'Includes',
                        items: _includes,
                        onAdd: (include) {
                          if (!_includes.contains(include)) {
                            setState(() => _includes.add(include));
                            _updateCompletionStates();
                          }
                        },
                        onRemove: (index) {
                          setState(() => _includes.removeAt(index));
                          _updateCompletionStates();
                        },
                      ),
                      const SizedBox(height: AppDesignSystem.sectionSpacing),
                    ],

                    // Resource Requirements
                    FormSectionHeader(
                      title: 'Resource Requirements',
                      icon: Icons.inventory,
                      isExpanded: _resourcesExpanded,
                      isCompleted: _resourcesCompleted,
                      isOptional: false,
                      onTap: () => setState(
                        () => _resourcesExpanded = !_resourcesExpanded,
                      ),
                      colors: colors,
                    ),
                    if (_resourcesExpanded) ...[
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      if (_resourceRequirements.isEmpty)
                        EmptyState(
                          message: 'No resources added yet',
                          icon: Icons.inventory_2_outlined,
                        )
                      else
                        ..._resourceRequirements.asMap().entries.map((entry) {
                          final index = entry.key;
                          final req = entry.value;
                          return RequirementCard(
                            title: req.name,
                            subtitle:
                                '${req.quantity} × DZD ${req.costPerUnit.toStringAsFixed(2)} = DZD ${(req.costPerUnit * req.quantity).toStringAsFixed(2)}',
                            onEdit: () => _showResourceDialog(
                              existing: req,
                              index: index,
                            ),
                            onDelete: () => setState(() {
                              _resourceRequirements.removeAt(index);
                              _updateCompletionStates();
                            }),
                          );
                        }).toList(),
                      const SizedBox(height: AppDesignSystem.smallSpacing),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton.small(
                          onPressed: () => _showResourceDialog(),
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDesignSystem.inputBorderRadius),
                          ),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.sectionSpacing),
                    ],

                    // Staff Requirements
                    FormSectionHeader(
                      title: 'Staff Requirements',
                      icon: Icons.people,
                      isExpanded: _staffExpanded,
                      isCompleted: _staffCompleted,
                      isOptional: false,
                      onTap: () => setState(
                        () => _staffExpanded = !_staffExpanded,
                      ),
                      colors: colors,
                    ),
                    if (_staffExpanded) ...[
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      if (_staffRequirements.isEmpty)
                        EmptyState(
                          message: 'No staff added yet',
                          icon: Icons.people_outline,
                        )
                      else
                        ..._staffRequirements.asMap().entries.map((entry) {
                          final index = entry.key;
                          final req = entry.value;
                          return RequirementCard(
                            title:
                                '${req.role} (${req.minCount}-${req.maxCount})',
                            subtitle:
                                '${req.allocatedHours}h × DZD ${req.hourlyRate.toStringAsFixed(2)}/h ≈ DZD ${(req.hourlyRate * req.allocatedHours * ((req.minCount + req.maxCount) / 2)).toStringAsFixed(2)}',
                            onEdit: () => _showStaffDialog(
                              existing: req,
                              index: index,
                            ),
                            onDelete: () => setState(() {
                              _staffRequirements.removeAt(index);
                              _updateCompletionStates();
                            }),
                          );
                        }).toList(),
                      const SizedBox(height: AppDesignSystem.smallSpacing),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton.small(
                          onPressed: () => _showStaffDialog(),
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDesignSystem.inputBorderRadius),
                          ),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.sectionSpacing),
                    ],

                    // Cost Summary
                    FormSectionHeader(
                      title: 'Cost Summary',
                      icon: Icons.calculate,
                      isExpanded: _costSummaryExpanded,
                      isCompleted: _costSummaryCompleted,
                      isOptional: false,
                      onTap: () => setState(
                        () => _costSummaryExpanded = !_costSummaryExpanded,
                      ),
                      colors: colors,
                    ),
                    if (_costSummaryExpanded) ...[
                      const SizedBox(height: AppDesignSystem.elementSpacing),
                      _buildCostSummary(),
                      const SizedBox(height: AppDesignSystem.sectionSpacing),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Progress and Save Button
          _buildProgressSection(),
        ],
      ),
    );
  }

  void _showResourceDialog({ServiceResourceRequirement? existing, int? index}) {
    final isEditing = existing != null;
    final _formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existing?.name ?? '');
    final typeController = TextEditingController(text: existing?.type ?? '');
    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '1',
    );
    final costPerUnitController = TextEditingController(
      text: existing?.costPerUnit.toStringAsFixed(2) ?? '0.00',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    bool isConsumable = existing?.isConsumable ?? false;
    int? productRef = existing?.productRef;
    String? selectedProductName;

    if (productRef != null && productRef > 0) {
      try {
        final productNotifier =
            Provider.of<ProductNotifier>(context, listen: false);
        final product = productNotifier.getProductByIdSync(productRef);
        if (product != null) {
          selectedProductName = product.product_name;
        }
      } catch (e) {}
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing
                  ? 'Edit Resource Requirement'
                  : 'Add Resource Requirement'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Resource Name',
                          hintText: 'e.g., Equipment, Materials, Supplies',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a resource name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: typeController,
                        decoration: const InputDecoration(
                          labelText: 'Resource Type',
                          hintText: 'e.g., Equipment, Consumable, Software',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a resource type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final selectedProduct =
                              await ProductSelectorDialog.show(
                            context,
                            supplierId: _providerId > 0 ? _providerId : null,
                            selectedProductId: productRef,
                          );

                          if (selectedProduct != null && mounted) {
                            setStateDialog(() {
                              productRef = selectedProduct.id_product;
                              selectedProductName =
                                  selectedProduct.product_name;
                              if (nameController.text.isEmpty) {
                                nameController.text =
                                    selectedProduct.product_name ?? '';
                              }
                              if (costPerUnitController.text.isEmpty ||
                                  costPerUnitController.text == '0.00') {
                                costPerUnitController.text =
                                    (selectedProduct.product_price ?? 0)
                                        .toStringAsFixed(2);
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product Reference',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      selectedProductName ??
                                          (productRef != null &&
                                                  (productRef ?? 0) > 0
                                              ? 'Product ID: $productRef'
                                              : 'Select a product (optional)'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: selectedProductName != null
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.6),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Number of units needed',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          final qty = double.tryParse(value);
                          if (qty == null || qty < 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: costPerUnitController,
                        decoration: const InputDecoration(
                          labelText: 'Cost Per Unit',
                          hintText: 'Cost per unit',
                          border: OutlineInputBorder(),
                          prefixText: 'DZD ',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d*$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cost per unit';
                          }
                          final cost = double.tryParse(value);
                          if (cost == null || cost < 0) {
                            return 'Please enter a valid cost';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Is Consumable'),
                        value: isConsumable,
                        onChanged: (value) {
                          setStateDialog(() {
                            isConsumable = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Any additional notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      if (quantityController.text.isNotEmpty &&
                          costPerUnitController.text.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Cost:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'DZD ${(double.tryParse(quantityController.text) ?? 0) * (double.tryParse(costPerUnitController.text) ?? 0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final resourceRequirement = ServiceResourceRequirement(
                        id: existing?.id ?? 0,
                        name: nameController.text,
                        type: typeController.text,
                        quantity: double.parse(quantityController.text),
                        isConsumable: isConsumable,
                        productRef: productRef,
                        serviceId: _id,
                        costPerUnit: double.parse(costPerUnitController.text),
                        notes: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      setState(() {
                        if (isEditing && index != null) {
                          _resourceRequirements[index] = resourceRequirement;
                        } else {
                          _resourceRequirements.add(resourceRequirement);
                        }
                        _updateCompletionStates();
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStaffDialog({ServiceStaffRequirement? existing, int? index}) {
    final isEditing = existing != null;
    final _formKey = GlobalKey<FormState>();

    // Controllers for form fields
    final roleController = TextEditingController(text: existing?.role ?? '');
    final minCountController = TextEditingController(
      text: existing?.minCount.toString() ?? '1',
    );
    final maxCountController = TextEditingController(
      text: existing?.maxCount.toString() ?? '1',
    );
    final allocatedHoursController = TextEditingController(
      text: existing?.allocatedHours.toString() ?? '1.0',
    );
    final hourlyRateController = TextEditingController(
      text: existing?.hourlyRate.toStringAsFixed(2) ?? '0.00',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isEditing ? 'Edit Staff Requirement' : 'Add Staff Requirement'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role
                  TextFormField(
                    controller: roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      hintText: 'e.g., Technician, Nurse, Doctor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Min Count
                  TextFormField(
                    controller: minCountController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Staff Count',
                      hintText: 'Minimum number of staff needed',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter minimum count';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Max Count
                  TextFormField(
                    controller: maxCountController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Staff Count',
                      hintText: 'Maximum number of staff needed',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter maximum count';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 0) {
                        return 'Please enter a valid number';
                      }
                      final min = int.tryParse(minCountController.text) ?? 0;
                      if (count < min) {
                        return 'Maximum must be greater than or equal to minimum';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Allocated Hours
                  TextFormField(
                    controller: allocatedHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Allocated Hours',
                      hintText: 'Hours allocated per staff member',
                      border: OutlineInputBorder(),
                      suffixText: 'hours',
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter allocated hours';
                      }
                      final hours = double.tryParse(value);
                      if (hours == null || hours < 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Hourly Rate
                  TextFormField(
                    controller: hourlyRateController,
                    decoration: const InputDecoration(
                      labelText: 'Hourly Rate',
                      hintText: 'Rate per hour',
                      border: OutlineInputBorder(),
                      prefixText: 'DZD ',
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hourly rate';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0) {
                        return 'Please enter a valid rate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Notes (optional)
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Any additional notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  // Preview cost calculation
                  if (minCountController.text.isNotEmpty &&
                      maxCountController.text.isNotEmpty &&
                      allocatedHoursController.text.isNotEmpty &&
                      hourlyRateController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Min Cost:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'DZD ${_calculateStaffCost(
                                  int.tryParse(minCountController.text) ?? 0,
                                  double.tryParse(
                                          allocatedHoursController.text) ??
                                      0,
                                  double.tryParse(hourlyRateController.text) ??
                                      0,
                                ).toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Max Cost:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'DZD ${_calculateStaffCost(
                                  int.tryParse(maxCountController.text) ?? 0,
                                  double.tryParse(
                                          allocatedHoursController.text) ??
                                      0,
                                  double.tryParse(hourlyRateController.text) ??
                                      0,
                                ).toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Average Cost:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'DZD ${_calculateStaffCost(
                                  ((int.tryParse(minCountController.text) ??
                                              0) +
                                          (int.tryParse(
                                                  maxCountController.text) ??
                                              0)) ~/
                                      2,
                                  double.tryParse(
                                          allocatedHoursController.text) ??
                                      0,
                                  double.tryParse(hourlyRateController.text) ??
                                      0,
                                ).toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final staffRequirement = ServiceStaffRequirement(
                    id: existing?.id ?? 0,
                    serviceId: _id, // Current service ID
                    minCount: int.parse(minCountController.text),
                    maxCount: int.parse(maxCountController.text),
                    role: roleController.text,
                    allocatedHours: double.parse(allocatedHoursController.text),
                    hourlyRate: double.parse(hourlyRateController.text),
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                    createdAt: existing?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  setState(() {
                    if (isEditing && index != null) {
                      _staffRequirements[index] = staffRequirement;
                    } else {
                      _staffRequirements.add(staffRequirement);
                    }
                    _updateCompletionStates();
                  });

                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  double _calculateStaffCost(int count, double hours, double rate) {
    return hours * rate * count;
  }
}
