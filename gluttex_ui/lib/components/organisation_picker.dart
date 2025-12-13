import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:provider/provider.dart';

class OrganisationPicker extends StatefulWidget {
  final ValueChanged<Organisation>? onOrganisationSelected;
  final int? initialValue;
  final String hintText;
  final bool showLabel;

  const OrganisationPicker({
    super.key,
    this.onOrganisationSelected,
    this.initialValue,
    required this.hintText,
    this.showLabel = true,
  });

  @override
  _OrganisationPickerState createState() => _OrganisationPickerState();
}

class _OrganisationPickerState extends State<OrganisationPicker> {
  int? selectedOrganisationId;
  String? newOrganisationName;

  final TextEditingController _searchController = TextEditingController();
  List<Organisation> filteredOrganisations = [];
  bool showCreateOption = false;

  late List<Organisation> organisations;

  late SupplierChangeNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = Provider.of<SupplierChangeNotifier>(context, listen: false);
    organisations = notifier.organisations;
    selectedOrganisationId = widget.initialValue;
    filteredOrganisations = List.from(organisations);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredOrganisations = List.from(organisations);
        showCreateOption = false;
      } else {
        // Filter organisations that match the search
        filteredOrganisations = organisations
            .where((org) =>
                org.provider_organisation_name.toLowerCase().contains(query))
            .toList();

        // Show create option if no exact match exists and query is not empty
        showCreateOption = query.isNotEmpty &&
            !organisations.any((org) =>
                org.provider_organisation_name.toLowerCase() ==
                query.toLowerCase());
      }
    });
  }

  void _openOrganisationPicker() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Reset search when opening the picker
    _searchController.clear();
    setState(() {
      filteredOrganisations = List.from(organisations);
      showCreateOption = false;
    });

    final result = await showModalBottomSheet<Organisation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheet();
      },
    );

    if (result != null) {
      setState(() => selectedOrganisationId = result.id_provider_organisation);
      widget.onOrganisationSelected?.call(result);

      newOrganisationName = result.provider_organisation_name;
    } else
      newOrganisationName = null;
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectOrganisation,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchOrganisations,
                    prefixIcon: const Icon(Icons.search, size: 22),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              // Results list
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    final hasResults =
                        filteredOrganisations.isNotEmpty || showCreateOption;

                    if (!hasResults) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)!.noOrganisationsFound,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        // "Create new" option
                        if (showCreateOption)
                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .createNew),
                                  TextSpan(
                                    text: _searchController.text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.pop(
                                  context,
                                  Organisation(
                                      id_provider_organisation: 0,
                                      provider_organisation_name:
                                          _searchController.text,
                                      provider_organisation_desc: ""));
                            },
                          ),

                        // List of existing organisations
                        if (filteredOrganisations.isNotEmpty)
                          ...filteredOrganisations.map((org) {
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      org.provider_organisation_name[0],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(org.provider_organisation_name),
                              trailing: selectedOrganisationId ==
                                      org.id_provider_organisation
                                  ? Icon(
                                      Icons.check,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    )
                                  : null,
                              onTap: () => Navigator.pop(context, org),
                            );
                          }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getOrganizationColor() {
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (widget.showLabel)
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 8.0),
        //     child: Text(
        //       "Organisation",
        //       style: Theme.of(context).textTheme.labelMedium?.copyWith(
        //             color: Theme.of(context)
        //                 .colorScheme
        //                 .onSurface
        //                 .withOpacity(0.7),
        //           ),
        //     ),
        //   ),
        GestureDetector(
          onTap: _openOrganisationPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedOrganisationId != null &&
                        selectedOrganisationId != 0
                    ? _getOrganizationColor().withOpacity(0.3)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      (selectedOrganisationId != null &&
                              selectedOrganisationId != 0)
                          ? Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  organisations
                                      .where((val) =>
                                          selectedOrganisationId ==
                                          val.id_provider_organisation)
                                      .first
                                      .provider_organisation_name[0],
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.organisationText,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                (selectedOrganisationId != null &&
                                        selectedOrganisationId != 0)
                                    ? organisations
                                        .where((val) =>
                                            selectedOrganisationId ==
                                            val.id_provider_organisation)
                                        .first
                                        .provider_organisation_name
                                    : (newOrganisationName ?? widget.hintText),
                                style: TextStyle(
                                  color: selectedOrganisationId != null &&
                                          selectedOrganisationId != 0
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                      : (newOrganisationName != null
                                          ? Colors.orange
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6)),
                                  fontWeight: selectedOrganisationId == null
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
