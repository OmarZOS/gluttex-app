import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:provider/provider.dart';

class ProvidedServiceFormScreen extends StatefulWidget {
  const ProvidedServiceFormScreen({super.key});

  @override
  State<ProvidedServiceFormScreen> createState() =>
      _ProvidedServiceFormScreenState();
}

class _ProvidedServiceFormScreenState extends State<ProvidedServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Basic Information
  String _serviceName = '';
  String _serviceDescription = '';
  int _categoryId = 0;
  int _providerId = 0;

  // Pricing
  double _basePrice = 0.0;
  double _finalPrice = 0.0;
  int _actualDuration = 0; // in minutes

  // Requirements
  final List<ServiceResourceRequirement> _resourceRequirements = [];
  final List<ServiceStaffRequirement> _staffRequirements = [];

  // Pricing Config
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

  // Controllers
  final TextEditingController _staffRoleController = TextEditingController();
  final TextEditingController _staffMinCountController =
      TextEditingController(text: '1');
  final TextEditingController _staffMaxCountController =
      TextEditingController(text: '1');
  final TextEditingController _staffHoursController =
      TextEditingController(text: '1.0');
  final TextEditingController _staffRateController =
      TextEditingController(text: '0.0');
  final TextEditingController _staffNotesController = TextEditingController();
  final TextEditingController _resourceNameController = TextEditingController();
  final TextEditingController _resourceTypeController = TextEditingController();
  final TextEditingController _resourceQuantityController =
      TextEditingController(text: '1.0');
  final TextEditingController _resourceCostController =
      TextEditingController(text: '0.0');
  final TextEditingController _resourceNotesController =
      TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _includesController = TextEditingController();

  bool _resourceIsConsumable = true;
  int? _resourceProductRef;

  // Section expansion states
  bool _basicInfoExpanded = true;
  bool _pricingExpanded = true;
  bool _pricingConfigExpanded = false;
  bool _resourcesExpanded = false;
  bool _staffExpanded = false;
  bool _costSummaryExpanded = false;

  @override
  void initState() {
    super.initState();
    _log('initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      try {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final ProvidedService? service = args?["service"];

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

        _initialized = true;
        _log('Form initialized successfully');
      } catch (e, stackTrace) {
        _logError('Error in didChangeDependencies', e, stackTrace);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _staffRoleController.dispose();
    _staffMinCountController.dispose();
    _staffMaxCountController.dispose();
    _staffHoursController.dispose();
    _staffRateController.dispose();
    _staffNotesController.dispose();
    _resourceNameController.dispose();
    _resourceTypeController.dispose();
    _resourceQuantityController.dispose();
    _resourceCostController.dispose();
    _resourceNotesController.dispose();
    _materialController.dispose();
    _includesController.dispose();
    super.dispose();
  }

  void _log(String message) {
    developer.log('ProvidedServiceForm: $message', name: 'ProvidedServiceForm');
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    developer.log('ProvidedServiceForm ERROR: $message - $error',
        name: 'ProvidedServiceForm', error: error, stackTrace: stackTrace);
  }

  // UI Helper Methods
  Widget _buildSectionHeader({
    required AppLocalizations loc,
    required String titleKey,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isExpanded ? colors.primaryContainer : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isExpanded ? colors.primary : colors.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 20,
              color: isExpanded ? colors.onPrimary : colors.onSurfaceVariant),
        ),
        title: Text(
          _getLocalizedText(loc, titleKey, titleKey),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isExpanded ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: isExpanded ? colors.primary : colors.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required AppLocalizations loc,
    required String labelKey,
    required String? initialValue,
    required Function(String?) onSaved,
    String? hintTextKey,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    int? maxLines,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelKey.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              children: [
                Text(
                  _getLocalizedText(loc, labelKey, labelKey),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              hintText: hintTextKey != null
                  ? _getLocalizedText(loc, hintTextKey, hintTextKey)
                  : null,
              hintStyle:
                  TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixText: suffixText,
              suffixStyle: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            onSaved: onSaved,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required AppLocalizations loc,
    required String labelKey,
    required double? value,
    required Function(double) onSaved,
    bool isRequired = false,
  }) {
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
                _getLocalizedText(loc, labelKey, labelKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue:
                value != null && value > 0 ? value.toStringAsFixed(2) : '',
            decoration: InputDecoration(
              hintText: _getLocalizedText(loc, 'enterPriceHint', '0.00'),
              hintStyle:
                  TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixText: 'DZD',
              suffixStyle: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (val) {
              if (isRequired && (val == null || val.isEmpty)) {
                return _getLocalizedText(
                    loc, 'priceRequired', 'This field is required');
              }
              if (val != null && val.isNotEmpty) {
                final parsed = double.tryParse(val);
                if (parsed == null || parsed < 0) {
                  return _getLocalizedText(
                      loc, 'invalidPrice', 'Please enter a valid price');
                }
              }
              return null;
            },
            onSaved: (val) {
              onSaved(double.tryParse(val ?? '') ?? 0.0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption({
    required AppLocalizations loc,
    required String labelKey,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(
          _getLocalizedText(loc, labelKey, labelKey),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
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
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildChipInput({
    required AppLocalizations loc,
    required String labelKey,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> items,
    required Function(int) onRemove,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedText(loc, labelKey, labelKey),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: _getLocalizedText(
                        loc, 'typeAndPressEnter', 'Type and press enter...'),
                    hintStyle: TextStyle(
                        color: colors.onSurfaceVariant.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onAdd,
                icon: Icon(Icons.add, color: colors.onPrimary),
                splashRadius: 20,
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return InputChip(
                label: Text(item),
                onDeleted: () => onRemove(index),
                deleteIconColor: colors.error,
                backgroundColor: colors.primaryContainer,
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRequirementCard({
    required AppLocalizations loc,
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.2),
        ),
      ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required AppLocalizations loc,
    required String messageKey,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: colors.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            _getLocalizedText(loc, messageKey, messageKey),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required AppLocalizations loc,
    required String tooltipKey,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colors = Theme.of(context).colorScheme;

    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20),
      tooltip: _getLocalizedText(loc, tooltipKey, tooltipKey),
    );
  }

  Widget _buildSaveButton({required AppLocalizations loc}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline.withOpacity(0.1)),
        ),
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 20),
            const SizedBox(width: 8),
            Text(
              _updatePage
                  ? _getLocalizedText(loc, 'updateService', 'Update Service')
                  : _getLocalizedText(loc, 'createService', 'Create Service'),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get localized text with fallback
  String _getLocalizedText(AppLocalizations loc, String key, String fallback) {
    try {
      switch (key) {
        case 'basicInformation':
          return loc.basicInformation ?? fallback;
        case 'serviceName':
          return loc.serviceName ?? fallback;
        case 'enterServiceName':
          return loc.enterServiceName ?? fallback;
        case 'serviceNameRequired':
          return loc.serviceNameRequired ?? fallback;
        case 'description':
          return loc.description ?? fallback;
        case 'enterDescription':
          return loc.enterDescription ?? fallback;
        case 'categoryId':
          return loc.categoryId ?? fallback;
        case 'enterCategoryId':
          return loc.enterCategoryId ?? fallback;
        case 'providerId':
          return loc.providerId ?? fallback;
        case 'enterProviderId':
          return loc.enterProviderId ?? fallback;
        case 'durationMinutes':
          return loc.durationMinutes ?? fallback;
        case 'enterDuration':
          return loc.enterDuration ?? fallback;
        case 'pricing':
          return loc.pricing ?? fallback;
        case 'basePrice':
          return loc.basePrice ?? fallback;
        case 'finalPrice':
          return loc.finalPrice ?? fallback;
        case 'enterPriceHint':
          return loc.enterPrice ?? fallback;
        case 'priceRequired':
          return loc.priceRequired ?? fallback;
        case 'invalidPrice':
          return loc.invalidPrice ?? fallback;
        case 'pricingConfiguration':
          return loc.pricingConfiguration ?? fallback;
        case 'ageGroup':
          return loc.ageGroup ?? fallback;
        case 'enterAgeGroup':
          return loc.enterAgeGroup ?? fallback;
        case 'sampleType':
          return loc.sampleType ?? fallback;
        case 'enterSampleType':
          return loc.enterSampleType ?? fallback;
        case 'specialistConsultation':
          return loc.specialistConsultation ?? fallback;
        case 'governmentFunded':
          return loc.governmentFunded ?? fallback;
        case 'consultationIncluded':
          return loc.consultationIncluded ?? fallback;
        case 'digitalImaging':
          return loc.digitalImaging ?? fallback;
        case 'materialOptions':
          return loc.materialOptions ?? fallback;
        case 'includes':
          return loc.includes ?? fallback;
        case 'typeAndPressEnter':
          return loc.typeAndPressEnter ?? fallback;
        case 'resourceRequirements':
          return loc.resourceRequirements ?? fallback;
        case 'noResourcesAdded':
          return loc.noResourcesAdded ?? fallback;
        case 'addResource':
          return loc.addResource ?? fallback;
        case 'staffRequirements':
          return loc.staffRequirements ?? fallback;
        case 'noStaffAdded':
          return loc.noStaffAdded ?? fallback;
        case 'addStaff':
          return loc.addStaff ?? fallback;
        case 'costSummary':
          return loc.costSummary ?? fallback;
        case 'updateService':
          return loc.updateService ?? fallback;
        case 'createService':
          return loc.createService ?? fallback;
        case 'editService':
          return loc.editService ?? fallback;
        case 'resourceCost':
          return loc.resourceCost ?? fallback;
        case 'staffCost':
          return loc.staffCost ?? fallback;
        case 'totalCost':
          return loc.totalCost ?? fallback;
        case 'finalPriceLabel':
          return loc.finalPriceLabel ?? fallback;
        case 'profitMargin':
          return loc.profitMargin ?? fallback;
        default:
          return fallback;
      }
    } catch (e) {
      return fallback;
    }
  }

  // Dialog Methods (simplified for brevity)
  void _showStaffRequirementDialog({
    required AppLocalizations loc,
    ServiceStaffRequirement? existing,
    int? index,
  }) {
    // Implementation for staff requirement dialog
    // Would use localization keys: 'addStaffRequirement', 'editStaffRequirement', etc.
  }

  void _showResourceRequirementDialog({
    required AppLocalizations loc,
    ServiceResourceRequirement? existing,
    int? index,
  }) {
    // Implementation for resource requirement dialog
    // Would use localization keys: 'addResourceRequirement', 'editResourceRequirement', etc.
  }

  // Calculation Methods
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
    if (_finalPrice == 0) return 0;
    return ((_finalPrice - _totalCost) / _finalPrice * 100);
  }

  double get _discountPercentage {
    if (_basePrice == 0) return 0;
    return ((_basePrice - _finalPrice) / _basePrice * 100);
  }

  // Form Submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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
        id: _id, // 0 for new services, existing ID for updates
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

      // TODO: Save service
      Navigator.pop(context, service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _updatePage
              ? _getLocalizedText(loc, 'editService', 'Edit Service')
              : _getLocalizedText(loc, 'createService', 'Create Service'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        actions: [
          IconButton(
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            icon: Icon(Icons.arrow_upward, color: colors.primary),
            tooltip: _getLocalizedText(loc, 'scrollToTop', 'Scroll to top'),
          ),
        ],
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
                    // Basic Information Section
                    _buildSectionHeader(
                      loc: loc,
                      titleKey: 'basicInformation',
                      icon: Icons.info_outline,
                      isExpanded: _basicInfoExpanded,
                      onTap: () => setState(
                          () => _basicInfoExpanded = !_basicInfoExpanded),
                    ),
                    if (_basicInfoExpanded) ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        loc: loc,
                        labelKey: 'serviceName',
                        initialValue: _serviceName,
                        isRequired: true,
                        hintTextKey: 'enterServiceName',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return _getLocalizedText(loc, 'serviceNameRequired',
                                'Service name is required');
                          }
                          return null;
                        },
                        onSaved: (val) => _serviceName = val ?? '',
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        loc: loc,
                        labelKey: 'description',
                        initialValue: _serviceDescription,
                        hintTextKey: 'enterDescription',
                        maxLines: 3,
                        onSaved: (val) => _serviceDescription = val ?? '',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              loc: loc,
                              labelKey: 'categoryId',
                              initialValue:
                                  _categoryId > 0 ? _categoryId.toString() : '',
                              hintTextKey: 'enterCategoryId',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onSaved: (val) =>
                                  _categoryId = int.tryParse(val ?? '') ?? 0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              loc: loc,
                              labelKey: 'providerId',
                              initialValue:
                                  _providerId > 0 ? _providerId.toString() : '',
                              hintTextKey: 'enterProviderId',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onSaved: (val) =>
                                  _providerId = int.tryParse(val ?? '') ?? 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        loc: loc,
                        labelKey: 'durationMinutes',
                        initialValue: _actualDuration > 0
                            ? _actualDuration.toString()
                            : '',
                        hintTextKey: 'enterDuration',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        suffixText: _getLocalizedText(loc, 'minutes', 'min'),
                        onSaved: (val) =>
                            _actualDuration = int.tryParse(val ?? '') ?? 0,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Pricing Section
                    _buildSectionHeader(
                      loc: loc,
                      titleKey: 'pricing',
                      icon: Icons.attach_money,
                      isExpanded: _pricingExpanded,
                      onTap: () =>
                          setState(() => _pricingExpanded = !_pricingExpanded),
                    ),
                    if (_pricingExpanded) ...[
                      const SizedBox(height: 16),
                      _buildPriceField(
                        loc: loc,
                        labelKey: 'basePrice',
                        value: _basePrice,
                        onSaved: (val) => _basePrice = val,
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),
                      _buildPriceField(
                        loc: loc,
                        labelKey: 'finalPrice',
                        value: _finalPrice,
                        onSaved: (val) => _finalPrice = val,
                        isRequired: true,
                      ),
                      if (_basePrice > 0 && _finalPrice > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _discountPercentage > 0
                                ? colors.primaryContainer.withOpacity(0.2)
                                : colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _discountPercentage > 0
                                  ? colors.primary.withOpacity(0.3)
                                  : colors.outline.withOpacity(0.3),
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _discountPercentage > 0
                                      ? '${_discountPercentage.toStringAsFixed(1)}% ${_getLocalizedText(loc, 'discountApplied', 'discount applied')}'
                                      : _getLocalizedText(
                                          loc, 'noDiscount', 'No discount'),
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
                      const SizedBox(height: 24),
                    ],

                    // Pricing Configuration Section
                    _buildSectionHeader(
                      loc: loc,
                      titleKey: 'pricingConfiguration',
                      icon: Icons.settings,
                      isExpanded: _pricingConfigExpanded,
                      onTap: () => setState(() =>
                          _pricingConfigExpanded = !_pricingConfigExpanded),
                    ),
                    if (_pricingConfigExpanded) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              loc: loc,
                              labelKey: 'ageGroup',
                              initialValue: _ageGroup,
                              hintTextKey: 'enterAgeGroup',
                              onSaved: (val) => _ageGroup = val ?? '',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              loc: loc,
                              labelKey: 'sampleType',
                              initialValue: _sampleType,
                              hintTextKey: 'enterSampleType',
                              onSaved: (val) => _sampleType = val ?? '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildCheckboxOption(
                            loc: loc,
                            labelKey: 'specialistConsultation',
                            value: _specialistConsultation,
                            onChanged: (val) => setState(
                                () => _specialistConsultation = val ?? false),
                          ),
                          const SizedBox(height: 8),
                          _buildCheckboxOption(
                            loc: loc,
                            labelKey: 'governmentFunded',
                            value: _governmentFunded,
                            onChanged: (val) => setState(
                                () => _governmentFunded = val ?? false),
                          ),
                          const SizedBox(height: 8),
                          _buildCheckboxOption(
                            loc: loc,
                            labelKey: 'consultationIncluded',
                            value: _consultationIncluded,
                            onChanged: (val) => setState(
                                () => _consultationIncluded = val ?? false),
                          ),
                          const SizedBox(height: 8),
                          _buildCheckboxOption(
                            loc: loc,
                            labelKey: 'digitalImaging',
                            value: _digitalImaging,
                            onChanged: (val) =>
                                setState(() => _digitalImaging = val ?? false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChipInput(
                        loc: loc,
                        labelKey: 'materialOptions',
                        controller: _materialController,
                        onAdd: _addMaterialOption,
                        items: _materialOptions,
                        onRemove: _removeMaterialOption,
                      ),
                      const SizedBox(height: 16),
                      _buildChipInput(
                        loc: loc,
                        labelKey: 'includes',
                        controller: _includesController,
                        onAdd: _addInclude,
                        items: _includes,
                        onRemove: _removeInclude,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Resource Requirements Section
                    _buildSectionHeader(
                      loc: loc,
                      titleKey: 'resourceRequirements',
                      icon: Icons.inventory,
                      isExpanded: _resourcesExpanded,
                      onTap: () => setState(
                          () => _resourcesExpanded = !_resourcesExpanded),
                    ),
                    if (_resourcesExpanded) ...[
                      const SizedBox(height: 16),
                      if (_resourceRequirements.isEmpty)
                        _buildEmptyState(
                          loc: loc,
                          messageKey: 'noResourcesAdded',
                          icon: Icons.inventory_2_outlined,
                        )
                      else
                        ..._resourceRequirements.asMap().entries.map((entry) {
                          final index = entry.key;
                          final req = entry.value;
                          return _buildRequirementCard(
                            loc: loc,
                            title: req.name,
                            subtitle:
                                '${req.quantity} × DZD ${req.costPerUnit.toStringAsFixed(2)} = DZD ${req.totalCost.toStringAsFixed(2)}',
                            onEdit: () => _showResourceRequirementDialog(
                              loc: loc,
                              existing: req,
                              index: index,
                            ),
                            onDelete: () => setState(() {
                              _resourceRequirements.removeAt(index);
                            }),
                          );
                        }).toList(),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildFloatingActionButton(
                          loc: loc,
                          icon: Icons.add,
                          tooltipKey: 'addResource',
                          onPressed: () =>
                              _showResourceRequirementDialog(loc: loc),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Staff Requirements Section
                    _buildSectionHeader(
                      loc: loc,
                      titleKey: 'staffRequirements',
                      icon: Icons.people,
                      isExpanded: _staffExpanded,
                      onTap: () =>
                          setState(() => _staffExpanded = !_staffExpanded),
                    ),
                    if (_staffExpanded) ...[
                      const SizedBox(height: 16),
                      if (_staffRequirements.isEmpty)
                        _buildEmptyState(
                          loc: loc,
                          messageKey: 'noStaffAdded',
                          icon: Icons.people_outline,
                        )
                      else
                        ..._staffRequirements.asMap().entries.map((entry) {
                          final index = entry.key;
                          final req = entry.value;
                          return _buildRequirementCard(
                            loc: loc,
                            title:
                                '${req.role} (${req.minCount}-${req.maxCount})',
                            subtitle:
                                '${req.allocatedHours}h × DZD ${req.hourlyRate.toStringAsFixed(2)}/h ≈ DZD ${req.averageCost.toStringAsFixed(2)}',
                            onEdit: () => _showStaffRequirementDialog(
                              loc: loc,
                              existing: req,
                              index: index,
                            ),
                            onDelete: () => setState(() {
                              _staffRequirements.removeAt(index);
                            }),
                          );
                        }).toList(),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildFloatingActionButton(
                          loc: loc,
                          icon: Icons.add,
                          tooltipKey: 'addStaff',
                          onPressed: () =>
                              _showStaffRequirementDialog(loc: loc),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Cost Summary Section
                    _buildSectionHeader(
                      loc: loc,
                      titleKey: 'costSummary',
                      icon: Icons.calculate,
                      isExpanded: _costSummaryExpanded,
                      onTap: () => setState(
                          () => _costSummaryExpanded = !_costSummaryExpanded),
                    ),
                    if (_costSummaryExpanded) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildCostRow(
                              loc: loc,
                              labelKey: 'resourceCost',
                              value: _totalResourceCost,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            _buildCostRow(
                              loc: loc,
                              labelKey: 'staffCost',
                              value: _totalStaffCost,
                              color: colors.onSurfaceVariant,
                            ),
                            const Divider(height: 24),
                            _buildCostRow(
                              loc: loc,
                              labelKey: 'totalCost',
                              value: _totalCost,
                              color: colors.onSurface,
                              isBold: true,
                            ),
                            if (_finalPrice > 0) ...[
                              const SizedBox(height: 16),
                              _buildCostRow(
                                loc: loc,
                                labelKey: 'finalPriceLabel',
                                value: _finalPrice,
                                color: colors.primary,
                                isBold: true,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _profitMargin >= 20
                                      ? colors.primaryContainer.withOpacity(0.3)
                                      : _profitMargin >= 10
                                          ? colors.secondaryContainer
                                              .withOpacity(0.3)
                                          : colors.errorContainer
                                              .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getLocalizedText(
                                          loc, 'profitMargin', 'Profit Margin'),
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '${_profitMargin.toStringAsFixed(1)}%',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
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
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Save Button
          _buildSaveButton(loc: loc),
        ],
      ),
    );
  }

  Widget _buildCostRow({
    required AppLocalizations loc,
    required String labelKey,
    required double value,
    required Color color,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getLocalizedText(loc, labelKey, labelKey),
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

  // Material/Include methods
  void _addMaterialOption() {
    final material = _materialController.text.trim();
    if (material.isNotEmpty && !_materialOptions.contains(material)) {
      setState(() {
        _materialOptions.add(material);
        _materialController.clear();
      });
    }
  }

  void _removeMaterialOption(int index) {
    setState(() {
      _materialOptions.removeAt(index);
    });
  }

  void _addInclude() {
    final include = _includesController.text.trim();
    if (include.isNotEmpty && !_includes.contains(include)) {
      setState(() {
        _includes.add(include);
        _includesController.clear();
      });
    }
  }

  void _removeInclude(int index) {
    setState(() {
      _includes.removeAt(index);
    });
  }
}
