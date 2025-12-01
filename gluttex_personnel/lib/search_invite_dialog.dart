import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/privilege_dialog.dart';
import 'package:provider/provider.dart';

class SearchInviteDialog extends StatefulWidget {
  final Function(AppUser, int) onUserSelected; // Updated to include privileges
  final int userId;
  final int? orgId;
  final int? supplierId;
  final String supplierName; // Added supplier name for privilege dialog

  const SearchInviteDialog({
    Key? key,
    required this.onUserSelected,
    required this.orgId,
    required this.userId,
    this.supplierId = 0,
    required this.supplierName, // Required for privilege dialog
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
          userId,
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
            // Header
            _buildHeader(),
            // Search Bar
            _buildSearchBar(),
            // Loading indicator or results
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
                      'Find team members to collaborate with',
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
    if (notifier.isLoading && notifier.personnel.isEmpty) {
      return _buildLoadingState();
    }

    if (notifier.searchQuery.isEmpty && notifier.personnel.isEmpty) {
      return _buildInitialState();
    }

    if (notifier.personnel.isEmpty && notifier.searchQuery.isNotEmpty) {
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
          'Search for team members',
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                'Found ${notifier.personnel.length} user${notifier.personnel.length == 1 ? '' : 's'}',
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
            itemCount: notifier.personnel.length,
            itemBuilder: (context, index) {
              final user = notifier.personnel[index];
              return _buildUserTile(user);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showPrivilegeDialog(AppUser user) async {
    // Show privilege dialog and wait for the result
    final int? privilegesBitmask = await showDialog<int>(
      context: context,
      builder: (context) => PrivilegeDialog(
        user: user,
        supplierName: widget.supplierName,
        // initialPrivileges: 0, // Start with no privileges, or pass existing if editing
      ),
    );

    // If user selected privileges (didn't cancel)
    if (privilegesBitmask != null && mounted) {
      // Close the search dialog and call the callback with user and privileges
      Navigator.pop(context);
      widget.onUserSelected(user, privilegesBitmask);
    }
    // If privilegesBitmask is null, user cancelled the privilege dialog
    // so we stay in the search dialog
  }

  Widget _buildUserTile(AppUser user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPrivilegeDialog(user),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
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
                // Avatar
                _buildUserAvatar(user),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        '${user.personFirstName} ${user.personLastName}'.trim(),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Username
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

                      // Role
                      const SizedBox(height: 4),
                      _buildUserRole(
                          user.app_user_type_desc, colorScheme, textTheme),
                    ],
                  ),
                ),

                // Add Button
                _buildAddButton(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(AppUser user) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Avatar Container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: colorScheme.surfaceVariant,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: user.app_user_image_url != null &&
                    user.app_user_image_url!.isNotEmpty
                ? Image.network(
                    user.app_user_image_url!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackAvatar(colorScheme, user);
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
                : _buildFallbackAvatar(colorScheme, user),
          ),
        ),

        // Online Status Indicator
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _getStatusColor(user),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: colorScheme.surface,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(ColorScheme colorScheme, AppUser user) {
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
            color: color,
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

  Widget _buildAddButton(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.person_add_alt_1_rounded,
        size: 20,
        color: colorScheme.primary,
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

  Color _getStatusColor(AppUser user) {
    return Colors.green;
  }

  Color _getRoleColor(String role, ColorScheme colorScheme) {
    switch (role.toLowerCase()) {
      case 'admin':
        return colorScheme.error;
      case 'manager':
        return colorScheme.primary;
      case 'chef':
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
      case 'chef':
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
