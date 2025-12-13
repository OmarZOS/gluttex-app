import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_event/personnel_notifier.dart';

class SupplierOrdersScreen extends StatelessWidget {
  final PrivilegeLevel privilegeLevel;
  final int userId;
  final List<int> accessibleSuppliers;
  final PersonnelNotifier personnelNotifier;

  const SupplierOrdersScreen({
    super.key,
    required this.privilegeLevel,
    required this.userId,
    required this.accessibleSuppliers,
    required this.personnelNotifier,
  });

  bool get _canManage => privilegeLevel == PrivilegeLevel.manage;
  bool get _canView => privilegeLevel == PrivilegeLevel.view;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartChangeNotifier>(
      builder: (context, cartNotifier, _) {
        return _OrdersScreenContent(
          privilegeLevel: privilegeLevel,
          userId: userId,
          accessibleSuppliers: accessibleSuppliers,
          personnelNotifier: personnelNotifier,
          cartNotifier: cartNotifier,
          canManage: _canManage,
          canView: _canView,
        );
      },
    );
  }
}

class _OrdersScreenContent extends StatefulWidget {
  final PrivilegeLevel privilegeLevel;
  final int userId;
  final List<int> accessibleSuppliers;
  final PersonnelNotifier personnelNotifier;
  final CartChangeNotifier cartNotifier;
  final bool canManage;
  final bool canView;

  const _OrdersScreenContent({
    required this.privilegeLevel,
    required this.userId,
    required this.accessibleSuppliers,
    required this.personnelNotifier,
    required this.cartNotifier,
    required this.canManage,
    required this.canView,
  });

  @override
  State<_OrdersScreenContent> createState() => _OrdersScreenContentState();
}

class _OrdersScreenContentState extends State<_OrdersScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeSupplier();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeSupplier() {
    final userRules = widget.personnelNotifier.getRulesForUser(widget.userId);

    // Find first supplier with order management/view privilege
    for (final rule in userRules) {
      if (!rule.isActiveStatus) continue;

      final ruleCode = rule.management_rule_code ?? 0;
      final hasPrivilege = widget.canManage
          ? _checkPrivilege(ruleCode, 'orders_manage')
          : _checkPrivilege(ruleCode, 'orders_view');

      if (hasPrivilege) {
        final supplierId = rule.productProvider?.id_product_provider;
        if (supplierId != null) {
          setState(() => _selectedSupplierId = supplierId);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.cartNotifier.fetchOrders(
              appUserId: supplierId,
              reset: true,
            );
          });

          // Load orders for this supplier
          break;
        }
      }
    }
  }

  bool _checkPrivilege(int ruleCode, String privilegeId) {
    // Assuming you have a RoleBitMapper or similar
    // This is a placeholder - replace with your actual privilege check
    return true; // TODO: Implement actual privilege check
  }

  void _selectSupplier(int? supplierId) {
    if (_selectedSupplierId != supplierId) {
      setState(() => _selectedSupplierId = supplierId);

      if (supplierId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.cartNotifier.fetchOrders(
            appUserId: supplierId,
            reset: true,
          );
        });
      }
    }
  }

  List<ProductProvider> _getAccessibleSuppliers() {
    final userRules = widget.personnelNotifier.getRulesForUser(widget.userId);
    final suppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in userRules) {
      if (!rule.isActiveStatus) continue;

      final ruleCode = rule.management_rule_code ?? 0;
      final hasPrivilege = widget.canManage
          ? _checkPrivilege(ruleCode, 'orders_manage')
          : _checkPrivilege(ruleCode, 'orders_view');

      if (hasPrivilege) {
        final supplier = rule.productProvider;
        if (supplier != null &&
            !supplierIds.contains(supplier.id_product_provider)) {
          supplierIds.add(supplier.id_product_provider);
          suppliers.add(supplier);
        }
      }
    }

    return suppliers;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.ordersText),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.pendingTxt),
            Tab(text: localizations.processingTxt),
            Tab(text: localizations.completedTxt),
          ],
        ),
      ),
      body: Column(
        children: [
          _SupplierSelector(
            selectedSupplierId: _selectedSupplierId,
            accessibleSuppliers: _getAccessibleSuppliers(),
            onSupplierChanged: _selectSupplier,
            canManage: widget.canManage,
            canView: widget.canView,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderListView(
                  status: 'pending',
                  cartNotifier: widget.cartNotifier,
                  canManage: widget.canManage,
                ),
                _OrderListView(
                  status: 'processing',
                  cartNotifier: widget.cartNotifier,
                  canManage: widget.canManage,
                ),
                _OrderListView(
                  status: 'completed',
                  cartNotifier: widget.cartNotifier,
                  canManage: widget.canManage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierSelector extends StatelessWidget {
  final int? selectedSupplierId;
  final List<ProductProvider> accessibleSuppliers;
  final Function(int?) onSupplierChanged;
  final bool canManage;
  final bool canView;

  const _SupplierSelector({
    required this.selectedSupplierId,
    required this.accessibleSuppliers,
    required this.onSupplierChanged,
    required this.canManage,
    required this.canView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (!canView && !canManage) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        child: Text(
          localizations.noOrderManagementPrivileges,
          style: TextStyle(color: theme.colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (accessibleSuppliers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surfaceVariant,
        child: Text(
          localizations.noOrderManagementPrivileges,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<int?>(
            isExpanded: true,
            value: selectedSupplierId,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            dropdownColor: theme.colorScheme.surface,
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.primary,
            ),
            hint: Text(
              localizations.selectSupplier,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            items: accessibleSuppliers.map((supplier) {
              return DropdownMenuItem<int?>(
                value: supplier.id_product_provider,
                child: Text(
                  supplier.product_provider_details.provider_name,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              );
            }).toList(),
            onChanged: onSupplierChanged,
          ),
        ),
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final String status;
  final CartChangeNotifier cartNotifier;
  final bool canManage;

  const _OrderListView({
    required this.status,
    required this.cartNotifier,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (cartNotifier.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    final orders = cartNotifier.orders.where((order) {
      return order.status.toLowerCase() == status.toLowerCase();
    }).toList();

    if (orders.isEmpty) {
      return _EmptyState(
        status: status,
        localizations: localizations,
        theme: theme,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _OrderCard(
          order: orders[index],
          canManage: canManage,
          onTap: () => _showOrderDetail(context, orders[index]),
        );
      },
    );
  }

  void _showOrderDetail(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool canManage;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.canManage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status, theme);
    final statusIcon = _getStatusIcon(order.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.idOrder}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${order.totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.shopping_bag,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${order.itemCount} items',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(order.orderedTimestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                ),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizations.orderDetails,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Add order details here
                    // You can expand this with more detailed information
                    Text('Order details would go here...'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String status;
  final AppLocalizations localizations;
  final ThemeData theme;

  const _EmptyState({
    required this.status,
    required this.localizations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getStatusIcon(status);
    final message = _getEmptyMessage(status, localizations);
    final color = _getStatusColor(status, theme);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.noOrdersFoundForStatus,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Color _getStatusColor(String status, ThemeData theme) {
  switch (status.toLowerCase()) {
    case 'pending':
      return theme.colorScheme.error;
    case 'processing':
      return theme.colorScheme.primary;
    case 'completed':
      return theme.colorScheme.tertiary;
    default:
      return theme.colorScheme.outline;
  }
}

IconData _getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.access_time;
    case 'processing':
      return Icons.local_shipping;
    case 'completed':
      return Icons.check_circle;
    default:
      return Icons.question_mark;
  }
}

String _getEmptyMessage(String status, AppLocalizations localizations) {
  switch (status.toLowerCase()) {
    case 'pending':
      return localizations.noPendingOrders;
    case 'processing':
      return localizations.noProcessingOrders;
    case 'completed':
      return localizations.noCompletedOrders;
    default:
      return localizations.noOrdersFound;
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
