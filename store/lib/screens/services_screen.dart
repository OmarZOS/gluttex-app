import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:store/components/selling_point/selling_point_supplier.dart';
import 'package:store/components/service/details/service_details_header.dart';
import 'package:store/components/service/service_card.dart';
import 'package:store/components/service/service_search_bar.dart';
import 'package:store/components/service/services_empty_state.dart';
import 'package:store/components/service/services_loading_state.dart';
import 'package:store/screens/service_details_screen.dart';
import 'package:provider/provider.dart';

class ServicesScreen extends StatelessWidget {
  final PrivilegeLevel privilegeLevel;
  final int userId;
  final List<int> accessibleSuppliers;
  final List<ManagementRule> userRules;
  final PersonnelNotifier personnelNotifier;
  final ServiceNotifier serviceNotifier;

  const ServicesScreen({
    super.key,
    required this.privilegeLevel,
    required this.userId,
    required this.accessibleSuppliers,
    required this.userRules,
    required this.personnelNotifier,
    required this.serviceNotifier,
  });

  bool get canManage => privilegeLevel == PrivilegeLevel.manage;
  bool get hasMultipleSuppliers => accessibleSuppliers.length > 1;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton:
          canManage ? _buildFloatingActionButton(context, localizations) : null,
      body: RefreshIndicator(
        onRefresh: () async => serviceNotifier.refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, localizations),
            if (hasMultipleSuppliers) _buildSupplierSelector(context),
            ServiceSearchBar(onSearchChanged: serviceNotifier.searchServices),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, AppLocalizations? localizations) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () => _handleAddService(context),
      icon: const Icon(Icons.add),
      label: Text(localizations?.addService ?? 'Add Service'),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    );
  }

  void _handleAddService(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.serviceForm);
  }

  SliverAppBar _buildAppBar(BuildContext context, AppLocalizations? loc) {
    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 140,
      collapsedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        expandedTitleScale: 1.5,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc?.services ?? 'Services',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 4),
            Consumer<ServiceNotifier>(
              builder: (context, notifier, _) {
                return Text(
                  '${notifier.services.length} ${loc?.servicesAvailable ?? 'available'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.background,
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSupplierSelector(BuildContext context) {
    final suppliers = _getAccessibleSuppliers();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SupplierSelector(
          accessibleSuppliers: suppliers,
          selectedSupplierId: serviceNotifier.currentProviderId,
          // allSuppliers: suppliers,
          onSupplierChanged: (id) {
            serviceNotifier.fetchServices(providerId: id ?? 0, reset: true);
          },
          // filterPrivilege: canManage ? 'services_manage' : 'services_view',
          // userRules: userRules,
        ),
      ),
    );
  }

  List<ProductProvider> _getAccessibleSuppliers() {
    final suppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in userRules) {
      if (!rule.isActiveStatus) continue;

      final supplier = rule.productProvider;
      if (supplier != null &&
          !supplierIds.contains(supplier.id_product_provider)) {
        supplierIds.add(supplier.id_product_provider);
        suppliers.add(supplier);
      }
    }

    return suppliers;
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<ServiceNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return const SliverFillRemaining(child: ServicesLoadingState());
        }

        if (notifier.services.isEmpty) {
          return SliverFillRemaining(child: ServicesEmptyState());
        }

        return SliverList.separated(
          itemCount: notifier.services.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final service = notifier.services[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ServiceCard(
                service: service,
                canManage: canManage,
                onTap: () => _handleServiceTap(context, service),
                onEdit: canManage ? () => _handleEditService(service) : null,
                onDelete:
                    canManage ? () => _handleDeleteService(service) : null,
              ),
            );
          },
        );
      },
    );
  }

  void _handleEditService(ProvidedService service) {
    // TODO: Implement edit service
  }

  void _handleDeleteService(ProvidedService service) {
    // TODO: Implement delete service with confirmation
  }
  void _handleServiceTap(BuildContext context, ProvidedService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsScreenLoader(
          serviceId: service.id,
          listService: service, // Pass the service from the list
        ),
      ),
    );
  }
}

// Update your _ServiceDetailsLoader widget to use fetchServiceDetails:
class ServiceDetailsScreenLoader extends StatefulWidget {
  final int serviceId;
  final ProvidedService listService;

  const ServiceDetailsScreenLoader({
    super.key,
    required this.serviceId,
    required this.listService,
  });

  @override
  State<ServiceDetailsScreenLoader> createState() =>
      _ServiceDetailsScreenLoaderState();
}

class _ServiceDetailsScreenLoaderState
    extends State<ServiceDetailsScreenLoader> {
  late Future<ProvidedService> _serviceFuture;

  @override
  void initState() {
    super.initState();
    // First try to get detailed service
    _serviceFuture = _fetchServiceDetails();
  }

  Future<ProvidedService> _fetchServiceDetails() async {
    final notifier = Provider.of<ServiceNotifier>(
      context,
      listen: false,
    );
    final detailedService =
        await notifier.fetchServiceDetails(widget.serviceId);
    return detailedService!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProvidedService>(
      future: _serviceFuture,
      builder: (context, snapshot) {
        // While loading, show a full screen loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading service details...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Optionally show the service name we're loading
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.listService.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // On error, show error screen
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load service details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                    ),
                    const SizedBox(height: 12),
                    // Show the service name we tried to load
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.listService.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can go back and try again',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Go Back'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _serviceFuture = _fetchServiceDetails();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // Show the detailed service
          final detailedService = snapshot.data!;
          return ServiceDetailsScreen(initialService: detailedService);
        }

        // Fallback - shouldn't happen, but show basic service screen
        return ServiceDetailsScreen(initialService: widget.listService);
      },
    );
  }
}
