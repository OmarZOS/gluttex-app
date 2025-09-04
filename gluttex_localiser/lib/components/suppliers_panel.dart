import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localiser/components/location_filter.dart';
import 'package:gluttex_ui/components/supplier/supplier_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PanelContent extends StatefulWidget {
  final List<Supplier> suppliers;
  final bool isLoading;
  final ScrollController scrollController;
  final Function focusOnLocation;
  final dynamic selectedLocation;
  final Function? onDeleteLocationFilter;
  final Function applyLocationFilter;

  const PanelContent({
    Key? key,
    required this.suppliers,
    required this.isLoading,
    required this.scrollController,
    required this.focusOnLocation,
    required this.selectedLocation,
    this.onDeleteLocationFilter,
    required this.applyLocationFilter,
  }) : super(key: key);

  @override
  State<PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends State<PanelContent> {
  final ValueNotifier<bool>? _localFilterNotifier =
      ValueNotifier<bool>(false); // Add this

  @override
  void initState() {
    super.initState();
    _localFilterNotifier!.value = widget.selectedLocation != null;
  }

  @override
  void didUpdateWidget(covariant PanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      _localFilterNotifier?.value = widget.selectedLocation != null;
    }
  }

  @override
  void dispose() {
    _localFilterNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header section - rebuilds only when filter changes
        _buildHeaderSection(theme, loc),
        const SizedBox(height: 8),

        // Supplier List - use separate builder to optimize rebuilds
        _buildSupplierList(theme, loc, isDarkMode),
      ],
    );
  }

  Widget _buildHeaderSection(ThemeData theme, AppLocalizations loc) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title and Filter Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Expanded(
                child: Text(
                  loc.providersText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // Filter Button - use ValueListenableBuilder to prevent rebuilds
              ValueListenableBuilder<bool>(
                valueListenable:
                    _localFilterNotifier!, // Your filter notifier here,
                builder: (context, isFilterApplied, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.selectedLocation != null
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    child: IconButton(
                      onPressed: () => LocationFilterBottomSheet.show(
                        context,
                        widget.applyLocationFilter,
                        widget.selectedLocation,
                      ),
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: widget.selectedLocation != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withOpacity(0.7),
                        size: 24,
                      ),
                      tooltip: 'Filter by location',
                    ),
                  );
                },
              ),
            ],
          ),

          // Active filter chip
          if (widget.selectedLocation != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(
                    widget.selectedLocation!["name"],
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onDeleted: () {
                    if (widget.onDeleteLocationFilter != null) {
                      widget.onDeleteLocationFilter!();
                    }
                  },
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupplierList(
      ThemeData theme, AppLocalizations loc, bool isDarkMode) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.suppliers.isEmpty) {
      return Center(
        child: Text(
          loc.notFoundError,
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: widget.suppliers.length,
        itemBuilder: (context, index) {
          final supplier = widget.suppliers[index];
          return _buildSupplierItem(supplier, theme, loc, isDarkMode);
        },
      ),
    );
  }

  Widget _buildSupplierItem(Supplier supplier, ThemeData theme,
      AppLocalizations loc, bool isDarkMode) {
    final category = loc.providerCategoryTextList
        .split(",")[supplier.productProviderTypeId - 1];

    return Card(
      color: isDarkMode
          ? theme.colorScheme.primaryContainer.withOpacity(0.2)
          : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildSupplierImage(supplier, theme),
        title: _buildSupplierTitle(supplier, category, theme),
        subtitle: _buildSupplierSubtitle(supplier, theme),
        trailing: _buildLocationButton(supplier, theme),
        onTap: () => showSupplierDetails(context, supplier),
      ),
    );
  }

  Widget _buildSupplierImage(Supplier supplier, ThemeData theme) {
    return CircleAvatar(
        radius: 40,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Image.network(
          GluttexConstants.fsBaseUrl + (supplier.supplier_image_url ?? ""),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SvgPicture.asset(
              'assets/icons/${supplier.productProviderTypeId}.svg',
              package: "gluttex_localiser",
              width: 30,
              height: 30,
              color: Theme.of(context).colorScheme.onSurface,
            );
          },
          key: ValueKey(supplier.supplier_image_url),
        ));
  }

  Widget _buildSupplierTitle(
      Supplier supplier, String category, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          supplier.providerName,
          style: theme.textTheme.titleMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierSubtitle(Supplier supplier, ThemeData theme) {
    return Text(
      AppLocalizations.of(context)!
          .by_organisation(supplier.provider_organisation_name),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildLocationButton(Supplier supplier, ThemeData theme) {
    return IconButton(
      icon: Icon(
        FontAwesomeIcons.locationDot,
        color: theme.colorScheme.primary,
      ),
      onPressed: () => widget.focusOnLocation(
          supplier.locationLatitude, supplier.locationLongitude),
    );
  }
}
