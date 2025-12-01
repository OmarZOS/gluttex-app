import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/privilege_dialog.dart';
import 'package:gluttex_personnel/search_invite_dialog.dart';
import 'package:gluttex_personnel/supplier_user_card.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_core/app/AppUser.dart';

class PersonnelManagementScreen extends StatefulWidget {
  final String supplierName;
  final int supplierId;
  final int orgId;

  const PersonnelManagementScreen({
    Key? key,
    required this.supplierName,
    required this.orgId,
    required this.supplierId,
  }) : super(key: key);

  @override
  State<PersonnelManagementScreen> createState() =>
      _PersonnelManagementScreenState();
}

class _PersonnelManagementScreenState extends State<PersonnelManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final appUserNotifier = context.read<AppUserNotifier>();
    final personnelNotifier = context.read<PersonnelNotifier>();

    final currentUserId = appUserNotifier.appUser?.id_app_user;
    if (currentUserId != null) {
      personnelNotifier.loadPersonnel(
        currentUserId,
        supplierId: widget.supplierId,
        reset: true,
      );
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      final appUserNotifier = context.read<AppUserNotifier>();
      final personnelNotifier = context.read<PersonnelNotifier>();

      final currentUserId = appUserNotifier.appUser?.id_app_user;
      if (currentUserId == null) return;

      if (query.isEmpty) {
        personnelNotifier.clearSearch(supplierId: widget.supplierId);
      } else {
        personnelNotifier.searchPersonnel(
          query,
          currentUserId,
          supplierId: widget.supplierId,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with Supplier Context
            _buildHeader(theme, colorScheme),
            // Quick Stats
            _buildQuickStats(),
            // Search Bar
            _buildSearchBar(theme, colorScheme),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 20.0,
        left: 24.0,
        right: 24.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back,
                    color: colorScheme.onPrimary, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.supplierName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personnel Management',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (context.read<AppUserNotifier>().appUser?.isAdmin ?? false)
                _buildAdminBadge(colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: colorScheme.onPrimary, size: 16),
          const SizedBox(width: 4),
          Text(
            'Admin',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        final supplierPersonnel =
            notifier.getPersonnelForSupplier(widget.supplierId);
        final totalUsers = supplierPersonnel.length;
        final activeAdmins =
            supplierPersonnel.where((user) => user.isAdmin).length;
        final managers = supplierPersonnel
            .where((user) =>
                user.app_user_type_desc?.toLowerCase().contains('manager') ??
                false)
            .length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalUsers, Icons.people_alt),
              _buildStatItem(
                  'Admins', activeAdmins, Icons.admin_panel_settings),
              _buildStatItem('Managers', managers, Icons.manage_accounts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Consumer<PersonnelNotifier>(
        builder: (context, notifier, child) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search team members...',
                      prefixIcon: Icon(Icons.search,
                          color: colorScheme.onSurfaceVariant),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: colorScheme.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<PersonnelNotifier>()
                                    .clearSearch(supplierId: widget.supplierId);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (notifier.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        // Get personnel for this specific supplier
        final supplierPersonnel =
            notifier.getPersonnelForSupplier(widget.supplierId);

        if (notifier.isLoading && supplierPersonnel.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (supplierPersonnel.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            final currentUserId =
                context.read<AppUserNotifier>().appUser?.id_app_user;
            if (currentUserId != null) {
              await notifier.loadPersonnel(
                currentUserId,
                supplierId: widget.supplierId,
                reset: true,
              );
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: supplierPersonnel.length,
            itemBuilder: (context, index) {
              final user = supplierPersonnel[index];
              return SupplierUserCard(
                user: user,
                onManagePrivileges: () => _showPrivilegeDialog(user),
                onRemove: () => _showRemoveDialog(user),
                // supplierId: widget.supplierId,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: colorScheme.surfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      color: colorScheme.surfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Team Members',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add team members to manage ${widget.supplierName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddOptions,
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: _showAddOptions,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.person_add),
      label: const Text('Add Member'),
    );
  }

  void _showAddOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Team Member',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add users to manage ${widget.supplierName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOptionButton(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan QR Code',
                  subtitle: 'Scan user profile QR code',
                  onTap: _showQRScanner,
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.search,
                  title: 'Search & Invite',
                  subtitle: 'Search and invite existing users',
                  onTap: _showSearchInviteDialog,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(icon, color: colorScheme.onPrimaryContainer, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQRScanner() async {
    // Navigate to QR scanner page and wait for result
    final result = await Navigator.pushNamed(context, AppRoutes.QRScanPage);

    log('QR Scanner result: $result (type: ${result.runtimeType})');

    if (result == null || !mounted) return;

    // Handle different possible result types
    if (result is String) {
      _handleScannedQRCode(result);
    } else if (result is Map<String, dynamic>) {
      // Handle if QR scanner returns a map
      final qrData = result['data']?.toString();
      if (qrData != null) {
        _handleScannedQRCode(qrData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR data format')),
        );
      }
    } else {
      log('Unexpected QR result type: ${result.runtimeType}');
    }
  }

  void _handleScannedQRCode(String qrData) {
    log('Handling QR data: $qrData');

    // Try different formats:
    // 1. If it's just a number, assume it's a user ID
    if (qrData.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empty QR code')),
      );
      return;
    }

    final trimmedData = qrData.trim();

    // Check if it's just a number (user ID)
    final userId = int.tryParse(trimmedData);
    if (userId != null) {
      log('Parsed user ID: $userId');
      _fetchUserById(userId);
      return;
    }

    // Check if it's in "user:123" format
    if (trimmedData.contains(':')) {
      final parts = trimmedData.split(':');
      if (parts.length != 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code format')),
        );
        return;
      }

      final label = parts[0].trim();
      final idString = parts[1].trim();

      log('Scanned QR Code: label=$label, id=$idString');

      if (label.toLowerCase() != 'user') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not a user QR code')),
        );
        return;
      }

      final parsedUserId = int.tryParse(idString);
      if (parsedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user ID in QR code')),
        );
        return;
      }

      _fetchUserById(parsedUserId);
      return;
    }

    // If none of the above, show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unrecognized QR format: $trimmedData')),
    );
  }

  Future<void> _fetchUserById(int userId) async {
    final appUserNotifier = context.read<AppUserNotifier>();

    try {
      final user = await appUserNotifier.fetchUserPassively(userId.toString());

      if (user == null || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
        return;
      }

      _showPrivilegeDialog(user);
    } catch (e) {
      log('Error fetching user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showPrivilegeDialog(AppUser user) async {
    // Show privilege dialog and wait for the result
    final int? privilegesBitmask = await showDialog<int>(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: widget.supplierName,
        initialPrivileges:
            0, // Start with no privileges, or pass existing if editing
      ),
    );

    // If user selected privileges (didn't cancel)
    if (privilegesBitmask != null && mounted) {
      await _addUserToSupplier(user, privilegesBitmask);
    }
  }

  void _showSearchInviteDialog() {
    final currentUserId = context.read<AppUserNotifier>().appUser?.id_app_user;
    if (currentUserId == null) return;

    showDialog(
      context: context,
      builder: (context) => SearchInviteDialog(
        orgId: widget.orgId,
        onUserSelected: (user, privileges) {
          _addUserToSupplier(user, privileges);
        },
        userId: currentUserId,
        supplierId: widget.supplierId,
        supplierName: widget.supplierName,
      ),
    );
  }

  Future<void> _addUserToSupplier(AppUser user, int privileges) async {
    final notifier = context.read<PersonnelNotifier>();
    final currentUserId = context.read<AppUserNotifier>().appUser?.id_app_user;

    if (currentUserId == null) return;

    final success = await notifier.addTeamMember(
      user.id_app_user ?? 0,
      supplierId: widget.supplierId,
      orgId: widget.orgId,
      privilege: privileges,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${user.personFirstName} ${user.personLastName} to ${widget.supplierName}',
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        final error = notifier.error ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add user: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showRemoveDialog(AppUser user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Team Member',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to remove ${user.personFirstName} ${user.personLastName} from ${widget.supplierName}?',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              _removeUserFromSupplier(user);
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeUserFromSupplier(AppUser user) async {
    final notifier = context.read<PersonnelNotifier>();
    // TODO: Implement removeUserFromSupplier method in PersonnelNotifier
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Remove functionality for ${user.personFirstName} coming soon',
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
