import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/role_bit_mapper.dart';
import 'package:gluttex_personnel/privilege_ui.dart';

class PrivilegeDialog extends StatefulWidget {
  final AppUser user;
  final String supplierName;
  final int? initialPrivileges; // Optional initial privileges bitmask

  const PrivilegeDialog({
    super.key,
    required this.user,
    required this.supplierName,
    this.initialPrivileges,
  });

  @override
  State<PrivilegeDialog> createState() => _PrivilegeDialogState();
}

class _PrivilegeDialogState extends State<PrivilegeDialog> {
  final Map<String, bool> _selectedPrivileges = {};

  @override
  void initState() {
    super.initState();
    _initializePrivileges();
  }

  void _initializePrivileges() {
    // If initial privileges are provided, use them
    if (widget.initialPrivileges != null) {
      final initialPrivilegeIds =
          RoleBitMapper.numberToPrivilegeIds(widget.initialPrivileges!);
      for (var privilege in PrivilegeManager.allPrivileges) {
        _selectedPrivileges[privilege.id] =
            initialPrivilegeIds.contains(privilege.id);
      }
    } else if (widget.user.isAdmin) {
      // Admins get all privileges
      for (var privilege in PrivilegeManager.allPrivileges) {
        _selectedPrivileges[privilege.id] = true;
      }
    } else {
      // Default privileges for non-admins
      for (var privilege in PrivilegeManager.allPrivileges) {
        _selectedPrivileges[privilege.id] = false;
      }
      // Set some basic defaults
      _selectedPrivileges['inventory_view'] = true;
      _selectedPrivileges['orders_view'] = true;
      _selectedPrivileges['personnel_view'] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(theme, colorScheme),
            // User Info
            _buildUserInfo(theme, colorScheme),
            // Privileges List
            Expanded(
              child: _buildPrivilegesList(theme, colorScheme),
            ),
            // Actions
            _buildActions(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Manage Permissions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context), // Pop with null
            icon: Icon(Icons.close_rounded,
                size: 24, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primaryContainer.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: widget.user.app_user_image_url != null
                  ? DecorationImage(
                      image: NetworkImage(widget.user.app_user_image_url!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: widget.user.app_user_image_url == null
                  ? colorScheme.primary.withOpacity(0.1)
                  : null,
            ),
            child: widget.user.app_user_image_url == null
                ? Icon(Icons.person_rounded,
                    color: colorScheme.primary, size: 24)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.personFirstName} ${widget.user.personLastName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.app_user_name ?? 'No username',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.supplierName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegesList(ThemeData theme, ColorScheme colorScheme) {
    final categories = _getCategories();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final category = categories[categoryIndex];
          final categoryPrivileges = PrivilegeManager.allPrivileges
              .where((privilege) => privilege.category == category)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Padding(
                padding: EdgeInsets.only(
                    bottom: 16, top: categoryIndex > 0 ? 24 : 0),
                child: Text(
                  category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              // Privileges in this category
              ...categoryPrivileges.map((privilege) =>
                  _buildPrivilegeItem(privilege, theme, colorScheme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrivilegeItem(
      PrivilegeItem privilege, ThemeData theme, ColorScheme colorScheme) {
    final PrivilegeUI? privilegeUI =
        PrivilegeUIManager.getPrivilege(privilege.id);
    final isSelected = _selectedPrivileges[privilege.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withOpacity(0.2)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(isSelected ? 0.1 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            privilegeUI?.icon,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          privilegeUI?.getTitle(context) ?? "",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          privilegeUI?.getDescription(context) ?? "",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.8)
                : colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: isSelected,
          onChanged: widget.user.isAdmin && privilege.id == 'full_access'
              ? null // Don't allow changing full access for admins
              : (value) {
                  setState(() {
                    _selectedPrivileges[privilege.id] = value;
                  });
                },
          activeColor: colorScheme.primary,
          activeTrackColor: colorScheme.primary.withOpacity(0.5),
        ),
        onTap: widget.user.isAdmin && privilege.id == 'full_access'
            ? null
            : () {
                setState(() {
                  _selectedPrivileges[privilege.id] = !isSelected;
                });
              },
      ),
    );
  }

  Widget _buildActions(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context), // Pop with null
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: colorScheme.outline),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _savePrivileges,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Permissions',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePrivileges() {
    // Get selected privilege IDs
    final selectedPrivilegeIds = _selectedPrivileges.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Convert to bitmask number using RoleBitMapper
    final privilegesBitmask =
        RoleBitMapper.privilegesToNumber(selectedPrivilegeIds);

    // Pop the dialog and return the integer value
    Navigator.pop(context, privilegesBitmask);
  }

  List<String> _getCategories() {
    return PrivilegeManager.allPrivileges
        .map((p) => p.category)
        .toSet()
        .toList();
  }
}
