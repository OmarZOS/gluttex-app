import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/supplier_change_notifier.dart';

class OperationSummary extends StatelessWidget {
  final BusinessOperation operation;

  const OperationSummary({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.operationSummary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryGrid(operation: operation),
          // const SizedBox(height: 16),
          // _AdditionalInfo(operation: operation),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final BusinessOperation operation;

  const _SummaryGrid({required this.operation});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _SummaryItem(
          label: localizations.operationId,
          valueFuture: Future.value(_getOperationId()),
          icon: Icons.numbers,
          color: colorScheme.primary,
        ),
        _ClientSummaryItem(
          operation: operation,
          localizations: localizations,
          color: colorScheme.secondary,
        ),
        _SupplierSummaryItem(
          operation: operation,
          localizations: localizations,
          color: Colors.orange,
        ),
        _SellerSummaryItem(
          operation: operation,
          localizations: localizations,
          color: Colors.purple,
        ),
      ],
    );
  }

  String _getOperationId() {
    if (operation.orderId != null) return '#${operation.orderId}';
    if (operation.cartId != null) return '#${operation.cartId}';
    return 'N/A';
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final Future<String> valueFuture;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.valueFuture,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                FutureBuilder<String>(
                  future: valueFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingSkeleton(colorScheme);
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'N/A',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }

                    return Text(
                      snapshot.data ?? 'N/A',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(ColorScheme colorScheme) {
    return SizedBox(
      height: 16,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _ClientSummaryItem extends StatelessWidget {
  final BusinessOperation operation;
  final AppLocalizations localizations;
  final Color color;

  const _ClientSummaryItem({
    required this.operation,
    required this.localizations,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasClient = operation.clientId != null && operation.clientId! > 0;

    if (!hasClient) {
      return _SummaryItem(
        label: localizations.client,
        valueFuture: Future.value('N/A'),
        icon: Icons.person,
        color: color,
      );
    }

    return FutureBuilder<String>(
      future: _getClientName(context),
      builder: (context, snapshot) {
        final value = snapshot.connectionState == ConnectionState.waiting
            ? '${localizations.loading}...'
            : snapshot.hasError
                ? '#${operation.clientId}'
                : snapshot.data ?? '#${operation.clientId}';

        return _SummaryItem(
          label: localizations.client,
          valueFuture: Future.value(value),
          icon: Icons.person,
          color: color,
        );
      },
    );
  }

  Future<String> _getClientName(BuildContext context) async {
    try {
      final personnelNotifier = context.read<PersonnelNotifier>();

      // Determine client type
      final clientType = 'user';

      final customer = await personnelNotifier.getCustomerDisplayInfo(
        customerId: operation.clientId!,
        customerType: clientType,
        personId: operation.clientId,
      );

      if (customer != null && customer.displayName?.isNotEmpty == true) {
        return customer.displayName!;
      }

      // Fallback to user name if customer info not found
      final appUserNotifier = context.read<AppUserNotifier>();
      final user = await appUserNotifier
          .fetchUserPassively(operation.clientId.toString());

      if (user != null) {
        return _getUserDisplayName(user);
      }

      return '#${operation.clientId}';
    } catch (e) {
      debugPrint('Error fetching client name: $e');
      return '#${operation.clientId}';
    }
  }

  String _getUserDisplayName(AppUser user) {
    final firstName = user.personFirstName?.trim();
    final lastName = user.personLastName?.trim();
    final userName = user.appUserName?.trim();

    if (firstName != null && firstName.isNotEmpty) {
      if (lastName != null && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }

    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    return 'User #${user.idAppUser}';
  }
}

class _SupplierSummaryItem extends StatelessWidget {
  final BusinessOperation operation;
  final AppLocalizations localizations;
  final Color color;

  const _SupplierSummaryItem({
    required this.operation,
    required this.localizations,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasSupplier =
        operation.supplierId != null && operation.supplierId! > 0;

    if (!hasSupplier) {
      return _SummaryItem(
        label: localizations.supplier,
        valueFuture: Future.value('N/A'),
        icon: Icons.business,
        color: color,
      );
    }

    return FutureBuilder<String>(
      future: _getSupplierName(context),
      builder: (context, snapshot) {
        final value = snapshot.connectionState == ConnectionState.waiting
            ? '${localizations.loading}...'
            : snapshot.hasError
                ? '#${operation.supplierId}'
                : snapshot.data ?? '#${operation.supplierId}';

        return _SummaryItem(
          label: localizations.supplier,
          valueFuture: Future.value(value),
          icon: Icons.business,
          color: color,
        );
      },
    );
  }

  Future<String> _getSupplierName(BuildContext context) async {
    try {
      final supplierNotifier = context.read<SupplierChangeNotifier>();
      final supplier = await supplierNotifier.getSupplierById(
        operation.supplierId!,
        forceRefresh: false,
        // notify: false,
      );

      if (supplier != null && supplier.providerName?.isNotEmpty == true) {
        return supplier.providerName!;
      }

      return '#${operation.supplierId}';
    } catch (e) {
      debugPrint('Error fetching supplier name: $e');
      return '#${operation.supplierId}';
    }
  }
}

class _SellerSummaryItem extends StatelessWidget {
  final BusinessOperation operation;
  final AppLocalizations localizations;
  final Color color;

  const _SellerSummaryItem({
    required this.operation,
    required this.localizations,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasSeller = operation.sellerId != null && operation.sellerId! > 0;

    if (!hasSeller) {
      return _SummaryItem(
        label: localizations.seller,
        valueFuture: Future.value('N/A'),
        icon: Icons.person_outline,
        color: color,
      );
    }

    return FutureBuilder<String>(
      future: _getSellerName(context),
      builder: (context, snapshot) {
        final value = snapshot.connectionState == ConnectionState.waiting
            ? '${localizations.loading}...'
            : snapshot.hasError
                ? '#${operation.sellerId}'
                : snapshot.data ?? '#${operation.sellerId}';

        return _SummaryItem(
          label: localizations.seller,
          valueFuture: Future.value(value),
          icon: Icons.person_outline,
          color: color,
        );
      },
    );
  }

  Future<String> _getSellerName(BuildContext context) async {
    try {
      final appUserNotifier = context.read<AppUserNotifier>();
      final user = await appUserNotifier
          .fetchUserPassively(operation.sellerId.toString());

      if (user != null) {
        return _getUserDisplayName(user);
      }

      return '#${operation.sellerId}';
    } catch (e) {
      debugPrint('Error fetching seller name: $e');
      return '#${operation.sellerId}';
    }
  }

  String _getUserDisplayName(AppUser user) {
    final firstName = user.personFirstName?.trim();
    final lastName = user.personLastName?.trim();
    final userName = user.appUserName?.trim();

    if (firstName != null && firstName.isNotEmpty) {
      if (lastName != null && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }

    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    return 'User #${user.idAppUser}';
  }
}

class _AdditionalInfo extends StatelessWidget {
  final BusinessOperation operation;

  const _AdditionalInfo({required this.operation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        if (operation.invoiceStatus.isNotEmpty &&
            operation.invoiceStatus != 'unknown')
          _InfoChip(
            label: '${localizations.invoice}: ${operation.invoiceStatus}',
            color: Colors.blue,
          ),
        if (operation.sourceTable.isNotEmpty &&
            operation.sourceTable != 'unknown')
          _InfoChip(
            label: operation.sourceTable == 'cart_based'
                ? localizations.cartBased
                : localizations.orderBased,
            color: colorScheme.primary,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
