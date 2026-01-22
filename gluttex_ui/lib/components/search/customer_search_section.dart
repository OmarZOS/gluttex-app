import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_ui/components/search/CustomerSearchDialog.dart';
import 'package:gluttex_ui/utils/qr_utils.dart';
import 'package:provider/provider.dart';

class CustomerSection extends StatelessWidget {
  final AppUser? selectedCustomer;
  final Person? selectedPerson;
  final ValueChanged<AppUser?> onCustomerChanged;
  final ValueChanged<Person?> onPersonChanged;
  final String? supplierId;
  final bool showPersonsAsUsers;
  final VoidCallback? onQRScanned;

  const CustomerSection({
    super.key,
    required this.selectedCustomer,
    required this.selectedPerson,
    required this.onCustomerChanged,
    required this.onPersonChanged,
    this.supplierId,
    this.showPersonsAsUsers = true,
    this.onQRScanned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // Determine which type of customer is selected
    final hasCustomer = selectedCustomer != null;
    final hasPerson = selectedPerson != null;
    final hasAnySelection = hasCustomer || hasPerson;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Icon(
          //       Icons.person_outline,
          //       color: theme.colorScheme.primary,
          //       size: 20,
          //     ),
          //     const SizedBox(width: 8),
          //     Text(
          //       loc.customer,
          //       style: theme.textTheme.titleMedium?.copyWith(
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 12),

          // Customer Selection Area with QR button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // QR Code Button
                _buildQRButton(context, theme),

                // Divider
                Container(
                  width: 1,
                  height: 48,
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),

                // Search Area
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCustomerSearchDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: !hasAnySelection
                                ? Text(
                                    loc.searchCustomers,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : Text(
                                    _getSelectedCustomerName(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                          if (hasAnySelection)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: hasPerson
                                    ? Colors.orange.withOpacity(0.1)
                                    : theme.colorScheme.primary
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: hasPerson
                                      ? Colors.orange.withOpacity(0.3)
                                      : theme.colorScheme.primary
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                hasPerson ? loc.persons : loc.users,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: hasPerson
                                      ? Colors.orange
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected Customer/Person Card
          if (hasAnySelection) ...[
            const SizedBox(height: 12),
            _buildCustomerInfoCard(context, theme, loc),
          ],
        ],
      ),
    );
  }

  Widget _buildQRButton(BuildContext context, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleQRCodeOption(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              // const SizedBox(height: 4),
              // Text(
              //   'QR',
              //   style: theme.textTheme.labelSmall?.copyWith(
              //     color: theme.colorScheme.primary,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSelectedCustomerName() {
    if (selectedCustomer != null) {
      return '${selectedCustomer!.personFirstName} ${selectedCustomer!.personLastName}';
    } else if (selectedPerson != null) {
      return selectedPerson!.fullName;
    }
    return '';
  }

  Widget _buildCustomerInfoCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    final isPerson = selectedPerson != null;
    final name = isPerson
        ? selectedPerson!.fullName
        : '${selectedCustomer!.personFirstName} ${selectedCustomer!.personLastName}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPerson
              ? Colors.orange.withOpacity(0.2)
              : theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPerson
                      ? [Colors.orange, Colors.deepOrange]
                      : [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                ),
              ),
              child: Icon(
                isPerson ? Icons.person_outline : Icons.person,
                color: theme.colorScheme.onPrimary,
                size: 20,
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
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPerson)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            loc.persons,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isPerson && selectedPerson!.age != null)
                    Text(
                      '${selectedPerson!.age} years',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: isPerson ? Colors.orange : theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: () {
                // Clear both selections
                onCustomerChanged(null);
                onPersonChanged(null);
              },
              tooltip: loc.changeCustomer,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleQRCodeOption(BuildContext context) async {
    if (onQRScanned != null) {
      // If callback is provided, use it
      onQRScanned!();
      return;
    }

    // Default QR handling
    final qrCode = await Navigator.pushNamed(context, AppRoutes.QRScanPage);
    if (qrCode is! String || qrCode.isEmpty) return;

    final userId = extractUserIdFromQR(qrCode);
    if (userId == null) {
      _showErrorMessage(context, 'Invalid QR code');
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userNotifier = context.read<AppUserNotifier>();
      final AppUser? user = await userNotifier.fetchUserPassively(userId);

      Navigator.pop(context); // Dismiss loading

      if (user == null) {
        _showErrorMessage(context, 'User not found');
        return;
      }

      // Select the user
      onCustomerChanged(user);
      onPersonChanged(null);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer selected: ${user.personFirstName}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss loading
      _showErrorMessage(context, 'Failed to fetch user: $e');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showCustomerSearchDialog(BuildContext context) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => CustomerSearchDialog(
        onCustomerSelected: (customer) {
          onCustomerChanged(customer);
        },
        onPersonSelected: (person) {
          onPersonChanged(person);
        },
        supplierId: int.tryParse(supplierId ?? "0"),
        currentSelectedCustomer: selectedCustomer,
        showPersonsAsUsers: showPersonsAsUsers,
      ),
    );
  }
}
