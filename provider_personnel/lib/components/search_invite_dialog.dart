import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider_personnel/components/privilege_dialog/privilege_dialog.dart';
import 'package:provider/provider.dart';

class SearchInviteDialog extends StatefulWidget {
  final Function(AppUser, int) onUserSelected;
  final int userId;
  final int? orgId;
  final int? supplierId;
  final String supplierName;

  const SearchInviteDialog({
    Key? key,
    required this.onUserSelected,
    required this.orgId,
    required this.userId,
    this.supplierId = 0,
    required this.supplierName,
  }) : super(key: key);

  @override
  State<SearchInviteDialog> createState() => _SearchInviteDialogState();
}

class _SearchInviteDialogState extends State<SearchInviteDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      final notifier = context.read<PersonnelNotifier>();

      if (query.isEmpty) {
        notifier.clearSearch(supplierId: widget.supplierId ?? 0);
      } else if (query.length >= 2) {
        final userId =
            context.read<AppUserNotifier>().appUser!.id_app_user ?? 0;
        notifier.searchPersonnel(
          query,
          // userId,
          supplierId: widget.supplierId ?? 0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 600,
          minHeight: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: Consumer<PersonnelNotifier>(
                builder: (context, notifier, child) {
                  return _buildContent(notifier);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search & Invite',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find users to add to ${widget.supplierName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
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

  Widget _buildSearchBar() {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
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
                      hintText: 'Search by name, username, or role...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
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

  Widget _buildContent(PersonnelNotifier notifier) {
    // FIXED: Check searchQuery instead of personnel for search state
    final hasSearchQuery = notifier.searchQuery.isNotEmpty;

    if (notifier.isLoading && notifier.searchResults.isEmpty) {
      return _buildLoadingState();
    }

    if (!hasSearchQuery && notifier.searchResults.isEmpty) {
      return _buildInitialState();
    }

    if (hasSearchQuery && notifier.searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResults(notifier);
  }

  Widget _buildInitialState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.group,
          size: 80,
          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'Search for users',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter a name, username, or role to find people',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Searching...',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 80,
          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'No users found',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your search terms',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            _searchController.clear();
            context.read<PersonnelNotifier>().clearSearch(
                  supplierId: widget.supplierId ?? 0,
                );
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Clear Search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceVariant,
            foregroundColor: colorScheme.onSurfaceVariant,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildResults(PersonnelNotifier notifier) {
    // FIXED: Use searchResults instead of personnel
    final searchResults = notifier.searchResults;
    final hasSearchQuery = notifier.searchQuery.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                '${hasSearchQuery ? 'Search results' : 'All users'}: ${searchResults.length} user${searchResults.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final user = searchResults[index];
              return _buildUserTile(user, notifier);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(AppUser user, PersonnelNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Check if user is already in the team
    final isUserInTeam = _isUserAlreadyInTeam(user.id_app_user ?? 0, notifier);
    final isPending = _isUserPending(user.id_app_user ?? 0, notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUserInTeam && !isPending
              ? () {
                  // Show info that user is already in the team
                  _showAlreadyInTeamDialog(user);
                }
              : () => _showPrivilegeDialog(user, isUserInTeam, isPending),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUserInTeam
                    ? (isPending
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3))
                    : colorScheme.outline.withOpacity(0.1),
                width: isUserInTeam ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildUserAvatar(user, isUserInTeam, isPending),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${user.personFirstName} ${user.personLastName}'
                                .trim(),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isUserInTeam)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isPending
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  isPending ? 'Pending' : 'In Team',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isPending
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (user.app_user_name != null &&
                          user.app_user_name!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.alternate_email_rounded,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '@${user.app_user_name!}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      _buildUserRole(
                          user.app_user_type_desc, colorScheme, textTheme),
                    ],
                  ),
                ),
                _buildAddButton(colorScheme, isUserInTeam, isPending),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(AppUser user, bool isUserInTeam, bool isPending) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isUserInTeam
                ? (isPending
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1))
                : colorScheme.surfaceVariant,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isUserInTeam
                  ? (isPending
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3))
                  : colorScheme.outline.withOpacity(0.2),
              width: isUserInTeam ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: user.app_user_image_url != null &&
                    user.app_user_image_url!.isNotEmpty
                ? Image.network(
                    user.app_user_image_url!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackAvatar(
                          colorScheme, user, isUserInTeam, isPending);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  )
                : _buildFallbackAvatar(
                    colorScheme, user, isUserInTeam, isPending),
          ),
        ),
        if (isUserInTeam)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isPending ? Colors.orange : Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                isPending ? Icons.access_time : Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackAvatar(ColorScheme colorScheme, AppUser user,
      bool isUserInTeam, bool isPending) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final color = colors[user.id_app_user! % colors.length];
    final initials = _getUserInitials(user);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: isUserInTeam
                ? (isPending ? Colors.orange : Colors.green)
                : color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildUserRole(
      String? role, ColorScheme colorScheme, TextTheme textTheme) {
    final roleText = role ?? 'User';
    final roleColor = _getRoleColor(roleText, colorScheme);
    final roleIcon = _getRoleIcon(roleText);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: roleColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleIcon,
            size: 12,
            color: roleColor,
          ),
          const SizedBox(width: 4),
          Text(
            roleText,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: roleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
      ColorScheme colorScheme, bool isUserInTeam, bool isPending) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUserInTeam
            ? (isPending
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1))
            : colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUserInTeam
              ? (isPending
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2))
              : colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        isUserInTeam
            ? (isPending ? Icons.access_time : Icons.check)
            : Icons.person_add_alt_1_rounded,
        size: 20,
        color: isUserInTeam
            ? (isPending ? Colors.orange : Colors.green)
            : colorScheme.primary,
      ),
    );
  }

  bool _isUserAlreadyInTeam(int userId, PersonnelNotifier notifier) {
    // Check if user is in the team (active or pending)
    final users = notifier.getPersonnelForSupplier(
      widget.supplierId ?? 0,
      includePending: true,
    );

    return users.any((user) => user.id_app_user == userId);
  }

  bool _isUserPending(int userId, PersonnelNotifier notifier) {
    // Check if user has pending rules for this supplier
    return notifier.hasPendingRulesForSupplier(userId, widget.supplierId ?? 0);
  }

  Future<void> _showPrivilegeDialog(
      AppUser user, bool isUserInTeam, bool isPending) async {
    if (isUserInTeam && isPending) {
      // User is pending - show appropriate message
      _showPendingUserDialog(user);
      return;
    }

    // Get existing privileges if user is already in the team
    int? existingPrivileges;
    if (isUserInTeam) {
      final notifier = context.read<PersonnelNotifier>();

      // First ensure data is loaded
      await notifier.loadPersonnel(
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId ?? 0,
      );

      // Then get the rule synchronously from cache
      final rule = notifier.getRuleForUser(
        userId: user.id_app_user ?? 0,
        supplierId: widget.supplierId ?? 0,
      );

      if (rule != null) {
        // existingPrivileges = rule.management_rule_code ?? 0;
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
      Navigator.pop(context);
      widget.onUserSelected(user, privilegesBitmask);
    }
  }

  void _showAlreadyInTeamDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Already in Team'),
        content: Text(
          '${user.personFirstName} ${user.personLastName} is already an active member of ${widget.supplierName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPendingUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Invitation'),
        content: Text(
          '${user.personFirstName} ${user.personLastName} has a pending invitation for ${widget.supplierName}. Please wait for them to accept or resend the invitation from the pending tab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getUserInitials(AppUser user) {
    final firstName = user.personFirstName?.trim() ?? '';
    final lastName = user.personLastName?.trim() ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      return '?';
    }

    final firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0] : '';

    return '$firstInitial$lastInitial'.toUpperCase();
  }

  Color _getRoleColor(String role, ColorScheme colorScheme) {
    switch (role.toLowerCase()) {
      case 'admin':
        return colorScheme.error;
      case 'manager':
        return colorScheme.primary;
      case 'recipe_catalog':
        return colorScheme.secondary;
      case 'supplier':
        return colorScheme.tertiary;
      case 'staff':
        return Colors.orange;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.security_rounded;
      case 'manager':
        return Icons.manage_accounts_rounded;
      case 'recipe_catalog':
        return Icons.restaurant_menu_rounded;
      case 'supplier':
        return Icons.inventory_2_rounded;
      case 'staff':
        return Icons.badge_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
