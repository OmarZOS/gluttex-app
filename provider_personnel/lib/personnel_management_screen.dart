import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider_personnel/components/pending_tab_content.dart';
import 'package:provider_personnel/components/personnel_tab_content.dart';
import 'package:provider_personnel/components/privilege_dialog/privilege_dialog.dart';
import 'package:provider_personnel/components/search_invite_dialog.dart';
import 'package:provider_personnel/components/dashboard/add_options_sheet.dart';
import 'package:provider_personnel/components/dashboard/confirmation_dialogs.dart';
import 'package:provider_personnel/components/dashboard/personnel_header_widget.dart';
import 'package:provider_personnel/components/dashboard/privilege_dialog_manager.dart';
import 'package:ui/utils/qr_utils.dart';
import 'package:provider_personnel/components/dashboard/quick_stats_widget.dart';
import 'package:ui/components/search/search_bar_widget.dart';
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
  bool _isInitialLoadComplete = false;
  late PersonnelNotifier _personnelNotifier;
  late AppUserNotifier _userNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _personnelNotifier = context.read<PersonnelNotifier>();
    _userNotifier = context.read<AppUserNotifier>();

    if (!_isInitialLoadComplete) {
      _isInitialLoadComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
    }
  }

  void _loadInitialData() {
    _personnelNotifier.loadPersonnel(
      supplierId: widget.supplierId,
      reset: true,
      includePending: true,
    );
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _personnelNotifier.clearSearch(supplierId: widget.supplierId);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _personnelNotifier.searchPersonnel(query,
            supplierId: widget.supplierId);
      }
    });
  }

  Future<void> _refreshData() async {
    await _personnelNotifier.loadPersonnel(
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
            PersonnelHeaderWidget(
              supplierName: widget.supplierName,
              onBack: () => Navigator.pop(context),
              colorScheme: colorScheme,
              theme: theme,
            ),
            QuickStatsWidget(supplierId: widget.supplierId),
            _buildTabBar(theme, colorScheme, localizations),
            SearchBarWidget(
              controller: _searchController,
              tabIndex: _tabController.index,
              supplierId: widget.supplierId,
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.person_add),
        label: Text(localizations.addMemberText),
      ),
    );
  }

  Widget _buildTabBar(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        Consumer<PersonnelNotifier>(
          builder: (context, notifier, child) {
            return PersonnelTabContent(
              supplierId: widget.supplierId,
              includePending: true,
              onRefresh: _refreshData,
              onShowPrivilegeDialog: _showPrivilegeDialog,
              onShowRemoveDialog: _showRemoveDialog,
              onCancelInvitation: _cancelInvitation,
            );
          },
        ),
        Consumer<PersonnelNotifier>(
          builder: (context, notifier, child) {
            return PersonnelTabContent(
              supplierId: widget.supplierId,
              includePending: false,
              onRefresh: _refreshData,
              onShowPrivilegeDialog: _showPrivilegeDialog,
              onShowRemoveDialog: _showRemoveDialog,
              onCancelInvitation: _cancelInvitation,
            );
          },
        ),
        Consumer<PersonnelNotifier>(
          builder: (context, notifier, child) {
            return PendingTabContent(
              supplierId: widget.supplierId,
              supplierName: widget.supplierName,
              onRefresh: _refreshData,
              onShowPrivilegeDialog: _showPrivilegeDialog,
              onShowRemoveDialog: _showRemoveDialog,
              onCancelInvitation: _cancelInvitation,
              onShowAddOptions: _showAddOptions,
            );
          },
        ),
      ],
    );
  }

  void _showAddOptions() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddOptionsSheet(
        supplierName: widget.supplierName,
        onQROption: _handleQRCodeOption,
        onSearchOption: _showSearchInviteDialog,
      ),
    );
  }

  void _showSearchInviteDialog() {
    final currentUserId = _userNotifier.appUser?.idAppUser;
    if (currentUserId == null || !mounted) return;

    showDialog(
      context: context,
      builder: (context) => SearchInviteDialog(
        orgId: widget.orgId,
        onUserSelected: (user, privileges) async {
          await _addUserToSupplier(user, privileges);
          _refreshData();
        },
        userId: currentUserId,
        supplierId: widget.supplierId,
        supplierName: widget.supplierName,
      ),
    );
  }

  Future<void> _handleQRCodeOption() async {
    if (!mounted) return;

    Navigator.pop(context);

    final qrCode = await Navigator.pushNamed(context, AppRoutes.QRScanPage);
    if (qrCode is! String || qrCode.isEmpty) return;

    final userId = extractUserIdFromQR(qrCode);
    if (userId == null) return;

    final AppUser? user = await _userNotifier.fetchUserPassively(userId);
    if (user == null || !mounted) return;

    final privilegesBitmask = await showDialog<int>(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: widget.supplierName,
        initialPrivileges: 0,
      ),
    );

    if (privilegesBitmask != null && mounted) {
      await _addUserToSupplier(user, privilegesBitmask, fromQR: true);
    }
  }

  Future<void> _addUserToSupplier(AppUser user, int privileges,
      {bool fromQR = false}) async {
    final success = await _personnelNotifier.addTeamMember(
      user.idAppUser ?? 0,
      supplierId: widget.supplierId,
      orgId: widget.orgId,
      privilege: privileges,
      fromQR: fromQR,
    );

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

  Future<void> _showPrivilegeDialog(
      AppUser user, bool isPending, int ruleId) async {
    await PrivilegeDialogManager.showPrivilegeDialog(
      context: context,
      user: user,
      isPending: isPending,
      ruleId: ruleId,
      supplierId: widget.supplierId,
      supplierName: widget.supplierName,
      personnelNotifier: _personnelNotifier,
      orgId: widget.orgId,
      onRefresh: _refreshData,
    );
  }

  Future<void> _cancelInvitation(AppUser user, int ruleId) async {
    await ConfirmationDialogs.showCancelInvitationDialog(
      context: context,
      user: user,
      onConfirm: () async {
        final success = await _personnelNotifier.removeUserFromSupplier(
          ruleId,
          user.idAppUser ?? 0,
          widget.supplierId,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${user.personFirstName}\'s invitation has been cancelled'),
            ),
          );
          _refreshData();
        }
      },
    );
  }

  void _showRemoveDialog(int ruleId, AppUser user) {
    ConfirmationDialogs.showRemoveMemberDialog(
      context: context,
      userName: user.personFirstName ?? "",
      supplierName: widget.supplierName,
      onConfirm: () => _removeUserFromSupplier(ruleId, user),
    );
  }

  Future<void> _removeUserFromSupplier(int ruleId, AppUser user) async {
    final success = await _personnelNotifier.removeUserFromSupplier(
      ruleId,
      user.idAppUser ?? 0,
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
      _refreshData();
    }
  }
}
