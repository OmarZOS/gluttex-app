import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';

class SupplierCard extends StatelessWidget {
  final AppUser supplier;
  final VoidCallback onManagePrivileges;
  final VoidCallback onRemove;
  final VoidCallback? onMessage;
  final bool isLoading;

  const SupplierCard({
    Key? key,
    required this.supplier,
    required this.onManagePrivileges,
    required this.onRemove,
    this.onMessage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0.5,
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with loading state
                    _buildUserAvatar(colorScheme),
                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name with loading skeleton
                          _buildNameSection(textTheme, colorScheme),
                          const SizedBox(height: 8),

                          // Username with loading skeleton
                          _buildUsernameSection(textTheme, colorScheme),
                          const SizedBox(height: 8),

                          // Location with loading skeleton
                          _buildLocationSection(textTheme, colorScheme),
                        ],
                      ),
                    ),

                    // Status Badge
                    _buildStatusBadge(colorScheme, textTheme),
                  ],
                ),
              ),

              // Actions
              if (!isLoading) _buildActionButtons(colorScheme, textTheme),
            ],
          ),

          // Loading Overlay
          if (isLoading) _buildLoadingOverlay(colorScheme),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: colorScheme.surfaceVariant,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _buildAvatarImage(colorScheme),
          ),
        ),

        // Online indicator
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green,
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

  Widget _buildAvatarImage(ColorScheme colorScheme) {
    final imageUrl = supplier.app_user_image_url;

    // Check if URL is valid
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackAvatar(colorScheme);
    }

    // Validate URL format
    final uri = Uri.tryParse(imageUrl);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return _buildFallbackAvatar(colorScheme);
    }

    // Check if URL might be a local file path
    if (imageUrl.startsWith('file://') || imageUrl.startsWith('/')) {
      return _buildLocalImage(imageUrl, colorScheme);
    }

    // For network images, use error handling
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Failed to load network image: $error');
        return _buildFallbackAvatar(colorScheme);
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
      headers: const {
        'Accept': 'image/*',
      },
      cacheWidth: 112, // 2x size for retina displays
      cacheHeight: 112,
    );
  }

  Widget _buildLocalImage(String path, ColorScheme colorScheme) {
    final filePath = path.replaceFirst('file://', '');
    final file = File(filePath);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          );
        }

        if (snapshot.data == true) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Failed to load local image: $error');
              return _buildFallbackAvatar(colorScheme);
            },
          );
        } else {
          return _buildFallbackAvatar(colorScheme);
        }
      },
    );
  }

  Widget _buildFallbackAvatar(ColorScheme colorScheme) {
    final initials = _getInitials();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.2),
            colorScheme.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.person,
                size: 28,
                color: colorScheme.primary.withOpacity(0.6),
              ),
      ),
    );
  }

  String _getInitials() {
    final firstName = supplier.personFirstName ?? '';
    final lastName = supplier.personLastName ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final username = supplier.app_user_name ?? '';
      if (username.isNotEmpty) {
        return username.substring(0, 1).toUpperCase();
      }
      return '';
    }

    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  Widget _buildNameSection(TextTheme textTheme, ColorScheme colorScheme) {
    if (isLoading) {
      return Container(
        width: 120,
        height: 20,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final fullName =
        '${supplier.personFirstName ?? ''} ${supplier.personLastName ?? ''}'
            .trim();

    if (fullName.isEmpty) {
      return Row(
        children: [
          Icon(
            Icons.person_outline,
            size: 14,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(width: 6),
          Text(
            'No name provided',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildUsernameSection(TextTheme textTheme, ColorScheme colorScheme) {
    if (isLoading) {
      return Container(
        width: 80,
        height: 16,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final username = supplier.app_user_name;

    return Row(
      children: [
        Icon(
          Icons.alternate_email,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            username?.isNotEmpty == true ? '@$username' : 'No username',
            style: textTheme.bodyMedium?.copyWith(
              color: username?.isNotEmpty == true
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontStyle: username?.isNotEmpty == true ? null : FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(TextTheme textTheme, ColorScheme colorScheme) {
    if (isLoading) {
      return Container(
        width: 100,
        height: 16,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final location = supplier.locationName;

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            location?.isNotEmpty == true ? location! : 'No location set',
            style: textTheme.bodyMedium?.copyWith(
              color: location?.isNotEmpty == true
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontStyle: location?.isNotEmpty == true ? null : FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme, TextTheme textTheme) {
    if (isLoading) {
      return Container(
        width: 60,
        height: 24,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final role = supplier.app_user_type_desc ?? 'Supplier';
    final badgeColor = _getRoleColor(role, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            role,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.admin_panel_settings_outlined,
              text: 'Privileges',
              onTap: onManagePrivileges,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.chat_bubble_outline,
              text: 'Message',
              onTap: onMessage ?? () {},
              color: colorScheme.secondary,
              enabled: onMessage != null,
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            icon: Icons.delete_outline,
            onTap: onRemove,
            color: colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: enabled ? color : color.withOpacity(0.3),
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: enabled ? color : color.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withOpacity(0.05),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(ColorScheme colorScheme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role, ColorScheme colorScheme) {
    final roleLower = role.toLowerCase();

    if (roleLower.contains('admin')) return colorScheme.error;
    if (roleLower.contains('manager')) return colorScheme.primary;
    if (roleLower.contains('chef')) return colorScheme.secondary;
    if (roleLower.contains('supplier')) return colorScheme.tertiary;
    if (roleLower.contains('staff')) return Colors.orange;

    return colorScheme.onSurfaceVariant;
  }

  IconData _getRoleIcon(String role) {
    final roleLower = role.toLowerCase();

    if (roleLower.contains('admin')) return Icons.security;
    if (roleLower.contains('manager')) return Icons.manage_accounts;
    if (roleLower.contains('chef')) return Icons.restaurant_menu;
    if (roleLower.contains('supplier')) return Icons.inventory;
    if (roleLower.contains('staff')) return Icons.badge;

    return Icons.person;
  }
}
