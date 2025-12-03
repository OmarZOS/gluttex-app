import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/components/pending_tab_content.dart';
import 'package:gluttex_personnel/components/personnel_tab_content.dart';
import 'package:gluttex_personnel/components/privilege_dialog.dart';
import 'package:gluttex_personnel/components/search_invite_dialog.dart';
import 'package:gluttex_personnel/components/supplier_user_card.dart';
import 'package:provider/provider.dart';

class PersonnelManagementScreen extends StatefulWidget {
  final String supplierName;
  final int supplierId;
  final int orgId;

  const PersonnelManagementScreen({
    super.key,
    required this.supplierName,
    required this.orgId,
    required this.supplierId,
  });

  @override
  State<PersonnelManagementScreen> createState() =>
      _PersonnelManagementScreenState();
}

class _PersonnelManagementScreenState extends State<PersonnelManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  void _loadInitialData() {
    final personnelNotifier = context.read<PersonnelNotifier>();
    personnelNotifier.loadPersonnel(
      supplierId: widget.supplierId,
      reset: true,
      includePending: true,
    );
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      final personnelNotifier = context.read<PersonnelNotifier>();

      if (query.isEmpty) {
        personnelNotifier.clearSearch(supplierId: widget.supplierId);
      } else {
        personnelNotifier.searchPersonnel(
          query,
          supplierId: widget.supplierId,
        );
      }
    });
  }

  Future<void> _refreshData() async {
    final personnelNotifier = context.read<PersonnelNotifier>();
    await personnelNotifier.loadPersonnel(
      supplierId: widget.supplierId,
      reset: true,
      includePending: true,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, colorScheme),
            _buildQuickStats(),
            _buildTabBar(theme, colorScheme, localizations),
            _buildSearchBar(theme, colorScheme),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
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
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, _) {
        final stats = notifier.getSupplierStats(widget.supplierId);
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
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Active', stats['active'] ?? 0, Icons.people_alt,
                  Colors.green),
              _buildStatItem('Pending', stats['pending'] ?? 0,
                  Icons.access_time, Colors.orange),
              _buildStatItem('Total', stats['total'] ?? 0, Icons.group,
                  Theme.of(context).colorScheme.primary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme, ColorScheme colorScheme,
      AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: colorScheme.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.all_inclusive_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(localizations.allText),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(localizations.status_active),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(localizations.pendingTxt),
                      ],
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

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Consumer<PersonnelNotifier>(
        builder: (context, notifier, _) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _getSearchHint(),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurfaceVariant,
                              ),
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
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (notifier.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getSearchHint() {
    switch (_tabController.index) {
      case 0:
        return 'Search all team members...';
      case 1:
        return 'Search active members...';
      case 2:
        return 'Search pending invitations...';
      default:
        return 'Search team members...';
    }
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        PersonnelTabContent(
          supplierId: widget.supplierId,
          includePending: true,
          onRefresh: _refreshData,
          onShowPrivilegeDialog: _showPrivilegeDialog,
          onShowRemoveDialog: _showRemoveDialog,
          // onResendInvitation: _resendInvitation,
          onCancelInvitation: _cancelInvitation,
        ),
        PersonnelTabContent(
          supplierId: widget.supplierId,
          includePending: false,
          onRefresh: _refreshData,
          onShowPrivilegeDialog: _showPrivilegeDialog,
          onShowRemoveDialog: _showRemoveDialog,
          // onResendInvitation: _resendInvitation,
          onCancelInvitation: _cancelInvitation,
        ),
        PendingTabContent(
          supplierId: widget.supplierId,
          supplierName: widget.supplierName,
          onRefresh: _refreshData,
          onShowPrivilegeDialog: _showPrivilegeDialog,
          onShowRemoveDialog: _showRemoveDialog,
          // onResendInvitation: _resendInvitation,
          onCancelInvitation: _cancelInvitation,
          onShowAddOptions: _showAddOptions,
        ),
      ],
    );
  }

  // Dialog and action methods
  Future<void> _showPrivilegeDialog(user, bool isPending, int ruleId) async {
    int? existingPrivileges;
    if (!isPending) {
      final personnelNotifier = context.read<PersonnelNotifier>();
      final rules = await personnelNotifier.getUserPrivileges(
        ruleId: ruleId,
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId,
      );

      if (rules != null && rules.isNotEmpty) {
        final ruleForSupplier = rules.firstWhere(
          (rule) =>
              rule.productProvider?.id_product_provider == widget.supplierId,
          orElse: () => rules.first,
        );
        existingPrivileges = ruleForSupplier.management_rule_code;
      }
    }

    final privilegesBitmask = await showDialog<int>(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: widget.supplierName,
        initialPrivileges: existingPrivileges,
      ),
    );

    if (privilegesBitmask != null && mounted && !isPending) {
      await _modifyUserPrivileges(user, privilegesBitmask, ruleId: ruleId);
    }
  }

  Future<void> _modifyUserPrivileges(user, int privileges,
      {int ruleId = 0}) async {
    final notifier = context.read<PersonnelNotifier>();
    try {
      final rules = await notifier.getUserPrivileges(
        ruleId: ruleId,
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId,
      );

      if (rules == null || rules.isEmpty) return;

      final ruleForSupplier = rules.firstWhere(
        (rule) =>
            rule.productProvider?.id_product_provider == widget.supplierId,
        orElse: () => rules.first,
      );

      final success = await notifier.updateTeamMemberPrivileges(
        ruleId: ruleForSupplier.id_management_rule,
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId,
        orgId: widget.orgId,
        privilege: privileges,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Updated privileges for ${user.personFirstName}'
                  : 'Failed to update privileges',
            ),
            backgroundColor: success
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      log('Error modifying user privileges: $e');
    }
  }

  Future<void> _cancelInvitation(user, int ruleId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invitation'),
        content: const Text('Cancel invitation? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Invitation'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final notifier = context.read<PersonnelNotifier>();
      final success = await notifier.removeUserFromSupplier(
        ruleId,
        user.id_app_user ?? 0,
        widget.supplierId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation canceled')),
        );
      }
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Team Member',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add users to manage ${widget.supplierName}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildOptionButton(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR Code',
                subtitle: 'Scan user profile QR code',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.search,
                title: 'Search & Invite',
                subtitle: 'Search and invite existing users',
                onTap: () {
                  Navigator.pop(context);
                  _showSearchInviteDialog();
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle),
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

  void _showSearchInviteDialog() {
    final currentUserId = context.read<AppUserNotifier>().appUser?.id_app_user;
    if (currentUserId == null) return;

    showDialog(
      context: context,
      builder: (context) => SearchInviteDialog(
        orgId: widget.orgId,
        onUserSelected: (user, privileges) =>
            _addUserToSupplier(user, privileges),
        userId: currentUserId,
        supplierId: widget.supplierId,
        supplierName: widget.supplierName,
      ),
    );
  }

  Future<void> _addUserToSupplier(user, int privileges,
      {bool fromQR = false}) async {
    final notifier = context.read<PersonnelNotifier>();
    final success = await notifier.addTeamMember(user.id_app_user ?? 0,
        supplierId: widget.supplierId,
        orgId: widget.orgId,
        privilege: privileges,
        fromQR: fromQR);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Added ${user.personFirstName} to ${widget.supplierName}'
                : 'Failed to add user',
          ),
          backgroundColor: success
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showRemoveDialog(int ruleId, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Team Member'),
        content:
            Text('Remove ${user.personFirstName} from ${widget.supplierName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeUserFromSupplier(ruleId, user);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeUserFromSupplier(int ruleId, AppUser user) async {
    final notifier = context.read<PersonnelNotifier>();
    final success = await notifier.removeUserFromSupplier(
      ruleId,
      user.id_app_user ?? 0,
      widget.supplierId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Removed ${user.personFirstName}'
                : 'Failed to remove user',
          ),
        ),
      );
    }
  }
}
