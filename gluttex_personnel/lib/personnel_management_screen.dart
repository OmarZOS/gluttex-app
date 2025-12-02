import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
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

class _PersonnelManagementScreenState extends State<PersonnelManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _handleTabChange() {
    setState(() {
      _currentTabIndex = _tabController.index;
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
        includePending: true, // Load pending users too
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
        personnelNotifier.clearSearch(
          supplierId: widget.supplierId,
          // includePending:
          //     _currentTabIndex != 1, // Include pending for "All" tab
        );
      } else {
        personnelNotifier.searchPersonnel(
          query,
          currentUserId,
          supplierId: widget.supplierId,
          // includePending:
          //     _currentTabIndex != 1, // Include pending for "All" tab
        );
      }
    });
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
        bottom: false,
        child: Column(
          children: [
            // Header with Supplier Context
            _buildHeader(theme, colorScheme),
            // Quick Stats
            _buildQuickStats(),
            // Tabs
            _buildTabBar(theme, colorScheme, localizations),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        final stats = notifier.getSupplierStats(widget.supplierId);
        final activeCount = stats['active'] ?? 0;
        final pendingCount = stats['pending'] ?? 0;
        final totalCount = stats['total'] ?? 0;
        final adminsCount = stats['admins'] ?? 0;
        final managersCount = stats['managers'] ?? 0;

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
              _buildStatItem(
                  'Active', activeCount, Icons.people_alt, Colors.green),
              _buildStatItem(
                  'Pending', pendingCount, Icons.access_time, Colors.orange),
              _buildStatItem('Total', totalCount, Icons.group,
                  Theme.of(context).colorScheme.primary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, int count, IconData icon, Color iconColor) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
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
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: [
                  _buildPillTab(
                    icon: Icons.all_inclusive_rounded,
                    label: localizations.allText,
                  ),
                  _buildPillTab(
                    icon: Icons.check_circle_rounded,
                    label: localizations.status_active,
                  ),
                  _buildPillTab(
                    icon: Icons.access_time_rounded,
                    label: localizations.pendingTxt,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab({
    required IconData icon,
    required String label,
  }) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
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
                      hintText: _getSearchHint(),
                      prefixIcon: Icon(Icons.search,
                          color: colorScheme.onSurfaceVariant),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: colorScheme.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                                context.read<PersonnelNotifier>().clearSearch(
                                      supplierId: widget.supplierId,
                                      // includePending: _currentTabIndex != 1,
                                    );
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

  String _getSearchHint() {
    switch (_currentTabIndex) {
      case 0: // All
        return 'Search all team members...';
      case 1: // Active
        return 'Search active members...';
      case 2: // Pending
        return 'Search pending invitations...';
      default:
        return 'Search team members...';
    }
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // All Tab
        _buildTabContent(includePending: true),
        // Active Tab
        _buildTabContent(includePending: false),
        // Pending Tab
        _buildPendingTabContent(),
      ],
    );
  }

  Widget _buildTabContent({required bool includePending}) {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        // Get personnel based on tab
        final users = notifier.getPersonnelForSupplier(
          widget.supplierId,
          includePending: includePending,
        );

        // Filter by active/pending status if needed
        final filteredUsers = includePending
            ? users
            : users.where((user) {
                final userId = user.id_app_user ?? 0;
                return !notifier.hasPendingRulesForSupplier(
                    userId, widget.supplierId);
              }).toList();

        if (notifier.isLoading && filteredUsers.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (filteredUsers.isEmpty) {
          return _buildEmptyState(
            title: _getEmptyStateTitle(includePending),
            message: _getEmptyStateMessage(includePending),
          );
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
                includePending: includePending,
              );
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final isPending = notifier.hasPendingRulesForSupplier(
                user.id_app_user ?? 0,
                widget.supplierId,
              );

              return SupplierUserCard(
                user: user,
                isPending: isPending,
                onManagePrivileges: () => _showPrivilegeDialog(user, isPending),
                onRemove: () => _showRemoveDialog(user),
                onResendInvite:
                    isPending ? () => _resendInvitation(user) : null,
                onCancelInvite:
                    isPending ? () => _cancelInvitation(user) : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPendingTabContent() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        // Get only pending users
        final allUsers = notifier.getPersonnelForSupplier(
          widget.supplierId,
          includePending: true,
        );

        final pendingUsers = allUsers.where((user) {
          final userId = user.id_app_user ?? 0;
          return notifier.hasPendingRulesForSupplier(userId, widget.supplierId);
        }).toList();

        if (notifier.isLoading && pendingUsers.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (pendingUsers.isEmpty) {
          return _buildEmptyState(
            title: 'No Pending Invitations',
            message:
                'All invitations have been accepted or no pending invites exist.',
            showInviteButton: true,
          );
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
                includePending: true,
              );
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final user = pendingUsers[index];

              return SupplierUserCard(
                user: user,
                isPending: true,
                onManagePrivileges: () => _showPrivilegeDialog(user, true),
                onRemove: () => _showRemoveDialog(user),
                onResendInvite: () => _resendInvitation(user),
                onCancelInvite: () => _cancelInvitation(user),
              );
            },
          ),
        );
      },
    );
  }

  String _getEmptyStateTitle(bool includePending) {
    if (includePending) {
      return 'No Team Members';
    } else {
      return 'No Active Members';
    }
  }

  String _getEmptyStateMessage(bool includePending) {
    if (includePending) {
      return 'Add team members to manage ${widget.supplierName}';
    } else {
      return 'No active team members found for ${widget.supplierName}';
    }
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

  Widget _buildEmptyState({
    required String title,
    required String message,
    bool showInviteButton = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentTabIndex == 2 ? Icons.access_time : Icons.people_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (showInviteButton) const SizedBox(height: 20),
            if (showInviteButton)
              ElevatedButton.icon(
                onPressed: _showAddOptions,
                icon: const Icon(Icons.person_add),
                label: const Text('Invite New Member'),
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

  Future<void> _showPrivilegeDialog(AppUser user, bool isPending) async {
    // Get existing privileges if user is already in the team
    int? existingPrivileges;
    if (!isPending) {
      final personnelNotifier = context.read<PersonnelNotifier>();
      final rules = await personnelNotifier.getUserPrivileges(
        ruleId: 0,
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId,
      );

      if (rules != null && rules.isNotEmpty) {
        final ruleForSupplier = rules.firstWhere(
          (rule) =>
              rule.productProvider?.id_product_provider == widget.supplierId,
          orElse: () => rules.first,
        );
        // existingPrivileges = ruleForSupplier.privilege ?? 0;
      }
    }

    final int? privilegesBitmask = await showDialog<int>(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: widget.supplierName,
        initialPrivileges: existingPrivileges,
      ),
    );

    if (privilegesBitmask != null && mounted) {
      if (isPending) {
        // For pending users, we can't modify privileges
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot modify privileges for pending users'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await _modifyUserPrivileges(user, privilegesBitmask);
      }
    }
  }

  Future<void> _modifyUserPrivileges(AppUser user, int privileges) async {
    final notifier = context.read<PersonnelNotifier>();
    final currentUserId = context.read<AppUserNotifier>().appUser?.id_app_user;

    if (currentUserId == null) return;

    try {
      // Get the existing rule
      final rules = await notifier.getUserPrivileges(
        ruleId: 0,
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId,
      );

      if (rules == null || rules.isEmpty) {
        // Fallback to add if no rule found
        // await _addUserToSupplier(user, privileges);
        return;
      }

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
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Updated privileges for ${user.personFirstName} ${user.personLastName}',
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update privileges'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      log('Error modifying user privileges: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resendInvitation(AppUser user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resend Invitation'),
        content: Text(
          'Resend invitation to ${user.personFirstName} ${user.personLastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Resend'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // TODO: Implement resend invitation logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation resent to ${user.personFirstName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _cancelInvitation(AppUser user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Invitation'),
        content: Text(
          'Cancel invitation to ${user.personFirstName} ${user.personLastName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('Cancel Invitation'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final notifier = context.read<PersonnelNotifier>();

      // TODO: Implement cancel invitation logic
      // For now, remove from pending list
      final success = await notifier.removeUserFromSupplier(
        user.id_app_user ?? 0,
        widget.supplierId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation canceled'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
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
                  onTap: () => _showQRScanner(false),
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

  Future<void> _showQRScanner(bool isPending) async {
    // Navigate to QR scanner page and wait for result
    final result = await Navigator.pushNamed(context, AppRoutes.QRScanPage);

    log('QR Scanner result: $result (type: ${result.runtimeType})');

    if (result == null || !mounted) return;

    // Handle different possible result types
    if (result is String) {
      _handleScannedQRCode(result, isPending);
    } else if (result is Map<String, dynamic>) {
      // Handle if QR scanner returns a map
      final qrData = result['data']?.toString();
      if (qrData != null) {
        _handleScannedQRCode(qrData, isPending);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR data format')),
        );
      }
    } else {
      log('Unexpected QR result type: ${result.runtimeType}');
    }
  }

  void _handleScannedQRCode(String qrData, bool isPending) {
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
      _fetchUserById(userId, isPending);
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

      _fetchUserById(parsedUserId, isPending);
      return;
    }

    // If none of the above, show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unrecognized QR format: $trimmedData')),
    );
  }

  Future<void> _fetchUserById(int userId, bool isPending) async {
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

      _showPrivilegeDialog(user, isPending);
    } catch (e) {
      log('Error fetching user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user: ${e.toString()}')),
        );
      }
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
